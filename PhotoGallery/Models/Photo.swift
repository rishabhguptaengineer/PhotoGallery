import Foundation

// MARK: - Photo

struct Photo: Sendable {
    let id: Int
    let albumId: Int
    var title: String
    let url: String
    let thumbnailUrl: String
    var thumbnailData: Data?
}
