import Foundation

// MARK: - CoreDataManaging Protocol

protocol CoreDataManaging {

    /// Upsert a batch of photos. Existing records are updated; new records are inserted.
    func savePhotos(_ photos: [Photo]) throws

    /// Fetch all photos sorted by id ascending.
    func fetchPhotos() throws -> [Photo]

    /// Update the title of a single photo by its domain id.
    func updateTitle(photoId: Int, title: String) throws

    /// Delete a single photo by its domain id.
    func deletePhoto(photoId: Int) throws

    /// Returns true if at least one photo record exists (uses a count request).
    func hasData() throws -> Bool
}
