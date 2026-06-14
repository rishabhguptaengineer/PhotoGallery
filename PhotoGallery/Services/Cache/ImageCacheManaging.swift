import UIKit

protocol ImageCacheManaging {
    func image(for url: URL) -> UIImage?
    func setImage(_ image: UIImage, for url: URL)
    func clearCache()
}
