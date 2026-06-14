import Foundation

// MARK: - AppError

enum AppError: LocalizedError {

    // MARK: Networking
    case invalidURL(String)
    case invalidResponse(statusCode: Int)
    case decodingFailed(Error)
    case networkError(Error)
    case unknown

    // MARK: Persistence
    case coreDataError(Error)
    case photoNotFound(id: Int)
    case saveFailed(reason: String)

    // MARK: - LocalizedError

    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .invalidResponse(let code):
            return "Invalid HTTP response with status code \(code)."
        case .decodingFailed(let underlying):
            return "Decoding failed: \(underlying.localizedDescription)"
        case .networkError(let underlying):
            return "Network error: \(underlying.localizedDescription)"
        case .unknown:
            return "An unknown error occurred."
        case .coreDataError(let underlying):
            return "Core Data error: \(underlying.localizedDescription)"
        case .photoNotFound(let id):
            return "Photo with id \(id) not found."
        case .saveFailed(let reason):
            return "Save failed: \(reason)"
        }
    }
}
