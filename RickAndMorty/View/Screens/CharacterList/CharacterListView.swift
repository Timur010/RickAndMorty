import SwiftUI

struct CharacterListView: View {
    @EnvironmentObject var viewModel: CharactersViewModel

    var body: some View {
        List {
            charactersSection
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .listStyle(PlainListStyle())
        .errorAlert(errorMessage: $viewModel.errorMessage)
        .refreshable {
            await viewModel.clearCacheAsync()
        }
    }
}

extension CharacterListView {
    private var charactersSection: some View {
        ForEach(viewModel.characters) { character in
            CharacterCellView(character: character)
                .onAppear {
                    if shouldLoadMoreCharacters(for: character) {
                        Task {
                            await viewModel.loadCharacters()
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 32, trailing: 24))
        }
    }
    
    private func shouldLoadMoreCharacters(for character: Character) -> Bool {
        character.id == viewModel.characters.last?.id && viewModel.canLoadMorePages
    }
}
