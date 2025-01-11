//
//  CharacterCellView.swift
//  RickAndMorty
//
//  Created by Timur Kadiev on 09.01.2025.
//
import SwiftUI

struct CharacterCellView: View {
    let character: Character

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: character.image)) { image in
                image.resizable()

            } placeholder: {
                ProgressView()
            }
            .saturation(1) 
            .frame(width: 120, height: 120)
            .cornerRadius(40)

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(character.name)
                        .titleStyle()
                    
                    Spacer()

                    Text(character.status.uppercased())
                        .regularTextStyle(color: .ramGreen)
                        .padding(5)
                        .background(
                            Capsule()
                                .fill(Color.lightGreen)
                        )
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
