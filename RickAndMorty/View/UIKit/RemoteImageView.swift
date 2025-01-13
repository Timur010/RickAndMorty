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
                        // Use ImageLoadingService instead of local functions
                        ImageLoadingService.shared.loadImage(from: imageURL) { loadedImage in
                            self.image = loadedImage
                        }
                    }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
