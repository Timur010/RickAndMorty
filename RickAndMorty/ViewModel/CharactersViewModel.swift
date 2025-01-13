import Foundation
import SwiftUI

@MainActor
class CharactersViewModel: ObservableObject {
    @Published private(set) var characters: [Character] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    
    private var nextPageURL: String?
    private let apiService: APIServiceProtocol
    private let dataCache: DataCacheProtocol
    private let cacheKey = "characters_cache"
    private var isFetching: Bool = false
    
    var canLoadMorePages: Bool { nextPageURL != nil }
    
    init(apiService: APIServiceProtocol = APIService(),
         dataCache: DataCacheProtocol = DataCache.shared,
         loadInitialData: Bool = true) {
        self.apiService = apiService
        self.dataCache = dataCache
        if loadInitialData {
            Task { @MainActor in
                await loadCachedData()
                if self.characters.isEmpty {
                    await loadCharacters()
                }
            }
        }
    }
    
    func loadMoreCharactersIfNeeded(currentCharacter: Character) async {
        let shouldLoadMore = await MainActor.run {
            guard let lastCharacter = characters.last,
                  currentCharacter.id == lastCharacter.id,
                  canLoadMorePages,
                  !isLoading,
                  !isFetching
            else { return false }
            return true
        }
        
        if shouldLoadMore {
            await loadCharacters()
        }
    }
    
    func clearCacheAsync() async {
        guard !isLoading else { return }
        await dataCache.clearCacheAsync(for: cacheKey)
        characters = []
        nextPageURL = nil
        await loadCharacters()
    }
    
    func loadCachedData() async {
        if let cachedData: CachedCharacters = await dataCache.getDataAsync(for: cacheKey) {
            self.characters = cachedData.characters
            self.nextPageURL = cachedData.nextPageURL
        } else {
            await loadCharacters()
        }
    }
    
    func loadCharacters() async {
        isFetching = true
        isLoading = true
        
        do {
            let response = try await apiService.fetchCharacters(nextURL: nextPageURL)
            let newCharacters = response.results.filter { newCharacter in
                !characters.contains(where: { $0.id == newCharacter.id })
            }
            
            if !newCharacters.isEmpty {
                characters.append(contentsOf: newCharacters)
                nextPageURL = response.info.next
                
                let cachedData = CachedCharacters(
                    characters: characters,
                    nextPageURL: nextPageURL
                )
                await dataCache.cacheDataAsync(cachedData, for: cacheKey)
            }
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = APIError.unknownError.localizedDescription
        }
        
        isFetching = false
        isLoading = false
    }
}


struct CachedCharacters: Codable {
    let characters: [Character]
    let nextPageURL: String?
}
