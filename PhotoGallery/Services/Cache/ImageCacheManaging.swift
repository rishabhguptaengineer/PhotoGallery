import UIKit

// MARK: - ImageCacheManaging

/// Abstracts full-size image caching so consumers depend on a protocol, not a concrete type.
/// This protocol is intentionally scoped to the detail screen's use-case only.
/// Thumbnail images remain in Core Data and are never routed through this cache.
protocol ImageCacheManaging: AnyObject {

    /// Returns a cached `UIImage` for the given URL string if one exists in memory, otherwise `nil`.
    /// This is a synchronous cache-hit check, suitable for an immediate lookup before async loading.
    func image(for urlString: String) -> UIImage?

    /// Returns an image for the given URL string.
    /// Checks the in-memory cache first. On a miss, downloads the image, caches it, and returns it.
    /// If two callers request the same URL simultaneously, only one network request executes;
    /// both callers receive the result when it completes.
    func loadImage(from urlString: String) async -> UIImage?
}
