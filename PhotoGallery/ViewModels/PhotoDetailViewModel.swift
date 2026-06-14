import Foundation

final class PhotoDetailViewModel {

    // MARK: - Dependencies

    private let persistenceManager: CoreDataManaging
    private let session: URLSession

    // MARK: - Properties

    private(set) var photo: Photo

    var onPhotoUpdated: ((Photo) -> Void)?
    var onPhotoDeleted: ((Int) -> Void)?

    // MARK: - Init

    init(
        photo: Photo,
        persistenceManager: CoreDataManaging,
        session: URLSession = .shared
    ) {
        self.photo = photo
        self.persistenceManager = persistenceManager
        self.session = session
    }

    // MARK: - Full Image Loading

    /// Downloads the full-size image data using async/await.
    /// Does not save the full-size image to Core Data.
    func downloadFullImage() async -> Data? {
        var correctedUrlString = photo.url.replacingOccurrences(of: "via.placeholder.com", with: "placehold.co")
        if !correctedUrlString.hasSuffix(".png") {
            correctedUrlString += "/ffffff.png"
        }

        guard let url = URL(string: correctedUrlString) else { return nil }
        do {
            let (data, response) = try await session.data(from: url)
            guard
                let http = response as? HTTPURLResponse,
                (200...299).contains(http.statusCode)
            else { return nil }
            return data
        } catch {
            return nil
        }
    }

    // MARK: - Save Title

    /// Trims the title, validates it, updates Core Data/local model, and notifies the parent listener.
    func saveTitle(_ newTitle: String) throws {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw AppError.saveFailed(reason: "Title cannot be empty.")
        }

        // Update database
        try persistenceManager.updateTitle(photoId: photo.id, title: trimmed)

        // Update local state
        photo.title = trimmed

        // Notify parent screen
        onPhotoUpdated?(photo)
    }

    // MARK: - Delete Photo

    /// Deletes the photo from Core Data and notifies the parent listener.
    func deletePhoto() throws {
        try persistenceManager.deletePhoto(photoId: photo.id)
        onPhotoDeleted?(photo.id)
    }
}
