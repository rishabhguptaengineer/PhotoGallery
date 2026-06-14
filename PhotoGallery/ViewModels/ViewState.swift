import Foundation

// MARK: - ViewState

enum ViewState: Equatable {
    case idle
    case loading
    case loaded
    case empty
    case error(String)

    static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.loaded, .loaded):
            return true
        case (.empty, .empty):
            return true
        case (.error(let lMsg), .error(let rMsg)):
            return lMsg == rMsg
        default:
            return false
        }
    }
}
