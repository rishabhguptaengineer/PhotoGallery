import Foundation
import CoreData

final class CoreDataManager: CoreDataManaging {

    static let shared = CoreDataManager()

    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PhotoGallery")
        container.loadPersistentStores { _, error in
            if let error { fatalError("Core Data failed to load: \(error)") }
        }
        return container
    }()

    var context: NSManagedObjectContext { persistentContainer.viewContext }

    func fetchPhotos() throws -> [Photo] {
        // TODO: Implement fetch
        return []
    }

    func savePhoto(_ photo: Photo) throws {
        // TODO: Implement save
    }

    func deletePhoto(id: Int64) throws {
        // TODO: Implement delete
    }
}
