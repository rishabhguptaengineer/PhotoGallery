import Foundation

final class PhotoDetailViewModel {

    private let persistenceManager: CoreDataManaging

    var photo: Photo?

    init(persistenceManager: CoreDataManaging) {
        self.persistenceManager = persistenceManager
    }
}
