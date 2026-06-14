import Foundation

final class APIService: APIServiceProtocol {

    func fetchPhotos() async throws -> [PhotoDTO] {
        // TODO: Implement networking
        return []
    }

    func fetchPhoto(id: Int64) async throws -> PhotoDTO {
        // TODO: Implement networking
        throw URLError(.unsupportedURL)
    }
}
