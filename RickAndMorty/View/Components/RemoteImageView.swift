//
//  RemoteImageView.swift
//  RickAndMorty
//
//  Created by Timur Kadiev on 11.01.2025.
//

import SwiftUI

struct RemoteImageView: View {
    let imageURL: String
    var saturation: Double = 1.0
    var cornerRadius: CGFloat = 40
    
    @State private var image: UIImage?
    
    var body: some View {
        GeometryReader { geometry in
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .saturation(saturation)
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    .cornerRadius(cornerRadius)
                    .clipped()
            } else {
                ProgressView()
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    .onAppear {
                        loadImage()
                    }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func loadImage() {
        ImageCache.shared.getImage(for: imageURL) { cachedImage in
            if let image = cachedImage {
                self.image = image
            } else {
                downloadImage()
            }
        }
    }
    
    private func downloadImage() {
        guard let url = URL(string: imageURL) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let downloadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    ImageCache.shared.cacheImage(downloadedImage, for: imageURL)
                    self.image = downloadedImage
                }
            }
        }.resume()
    }
}
