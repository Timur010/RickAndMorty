//
//  CharacterCellView.swift
//  RickAndMorty
//
//  Created by Timur Kadiev on 09.01.2025.
//
import SwiftUI

struct CharacterCellView: View {
    let character: Character

    private var characterStatus: CharacterStatus {
            CharacterStatus(rawValue: character.status) ?? .unknown
        }
    
    var body: some View {
        HStack {
            RemoteImageView(imageURL: character.image, saturation: characterStatus.imageSaturation)
                .frame(width: UIScreen.main.bounds.width * 0.28)

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(character.name)
                        .titleStyle()
                    
                    Spacer()

                    StatusBadgeView(status: characterStatus)
                }
               
                Text("\(character.species), \(character.gender)")
                    .regularTextStyle(color: .ramBlack)
                
                Button(action: {
                    
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                            .scaleEffect(0.7)
                        Text("Watch episodes")
                            .regularTextStyle(color: .ramOrange)
                    }
                }
                .buttonStyle(CustomButtonStyle(backgroundColor: .ramOrange.opacity(0.1), foregroundColor: .ramOrange))
                .tint(.orange)

                HStack {
                    Image(systemName: "location")
                        .foregroundColor(.gray)
                    Text(character.origin.name)
                        .regularTextStyle(color: .ramGrey)
                }
            }
        }
        .padding()
    }
}
