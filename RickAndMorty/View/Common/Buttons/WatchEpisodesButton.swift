import SwiftUI

struct WatchEpisodesButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image("play")
                Text("Watch episodes")
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
