//
//  TextStyle.swift
//  RickAndMorty
//
//  Created by Timur Kadiev on 11.01.2025.
//

import SwiftUI

struct LargeTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 31, weight: .bold, design: .rounded))
            .foregroundColor(Color.ramBlack)
    }
}

struct TitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 21, weight: .regular, design: .rounded))
            .foregroundColor(Color.ramBlack)
    }
}

struct RegularTextStyle: ViewModifier {
    let textColor: Color
    
    init(color: Color = .ramBlack) {
        self.textColor = color
    }
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14, weight: .regular, design: .rounded))
            .foregroundColor(textColor)
    }
}
