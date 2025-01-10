//
//  CharacterListView.swift
//  RickAndMorty
//
//  Created by Timur Kadiev on 09.01.2025.
//

import SwiftUI

struct CharacterListView: View {
    @EnvironmentObject var viewModel: CharactersViewModel

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.characters, id: \.name) { character in
                    CharacterCellView(character: character)
                }
            }
        }
    }
}
