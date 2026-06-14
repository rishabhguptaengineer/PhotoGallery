import UIKit

// MARK: - PhotoDetailViewModel

final class PhotoDetailViewModel {

    // MARK: - Dependencies

    private let persistenceManager: CoreDataManaging
    private let imageCacheManager: ImageCacheManaging

    // MARK: - Properties

    private(set) var photo: Photo

    var onPhotoUpdated: ((Photo) -> Void)?
    var onPhotoDeleted: ((Int) -> Void)?

    // MARK: - Init

    init(
        photo: Photo,
        persistenceManager: CoreDataManaging,
        imageCacheManager: ImageCacheManaging
    ) {
        self.photo = photo
        self.persistenceManager = persistenceManager
        self.imageCacheManager = imageCacheManager
    }

    // MARK: - Full Image Loading

    /// Returns the full-size image for the current photo.
    ///
    /// Lookup order:
    /// 1. **Cache hit** — `ImageCacheManager` holds the image from a previous visit this session.
    ///    Returned synchronously with no network request.
    /// 2. **Cache miss** — `ImageCacheManager` downloads the image, stores it in `NSCache`,
    ///    and returns it. If an identical request is already in-flight (e.g. the user opens
    ///    and closes the same photo rapidly), the existing task is awaited instead of
    ///    starting a duplicate network request.
    ///
    /// Full-size images are never written to Core Data. They are held in-memory for
    /// the session only, keeping the Core Data store lean.
    func loadFullImage() async -> UIImage? {
        await imageCacheManager.loadImage(from: photo.url)
    }

    // MARK: - Save Title

    /// Trims the title, validates it, updates Core Data/local model, and notifies the parent listener.
    func saveTitle(_ newTitle: String) throws {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw AppError.saveFailed(reason: "Title cannot be empty.")
        }

        try persistenceManager.updateTitle(photoId: photo.id, title: trimmed)
        photo.title = trimmed
        onPhotoUpdated?(photo)
    }

    // MARK: - Delete Photo

    /// Deletes the photo from Core Data and notifies the parent listener.
    func deletePhoto() throws {
        try persistenceManager.deletePhoto(photoId: photo.id)
        onPhotoDeleted?(photo.id)
    }
}
