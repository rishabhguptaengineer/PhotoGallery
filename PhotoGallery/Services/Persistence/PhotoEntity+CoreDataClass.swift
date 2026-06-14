import Foundation
import CoreData

// MARK: - PhotoEntity

/// NSManagedObject subclass for the PhotoEntity Core Data entity.
/// Code-gen is set to Manual/None so we own this file entirely.
@objc(PhotoEntity)
public class PhotoEntity: NSManagedObject {

    @NSManaged public var id: Int64
    @NSManaged public var albumId: Int64
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var thumbnailUrl: String?
    @NSManaged public var thumbnailData: Data?
}

// MARK: - Fetch Request

extension PhotoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoEntity> {
        NSFetchRequest<PhotoEntity>(entityName: "PhotoEntity")
    }
}
