import Foundation

// MARK: - Endpoint

/// Represents every API endpoint the app can call.
/// Responsible solely for constructing the correct URL — no networking logic here.
enum Endpoint {

    case photos(page: Int, limit: Int)

    // MARK: - Base

    private static let baseURL = "https://jsonplaceholder.typicode.com"

    // MARK: - URL Construction

    /// Returns the fully-formed `URL` for this endpoint, or throws `AppError.invalidURL`.
    func url() throws -> URL {
        var components = URLComponents(string: Self.baseURL)

        switch self {
        case .photos(let page, let limit):
            components?.path = "/photos"
            components?.queryItems = [
                URLQueryItem(name: "_page", value: "\(page)"),
                URLQueryItem(name: "_limit", value: "\(limit)")
            ]
        }

        guard let url = components?.url else {
            throw AppError.invalidURL(components?.string ?? Self.baseURL)
        }
        return url
    }
}
