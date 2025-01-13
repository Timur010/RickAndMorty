import SwiftUI

class ImageLoadingService {
    static let shared = ImageLoadingService()
    private init() {}
    
    func loadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        ImageCache.shared.getImage(for: url) { cachedImage in
            if let image = cachedImage {
                completion(image)
            } else {
                self.downloadImage(from: url, completion: completion)
            }
        }
    }
    
    private func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let downloadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    ImageCache.shared.cacheImage(downloadedImage, for: urlString)
                    completion(downloadedImage)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
}
