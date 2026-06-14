import Foundation

// MARK: - AppError

enum AppError: LocalizedError {

    case coreDataError(Error)
    case photoNotFound(id: Int)
    case saveFailed(reason: String)

    var errorDescription: String? {
        switch self {
        case .coreDataError(let underlying):
            return "Core Data error: \(underlying.localizedDescription)"
        case .photoNotFound(let id):
            return "Photo with id \(id) not found."
        case .saveFailed(let reason):
            return "Save failed: \(reason)"
        }
    }
}
