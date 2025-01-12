
import Foundation

@MainActor
class CharactersViewModel: ObservableObject {
    @Published var characters: [Character] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    var nextPageURL: String?
    private let apiService: APIServiceProtocol
    private let dataCache: DataCacheProtocol  // Использование протокола
    private let cacheKey = "characters_cache"
    private var isFetching: Bool = false

    init(apiService: APIServiceProtocol = APIService(), dataCache: DataCacheProtocol = DataCache.shared) {
        self.apiService = apiService
        self.dataCache = dataCache
        Task {
            await loadCachedData()
        }
    }
        
    func loadMoreCharactersIfNeeded(currentCharacter: Character) {
        guard let lastCharacter = characters.last else { return }
        if currentCharacter.id == lastCharacter.id && canLoadMorePages {
            Task {
                await loadCharacters()
            }
        }
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
        guard !isLoading, !isFetching else { return }
        isFetching = true
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.fetchCharacters(nextURL: nextPageURL)
            let newCharacters = response.results.filter { newCharacter in
                !self.characters.contains(where: { $0.id == newCharacter.id })
            }
            characters.append(contentsOf: newCharacters)
            nextPageURL = response.info.next

            let cachedData = CachedCharacters(characters: characters, nextPageURL: nextPageURL)
            await dataCache.cacheDataAsync(cachedData, for: cacheKey)
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = APIError.unknownError.localizedDescription
        }
        
        isFetching = false
        isLoading = false
    }

    func clearCacheAsync() async {
        guard !isLoading else { return }
        await dataCache.clearCacheAsync(for: cacheKey)
        characters = []
        nextPageURL = nil
        await loadCharacters()
    }

    private func getCachedData<T: Codable>(for key: String) async -> T? {
        return await dataCache.getDataAsync(for: key)
    }

    var canLoadMorePages: Bool {
        return nextPageURL != nil
    }
}

struct CachedCharacters: Codable {
    let characters: [Character]
    let nextPageURL: String?
}
