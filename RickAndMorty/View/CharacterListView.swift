// CharacterListView.swift
// RickAndMorty
//
// Created by Timur Kadiev on 09.01.2025.
//

import SwiftUI

struct CharacterListView: View {
    @EnvironmentObject var viewModel: CharactersViewModel

    var body: some View {
            List {
                ForEach(viewModel.characters) { character in
                    CharacterCellView(character: character)
                        .onAppear {
                            if character.id == viewModel.characters.last?.id && viewModel.canLoadMorePages {
                                Task {
                                    await viewModel.loadCharacters()
                                }
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 32, trailing: 24)) // Убрать стандартные отступы
                }

                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                }

                if let errorMessage = viewModel.errorMessage {
                    HStack {
                        Spacer()
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding()
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(PlainListStyle())
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .refreshable {
                await viewModel.clearCacheAsync()
            }
        }
    }

