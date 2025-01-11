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
        ScrollView() {
            LazyVStack(spacing: 32) {
                ForEach(viewModel.characters, id: \.id) { character in
                    CharacterCellView(character: character)
                        .onAppear {
                            if character.id == viewModel.characters.last?.id && viewModel.canLoadMorePages {
                                viewModel.loadCharacters()
                            }
                        }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(height: 50)
                }
                
                if viewModel.errorMessage != nil {
                    Text(viewModel.errorMessage ?? "")
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 24)
        }
    }
}
