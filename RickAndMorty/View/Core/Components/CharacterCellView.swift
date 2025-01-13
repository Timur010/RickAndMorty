import SwiftUI

struct CharacterCellView: View {
    let character: Character
    
    private var characterStatus: CharacterStatus {
        CharacterStatus(rawValue: character.status) ?? .unknown
    }
    
    var body: some View {
        HStack {
            RemoteImageView(
                imageURL: character.image,
                saturation: characterStatus.imageSaturation
            )
            .frame(width: UIScreen.main.bounds.width * 0.28)
            
            VStack(alignment: .leading, spacing: 5) {
                CharacterInfoView(
                    character: character,
                    status: characterStatus
                )
                
                WatchEpisodesButton(imageName: "play", title: "Watch episodes") {
                }
                
                LocationView(locationName: character.origin.name)
            }
        }
        .padding(.horizontal, 24)
    }
}
