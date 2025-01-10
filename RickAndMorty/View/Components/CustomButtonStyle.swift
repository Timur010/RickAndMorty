//
//  CustomButtonStyle.swift
//  RickAndMorty
//
//  Created by Timur Kadiev on 10.01.2025.
//

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
