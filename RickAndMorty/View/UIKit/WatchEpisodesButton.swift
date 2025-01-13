import SwiftUI

struct WatchEpisodesButton: View {
    let imageName: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(imageName)
                Text(title)
                    .regularTextStyle(color: .ramOrange)
            }
            .padding(0)
        }
        .buttonStyle(CustomButtonStyle(
            backgroundColor: .ramOrange.opacity(0.1),
            foregroundColor: .ramOrange
        ))
        .tint(.orange)
    }
}
