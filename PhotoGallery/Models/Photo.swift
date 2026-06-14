import Foundation

struct Photo {
    let id: Int64
    let albumId: Int64
    var title: String
    let url: String
    let thumbnailUrl: String
    var thumbnailData: Data?
}
