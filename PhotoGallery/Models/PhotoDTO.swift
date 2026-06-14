import Foundation

struct PhotoDTO: Codable {
    let id: Int64
    let albumId: Int64
    let title: String
    let url: String
    let thumbnailUrl: String

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
