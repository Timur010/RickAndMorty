//
//  APIServise.swift
//  RickAndMorty
//
//  Created by Timur Kadiev on 09.01.2025.
//

import Foundation
import Alamofire

protocol APIServiceProtocol {
    func fetchCharacters(page: Int, completion: @escaping (Result<CharacterResponse, Error>) -> Void)
}

class APIService: APIServiceProtocol {
    
    init() {}

    func fetchCharacters(page: Int = 1, completion: @escaping (Result<CharacterResponse, Error>) -> Void) {
        let url = "https://rickandmortyapi.com/api/character?page=\(page)"
        
        AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: CharacterResponse.self) { response in
                switch response.result {
                case .success(let characterResponse):
                    completion(.success(characterResponse))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
