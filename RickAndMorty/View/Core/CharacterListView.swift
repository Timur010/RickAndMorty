import SwiftUI

struct CharacterListView: View {
    @EnvironmentObject var viewModel: CharactersViewModel
    
    var body: some View {
        ScrollView {
            charactersSection
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .errorAlert(errorMessage: $viewModel.errorMessage)
        .refreshable {
            await viewModel.clearCacheAsync()
        }
    }
}

extension CharacterListView {
    private var charactersSection: some View {
        LazyVStack(spacing: 32) {
            ForEach(viewModel.characters, id: \.id) { character in
                CharacterCellView(character: character)
                    .onAppear {
                        if shouldLoadMoreCharacters(for: character) {
                            Task {
                                await viewModel.loadCharacters()
                            }
                        }
                    }
            }
        }
    }
    
    private func shouldLoadMoreCharacters(for character: Character) -> Bool {
        character.id == viewModel.characters.last?.id && viewModel.canLoadMorePages
    }
}
