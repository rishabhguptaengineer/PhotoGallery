import Foundation

// MARK: - PhotoListViewModel

final class PhotoListViewModel {

    // MARK: - Dependencies

    private let apiService: APIServiceProtocol
    private let persistenceManager: CoreDataManaging

    // MARK: - State

    private(set) var photos: [Photo] = []

    private(set) var state: ViewState = .idle {
        didSet { onStateChanged?(state) }
    }

    // MARK: - Callbacks

    var onStateChanged: ((ViewState) -> Void)?
    var onNetworkError: ((String) -> Void)?
    var onPaginationStateChanged: ((Bool) -> Void)?

    // MARK: - Pagination

    private var currentPage = 1
    private let pageSize = 50
    private var isFetching = false

    // MARK: - Init

    init(apiService: APIServiceProtocol, persistenceManager: CoreDataManaging) {
        self.apiService = apiService
        self.persistenceManager = persistenceManager
    }

    // MARK: - Public Actions

    /// Loads photos from Core Data first. Falls back to the API if the local store is empty.
    func loadPhotos() {
        state = .loading
        do {
            let localPhotos = try persistenceManager.fetchPhotos()
            if !localPhotos.isEmpty {
                photos = localPhotos
                state = .loaded
            } else {
                currentPage = 1
                Task { await fetchAndSavePhotos(page: 1) }
            }
        } catch {
            state = .error("Unable to load saved photos.")
        }
    }

    /// Re-fetches page 1 from the API, upserts results into Core Data, and reloads the list.
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
                photos = localPhotos
                isFetching = false
                state = localPhotos.isEmpty ? .empty : .loaded
            } catch {
                isFetching = false
                handleNetworkFailure()
            }
        }
    }

    /// Fetches the next page from the API and appends the new photos to the current list.
    func loadNextPage() {
        guard !isFetching else { return }
        isFetching = true
        onPaginationStateChanged?(true)
        let nextPage = currentPage + 1

        Task {
            do {
                let newPhotos = try await apiService.fetchPhotos(page: nextPage, limit: pageSize)
                if !newPhotos.isEmpty {
                    try persistenceManager.savePhotos(newPhotos)
                    currentPage = nextPage
                    photos.append(contentsOf: newPhotos)
                }
                isFetching = false
                onPaginationStateChanged?(false)
                state = .loaded
            } catch {
                isFetching = false
                onPaginationStateChanged?(false)
                // Pagination failures are non-fatal; the existing list stays visible.
                onNetworkError?("You are currently offline. Showing saved data.")
            }
        }
    }

    /// Updates a single photo in the in-memory list (called by the detail screen after an edit).
    func updatePhoto(at index: Int, with updatedPhoto: Photo) {
        guard photos.indices.contains(index) else { return }
        photos[index] = updatedPhoto
    }

    /// Removes a single photo from the in-memory list (called by the detail screen after deletion).
    func removePhoto(at index: Int) {
        guard photos.indices.contains(index) else { return }
        photos.remove(at: index)
        state = photos.isEmpty ? .empty : .loaded
    }

    // MARK: - Private Helpers

    /// Fetches a page from the API, saves to Core Data, then reloads the local list.
    private func fetchAndSavePhotos(page: Int) async {
        isFetching = true
        do {
            let apiPhotos = try await apiService.fetchPhotos(page: page, limit: pageSize)
            try persistenceManager.savePhotos(apiPhotos)
            let localPhotos = try persistenceManager.fetchPhotos()
            photos = localPhotos
            isFetching = false
            state = localPhotos.isEmpty ? .empty : .loaded
        } catch {
            isFetching = false
            handleNetworkFailure()
        }
    }

    /// Shared offline-fallback handler. If cached data exists, keeps the list visible and
    /// surfaces a user-friendly offline banner. Otherwise, surfaces an error state.
    private func handleNetworkFailure() {
        if let cachedPhotos = try? persistenceManager.fetchPhotos(), !cachedPhotos.isEmpty {
            photos = cachedPhotos
            state = .loaded
            onNetworkError?("You are currently offline. Showing saved data.")
        } else {
            state = .error("No internet connection. Unable to load photos.")
        }
    }
}
