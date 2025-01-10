//
//  CharactersViewModel.swift
//  RickAndMorty
//
//  Created by Timur Kadiev on 09.01.2025.
//

import Foundation
//import Combine

class CharactersViewModel: ObservableObject {
    @Published var characters: [Character] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var currentPage = 1
    
    init() {
        loadCharacters()
    }

    func loadCharacters() {
        isLoading = true
        errorMessage = nil

        APIService.shared.fetchCharacters(page: currentPage) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.characters.append(contentsOf: response.results)
                    self?.currentPage += 1
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
