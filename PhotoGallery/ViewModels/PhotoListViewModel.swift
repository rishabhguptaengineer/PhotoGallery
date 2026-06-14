import Foundation

final class PhotoListViewModel {

    private let apiService: APIServiceProtocol
    private let persistenceManager: CoreDataManaging
    private let imageCacheManager: ImageCacheManaging

    private(set) var photos: [Photo] = []

    init(
        apiService: APIServiceProtocol,
        persistenceManager: CoreDataManaging,
        imageCacheManager: ImageCacheManaging
    ) {
        self.apiService = apiService
        self.persistenceManager = persistenceManager
        self.imageCacheManager = imageCacheManager
    }
}
