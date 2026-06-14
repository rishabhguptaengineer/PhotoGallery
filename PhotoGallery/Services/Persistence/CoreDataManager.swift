import Foundation
import CoreData

// MARK: - CoreDataManager

final class CoreDataManager: CoreDataManaging {

    // MARK: Singleton

    static let shared = CoreDataManager()
    private init() {}

    // MARK: Stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PhotoGallery")
        container.loadPersistentStores { _, error in
            if let error {
                // fatalError is acceptable here — unrecoverable startup failure.
                fatalError("Core Data failed to load persistent stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()

    var viewContext: NSManagedObjectContext { persistentContainer.viewContext }

    // MARK: - Context Save Helper

    private func saveContext(_ context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw AppError.coreDataError(error)
        }
    }

    // MARK: - Fetch Entity by ID (private helper)

    private func fetchEntity(
        id: Int,
        in context: NSManagedObjectContext
    ) throws -> PhotoEntity? {
        let request = PhotoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", Int64(id))
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first
        } catch {
            throw AppError.coreDataError(error)
        }
    }
}

// MARK: - CoreDataManaging Implementation

extension CoreDataManager {

    // MARK: Save (Upsert)

    func savePhotos(_ photos: [Photo]) throws {
        let context = viewContext
        for photo in photos {
            if let existing = try fetchEntity(id: photo.id, in: context) {
                // Preserve the local title if it has been modified
                let localTitle = existing.title
                photo.populate(entity: existing)
                if let localTitle = localTitle, !localTitle.isEmpty {
                    existing.title = localTitle
                }
            } else {
                // Insert new record
                let entity = PhotoEntity(context: context)
                photo.populate(entity: entity)
            }
        }
        try saveContext(context)
    }

    // MARK: Fetch

    func fetchPhotos() throws -> [Photo] {
        let request = PhotoEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { $0.toDomain() }
        } catch {
            throw AppError.coreDataError(error)
        }
    }

    // MARK: Update Title

    func updateTitle(photoId: Int, title: String) throws {
        guard let entity = try fetchEntity(id: photoId, in: viewContext) else {
            throw AppError.photoNotFound(id: photoId)
        }
        entity.title = title
        try saveContext(viewContext)
    }

    // MARK: Delete

    func deletePhoto(photoId: Int) throws {
        guard let entity = try fetchEntity(id: photoId, in: viewContext) else {
            throw AppError.photoNotFound(id: photoId)
        }
        viewContext.delete(entity)
        try saveContext(viewContext)
    }

    // MARK: Has Data

    func hasData() throws -> Bool {
        let request = PhotoEntity.fetchRequest()
        request.fetchLimit = 1
        request.includesPropertyValues = false  // count-only, skip property loading
        do {
            let count = try viewContext.count(for: request)
            return count > 0
        } catch {
            throw AppError.coreDataError(error)
        }
    }
}
