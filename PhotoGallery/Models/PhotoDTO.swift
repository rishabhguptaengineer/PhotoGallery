import Foundation

// MARK: - PhotoDTO

struct PhotoDTO: Codable {
    let id: Int
    let albumId: Int
    let title: String
    let url: String
    let thumbnailUrl: String

    // MARK: Mapping

    func toDomain() -> Photo {
        Photo(
            id: id,
            albumId: albumId,
            title: title,
            url: url,
            thumbnailUrl: thumbnailUrl,
            thumbnailData: nil
        )
    }
}
