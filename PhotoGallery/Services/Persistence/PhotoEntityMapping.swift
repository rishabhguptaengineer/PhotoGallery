import Foundation
import CoreData

// MARK: - PhotoEntity → Domain

extension PhotoEntity {

    /// Maps a Core Data entity to the domain Photo model.
    func toDomain() -> Photo {
        Photo(
            id: Int(id),
            albumId: Int(albumId),
            title: title ?? "",
            url: url ?? "",
            thumbnailUrl: thumbnailUrl ?? "",
            thumbnailData: thumbnailData
        )
    }
}

// MARK: - Domain → PhotoEntity

extension Photo {

    /// Populates an existing (or newly created) PhotoEntity with the Photo's values.
    /// Called for both insert and update paths, keeping the mapping DRY.
    func populate(entity: PhotoEntity) {
        entity.id = Int64(id)
        entity.albumId = Int64(albumId)
        entity.title = title
        entity.url = url
        entity.thumbnailUrl = thumbnailUrl
        entity.thumbnailData = thumbnailData
    }
}
