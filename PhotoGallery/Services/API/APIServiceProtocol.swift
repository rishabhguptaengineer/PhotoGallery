import Foundation

// MARK: - APIServiceProtocol

/// Abstracts the networking layer so ViewModels depend on a protocol, not a concrete type.
protocol APIServiceProtocol {

    /// Fetches a paginated list of photos, including pre-downloaded thumbnail data.
    /// - Parameters:
    ///   - page:  1-based page index.
    ///   - limit: Maximum number of items to return.
    /// - Returns: An array of fully-populated `Photo` domain objects.
    func fetchPhotos(page: Int, limit: Int) async throws -> [Photo]
}
