import Foundation

// MARK: - PhotoDTO

struct PhotoDTO: Codable {

    let id: Int
    let albumId: Int
    let title: String
    let url: String
    let thumbnailUrl: String

    // MARK: - CodingKeys

    private enum CodingKeys: String, CodingKey {
        case id
        case albumId
        case title
        case url
        case thumbnailUrl
    }

    // MARK: - Mapping

    /// Converts the DTO to a domain Photo, optionally attaching downloaded thumbnail data.
    func toDomain(thumbnailData: Data? = nil) -> Photo {
        Photo(
            id: id,
            albumId: albumId,
            title: title,
            url: url,
            thumbnailUrl: thumbnailUrl,
            thumbnailData: thumbnailData
        )
    }
}
