//
//  APIServise.swift
//  RickAndMorty
//
//  Created by Timur Kadiev on 09.01.2025.
//

import Foundation
import Alamofire

protocol APIServiceProtocol {
    func fetchCharacters(urlString: String?, completion: @escaping (Result<CharacterResponse, Error>) -> Void)
}

class APIService: APIServiceProtocol {
    private let baseURL = "https://rickandmortyapi.com/api/character"
    
    func fetchCharacters(urlString: String? = nil, completion: @escaping (Result<CharacterResponse, Error>) -> Void) {
        let urlToUse = urlString ?? baseURL
        
        AF.request(urlToUse)
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

//enum NetworkError: Error {
//    case invalidURL
//    case noData
//}
