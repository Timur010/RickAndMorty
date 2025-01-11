//
//  CharactersViewModel.swift
//  RickAndMorty
//
//  Created by Timur Kadiev on 09.01.2025.
import Foundation

class CharactersViewModel: ObservableObject {
    @Published var characters: [Character] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var nextPageURL: String?
    private let apiService: APIServiceProtocol
    private let cacheKey = "characters_cache"
    private var isFetching = false
    
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
        
        DataCache.shared.getData(for: cacheKey) { [weak self] (cachedData: CachedCharacters?) in
            DispatchQueue.main.async {
                if let cachedData = cachedData {
                    self?.characters = cachedData.characters
                    self?.nextPageURL = cachedData.nextPageURL
                } else {
                    self?.loadCharacters()
                }
            }
        }
    }
    
    func loadCharacters() {
        guard !isLoading, !isFetching else { return }
        isFetching = true
        isLoading = true
        errorMessage = nil

        apiService.fetchCharacters(endpoint: nextPageURL) { [weak self] result in
            DispatchQueue.main.async {
                self?.isFetching = false
                self?.isLoading = false
                switch result {
                case .success(let response):
                    let newCharacters = response.results.filter { newCharacter in
                        !(self?.characters.contains(where: { $0.id == newCharacter.id }) ?? false)
                    }
                    self?.characters.append(contentsOf: newCharacters)
                    self?.nextPageURL = response.info.next

                    if let characters = self?.characters {
                        let cachedData = CachedCharacters(characters: characters, nextPageURL: self?.nextPageURL)
                        DataCache.shared.cacheData(cachedData, for: self?.cacheKey ?? "")
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    
    var canLoadMorePages: Bool {
        return nextPageURL != nil
    }
    
    func clearCache() {
        guard !isLoading else { return }
        DataCache.shared.clearCache()
        characters = []
        nextPageURL = nil
        loadCharacters()
    }
}


struct CachedCharacters: Codable {
    let characters: [Character]
    let nextPageURL: String?
}
