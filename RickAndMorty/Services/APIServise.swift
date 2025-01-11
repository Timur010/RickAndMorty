//
//  APIServise.swift
//  RickAndMorty
//
//  Created by Timur Kadiev on 09.01.2025.
//

import Foundation
import Alamofire
import Foundation
import Alamofire

protocol APIServiceProtocol {
    func fetchCharacters(endpoint: String?, completion: @escaping (Result<CharacterResponse, Error>) -> Void)
}

enum APIError: Error {
    case decodingError
    case requestFailed(AFError)
    case unknownError
    
    var localizedDescription: String {
        switch self {
        case .decodingError:
            return "Failed to decode the response."
        case .requestFailed(let afError):
            return "Request failed: \(afError.localizedDescription)"
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}

class APIService: APIServiceProtocol {
    private let session: Session
    private let baseURL: String
    
    init(baseURL: String = "https://rickandmortyapi.com/api/character", session: Session = .default) {
        self.baseURL = baseURL
        self.session = session
    }
    
    func fetchCharacters(endpoint: String? = nil, completion: @escaping (Result<CharacterResponse, Error>) -> Void) {
        guard NetworkReachabilityManager()?.isReachable == true else {
            completion(.failure(APIError.requestFailed(AFError.explicitlyCancelled)))
            return
        }
        
        let urlToUse = endpoint.map { "\($0)" } ?? baseURL
        
        session.request(urlToUse)
            .validate()
            .responseDecodable(of: CharacterResponse.self) { response in
                switch response.result {
                case .success(let characterResponse):
                    completion(.success(characterResponse))
                case .failure(let error):
                    if let afError = error.asAFError, afError.isResponseSerializationError {
                        completion(.failure(APIError.decodingError))
                    } else {
                        completion(.failure(APIError.requestFailed(error)))
                    }
                }
            }
    }
}
