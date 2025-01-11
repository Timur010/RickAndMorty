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
    
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
        
        DataCache.shared.getData(for: cacheKey) { [weak self] (characters: [Character]?) in
            if let characters = characters {
                DispatchQueue.main.async {
                    self?.characters = characters
                }
            }
            self?.loadCharacters()
        }
    }
    
    func loadCharacters() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        apiService.fetchCharacters(urlString: nextPageURL) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.characters.append(contentsOf: response.results)
                    self?.nextPageURL = response.info.next
                    
                    if let characters = self?.characters {
                        DataCache.shared.cacheData(characters, for: self?.cacheKey ?? "")
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
        DataCache.shared.clearCache()
        characters = []
        nextPageURL = nil
        loadCharacters()
    }
}
