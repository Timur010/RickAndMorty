//
//  RemoteImageView.swift
//  RickAndMorty
//
//  Created by Timur Kadiev on 11.01.2025.
//

import SwiftUI

struct RemoteImageView: View {
    let imageURL: String
    var saturation: Double = 1.0
    var cornerRadius: CGFloat = 40
    
    var body: some View {
        GeometryReader { geometry in
            AsyncImage(url: URL(string: imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .saturation(saturation) 
            .frame(width: geometry.size.width, height: geometry.size.width)
            .cornerRadius(cornerRadius)
            .clipped()
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

