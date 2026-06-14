import UIKit

// MARK: - ImageCacheManager

/// A lightweight in-memory image cache backed by `NSCache`.
///
/// Responsibilities:
/// - Cache full-size images for the duration of the app session.
/// - Prevent duplicate concurrent network requests for the same URL.
/// - Return cached images immediately on subsequent visits to the Detail Screen.
///
/// Scope:
/// - Used exclusively for full-size images on the Detail Screen.
/// - Thumbnail images are stored in Core Data and are never routed through this cache.
///
/// Thread Safety:
/// - All mutable state (`runningTasks`) is automatically
///   serialised by Swift Concurrency — no manual locking required.
/// - `NSCache` is thread-safe per Apple's documentation.
final class ImageCacheManager: ImageCacheManaging {

    // MARK: - Private State

    /// In-memory store keyed by URL string. NSCache evicts objects automatically under memory pressure.
    private let cache: NSCache<NSString, UIImage> = {
        let c = NSCache<NSString, UIImage>()
        c.countLimit = 100                    // Max 100 images
        c.totalCostLimit = 50 * 1024 * 1024  // ~50 MB soft limit
        return c
    }()

    /// Tracks in-flight download tasks, keyed by URL string.
    /// Guarded by the serial queue below to prevent data races.
    private var runningTasks: [String: Task<UIImage?, Never>] = [:]

    /// A serial queue that serialises mutations to `runningTasks`.
    /// This avoids making the entire class an `actor` while still
    /// preventing dictionary races without blocking async work.
    private let taskQueue = DispatchQueue(label: "com.photogallery.imagecache.taskqueue")

    // MARK: - ImageCacheManaging

    /// Synchronous cache-hit check. Returns a cached image immediately, or `nil` on a miss.
    func image(for urlString: String) -> UIImage? {
        cache.object(forKey: urlString as NSString)
    }

    /// Full async load: checks cache → deduplicates in-flight requests → downloads on miss.
    func loadImage(from urlString: String) async -> UIImage? {

        // 1. Cache hit — return immediately without any network work.
        if let cached = cache.object(forKey: urlString as NSString) {
            return cached
        }

        // 2. In-flight deduplication — if a download for this URL is already running,
        //    await its result instead of starting a second network request.
        let existingTask: Task<UIImage?, Never>? = taskQueue.sync { runningTasks[urlString] }
        if let existingTask {
            return await existingTask.value
        }

        // 3. Cache miss — create a new download task and register it.
        let task = Task<UIImage?, Never> { [weak self] in
            guard let self else { return nil }
            let image = await self.download(urlString: urlString)
            // Clean up regardless of whether download succeeded.
            self.taskQueue.async { self.runningTasks.removeValue(forKey: urlString) }
            return image
        }

        taskQueue.sync { runningTasks[urlString] = task }

        return await task.value
    }

    // MARK: - Private Helpers

    /// Downloads an image from the corrected placeholder URL, validates the response,
    /// converts `Data` to `UIImage`, stores it in the cache, and returns it.
    private func download(urlString: String) async -> UIImage? {
        guard let url = PlaceholderURLHelper.correctedURL(from: urlString) else { return nil }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard
                let http = response as? HTTPURLResponse,
                (200...299).contains(http.statusCode),
                let image = UIImage(data: data)
            else { return nil }

            // Store in NSCache for subsequent requests during this session.
            cache.setObject(image, forKey: urlString as NSString)
            return image
        } catch {
            // Download failures are non-fatal — return nil and let the caller show a placeholder.
            return nil
        }
    }
}
