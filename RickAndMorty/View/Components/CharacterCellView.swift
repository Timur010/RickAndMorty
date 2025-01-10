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
                        .font(.headline)
                    
                    Spacer()

                    
                    Text(character.status.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color.ramGreen)
                        .padding(5)
                        .background(
                            Capsule()
                                .fill(Color.lightGreen)
                        )
                }
               

                Text("\(character.species), \(character.gender)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                            .scaleEffect(0.7)
                        Text("Watch episodes")
                            .font(.system(size: 14))
                    }
                }
                .buttonStyle(CustomButtonStyle(backgroundColor: .ramOrange.opacity(0.1), foregroundColor: .ramOrange))
                .tint(.orange)

                HStack {
                    Image(systemName: "location")
                        .foregroundColor(.gray)
                    Text(character.origin.name)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
    }
}


import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    var backgroundColor: Color = .blue
    var foregroundColor: Color = .white
    var cornerRadius: CGFloat = 17
    var padding: CGFloat = 9

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(padding)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
