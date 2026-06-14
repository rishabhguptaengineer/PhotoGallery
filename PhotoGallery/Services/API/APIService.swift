import Foundation

// MARK: - APIService

final class APIService: APIServiceProtocol {

    // MARK: - Dependencies

    private let session: URLSession

    // MARK: - Init

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - APIServiceProtocol

    func fetchPhotos(page: Int, limit: Int) async throws -> [Photo] {
        let url = try Endpoint.photos(page: page, limit: limit).url()
        let dtos = try await performRequest(url: url, as: [PhotoDTO].self)
        return await assemblePhotos(from: dtos)
    }
}

// MARK: - Private: Network

private extension APIService {

    /// Executes an HTTP GET request, validates the response, and decodes the body.
    func performRequest<T: Decodable>(url: URL, as type: T.Type) async throws -> T {
        let request = URLRequest(url: url)
        let (data, response) = try await executeRequest(request)
        try validateResponse(response)
        return try decode(data, as: type)
    }

    /// Wraps `URLSession.data(for:)` and maps `URLError` to `AppError.networkError`.
    func executeRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw AppError.networkError(error)
        }
    }

    /// Validates that the HTTP status code is in the 2xx range.
    func validateResponse(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw AppError.unknown
        }
        guard (200...299).contains(http.statusCode) else {
            throw AppError.invalidResponse(statusCode: http.statusCode)
        }
    }

    /// Decodes raw `Data` into `T`, mapping `DecodingError` to `AppError.decodingFailed`.
    func decode<T: Decodable>(_ data: Data, as type: T.Type) throws -> T {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw AppError.decodingFailed(error)
        }
    }
}

// MARK: - Private: Thumbnail Assembly

private extension APIService {

    /// Builds Photo domain objects concurrently, downloading each thumbnail in parallel.
    /// Uses `withTaskGroup` so all thumbnail downloads run at the same time.
    func assemblePhotos(from dtos: [PhotoDTO]) async -> [Photo] {
        await withTaskGroup(of: Photo.self) { group in
            for dto in dtos {
                group.addTask {
                    let data = await self.downloadThumbnail(from: dto.thumbnailUrl)
                    return dto.toDomain(thumbnailData: data)
                }
            }

            // Collect results — order may differ from input due to concurrency.
            var photos: [Photo] = []
            photos.reserveCapacity(dtos.count)
            for await photo in group {
                photos.append(photo)
            }
            // Restore stable ordering by id.
            return photos.sorted { $0.id < $1.id }
        }
    }

    /// Downloads a thumbnail image and returns its raw `Data`.
    ///
    /// - Never throws — failures are silently swallowed and `nil` is returned,
    ///   so the photo pipeline continues even if a single thumbnail is unavailable.
    func downloadThumbnail(from urlString: String) async -> Data? {
        var correctedUrlString = urlString.replacingOccurrences(of: "via.placeholder.com", with: "placehold.co")
        if !correctedUrlString.hasSuffix(".png") {
            correctedUrlString += "/ffffff.png"
        }
        
        guard let url = URL(string: correctedUrlString) else { return nil }
        do {
            let (data, response) = try await session.data(from: url)
            guard
                let http = response as? HTTPURLResponse,
                (200...299).contains(http.statusCode)
            else { return nil }
            return data
        } catch {
            // Thumbnail failures are non-fatal — return nil and continue.
            return nil
        }
    }
}
