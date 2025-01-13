import SwiftUI

struct CharacterInfoView: View {
    let character: Character
    let status: CharacterStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(character.name)
                    .titleStyle()
                
                Spacer()
                
                StatusBadgeView(status: status)
            }
            
            Text("\(character.species), \(character.gender)")
                .regularTextStyle(color: .ramBlack)
        }
    }
}
