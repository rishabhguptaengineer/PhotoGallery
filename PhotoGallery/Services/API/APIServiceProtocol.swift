import Foundation

protocol APIServiceProtocol {
    func fetchPhotos() async throws -> [PhotoDTO]
    func fetchPhoto(id: Int64) async throws -> PhotoDTO
}
