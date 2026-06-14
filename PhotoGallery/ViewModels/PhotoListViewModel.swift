import Foundation

// MARK: - PhotoListViewModel

final class PhotoListViewModel {

    // MARK: - Dependencies

    private let apiService: APIServiceProtocol
    private let persistenceManager: CoreDataManaging

    // MARK: - Properties

    private(set) var photos: [Photo] = []
    private(set) var state: ViewState = .idle {
        didSet {
            onStateChanged?(state)
        }
    }

    var onStateChanged: ((ViewState) -> Void)?

    // MARK: - Pagination State

    private var currentPage = 1
    private let pageSize = 50
    private var isFetching = false

    // MARK: - Init

    init(apiService: APIServiceProtocol, persistenceManager: CoreDataManaging) {
        self.apiService = apiService
        self.persistenceManager = persistenceManager
    }

    // MARK: - Actions

    /// Loads photos from Core Data first. If empty, fetches from the API.
    func loadPhotos() {
        state = .loading
        do {
            let localPhotos = try persistenceManager.fetchPhotos()
            if !localPhotos.isEmpty {
                self.photos = localPhotos
                state = .loaded
            } else {
                currentPage = 1
                Task {
                    await fetchAndSavePhotos(page: 1)
                }
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    /// Fetches latest page (page 1) from the API, saves to Core Data, and reloads local data.
    func refresh() {
        guard !isFetching else { return }
        isFetching = true
        state = .loading
        currentPage = 1

        Task {
            do {
                let apiPhotos = try await apiService.fetchPhotos(page: 1, limit: pageSize)
                try persistenceManager.savePhotos(apiPhotos)
                let localPhotos = try persistenceManager.fetchPhotos()
                self.photos = localPhotos
                isFetching = false
                state = localPhotos.isEmpty ? .empty : .loaded
            } catch {
                isFetching = false
                state = .error(error.localizedDescription)
            }
        }
    }

    /// Loads the next page of photos from the API and appends them.
    func loadNextPage() {
        guard !isFetching else { return }
        isFetching = true
        let nextPage = currentPage + 1

        Task {
            do {
                let newPhotos = try await apiService.fetchPhotos(page: nextPage, limit: pageSize)
                if !newPhotos.isEmpty {
                    try persistenceManager.savePhotos(newPhotos)
                    currentPage = nextPage
                    self.photos.append(contentsOf: newPhotos)
                }
                isFetching = false
                state = .loaded
            } catch {
                isFetching = false
                state = .error(error.localizedDescription)
            }
        }
    }

    /// Deletes a photo by index, removing it from Core Data and the local array.
    func deletePhoto(at index: Int) {
        guard index >= 0 && index < photos.count else { return }
        let photoToDelete = photos[index]
        do {
            try persistenceManager.deletePhoto(photoId: photoToDelete.id)
            photos.remove(at: index)
            state = photos.isEmpty ? .empty : .loaded
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    // MARK: - Private Helpers

    private func fetchAndSavePhotos(page: Int) async {
        isFetching = true
        do {
            let apiPhotos = try await apiService.fetchPhotos(page: page, limit: pageSize)
            try persistenceManager.savePhotos(apiPhotos)
            let localPhotos = try persistenceManager.fetchPhotos()
            self.photos = localPhotos
            isFetching = false
            state = localPhotos.isEmpty ? .empty : .loaded
        } catch {
            isFetching = false
            state = .error(error.localizedDescription)
        }
    }
}
