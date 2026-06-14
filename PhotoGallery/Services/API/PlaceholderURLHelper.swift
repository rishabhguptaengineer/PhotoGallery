import Foundation

// MARK: - PlaceholderURLHelper

/// Centralises the URL rewriting logic for placeholder image services.
/// The JSONPlaceholder API references `via.placeholder.com`, which has been
/// defunct since 2024. All image URLs are rewritten here to use `placehold.co`.
enum PlaceholderURLHelper {

    /// Rewrites a `via.placeholder.com` URL to a working `placehold.co` URL,
    /// enforcing the `/<bg>/<fg>.png` suffix that the service requires.
    nonisolated static func correctedURL(from urlString: String) -> URL? {
        var corrected = urlString.replacingOccurrences(of: "via.placeholder.com", with: "placehold.co")
        if !corrected.hasSuffix(".png") {
            corrected += "/ffffff.png"
        }
        return URL(string: corrected)
    }
}
