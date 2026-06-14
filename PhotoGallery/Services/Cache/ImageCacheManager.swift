import UIKit

final class ImageCacheManager: ImageCacheManaging {

    static let shared = ImageCacheManager()
    private init() {}

    private let cache = NSCache<NSURL, UIImage>()

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func setImage(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }

    func clearCache() {
        cache.removeAllObjects()
    }
}
