// APIService.swift
// RickAndMorty
//
// Created by Timur Kadiev on 09.01.2025.
//

// swiftlint:disable line_length
import Alamofire
import Foundation

protocol APIServiceProtocol {
    func fetchCharacters(nextURL: String?) async throws -> CharacterResponse
}

protocol ReachabilityProtocol {
    var isReachable: Bool { get }
}

extension NetworkReachabilityManager: ReachabilityProtocol {}

enum APIError: Error, Equatable {
    case decodingError
    case requestFailed(AFError)
    case noInternetConnection
    case unknownError
    
    var localizedDescription: String {
        switch self {
        case .decodingError:
            return "Не удалось декодировать ответ."
        case .requestFailed(let afError):
            return "Запрос не удался: \(afError.localizedDescription)"
        case .noInternetConnection:
            return "Отсутствует интернет-соединение."
        case .unknownError:
            return "Произошла неизвестная ошибка."
        }
    }
    
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.decodingError, .decodingError),
            (.noInternetConnection, .noInternetConnection),
            (.unknownError, .unknownError):
            return true
        case (.requestFailed(let lhsError), .requestFailed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

class APIService: APIServiceProtocol {
    private let session: Session
    private let baseURL: String
    private let reachabilityManager: ReachabilityProtocol?
    
    init(baseURL: String = "https://rickandmortyapi.com/api/character",
         session: Session = .default,
         reachabilityManager: ReachabilityProtocol? = NetworkReachabilityManager()) {
        self.baseURL = baseURL
        self.session = session
        self.reachabilityManager = reachabilityManager
    }
    
    func fetchCharacters(nextURL: String? = nil) async throws -> CharacterResponse {
        guard reachabilityManager?.isReachable == true else {
            throw APIError.noInternetConnection
        }
        
        let urlToUse = nextURL ?? baseURL
        
        do {
            let response = try await session.request(urlToUse)
                .validate()
                .serializingDecodable(CharacterResponse.self)
                .value
            return response
        } catch let error as AFError {
            if error.isResponseSerializationError {
                throw APIError.decodingError
            } else if let underlyingError = error.underlyingError, !(underlyingError is AFError) {
                throw APIError.unknownError
            } else {
                throw APIError.requestFailed(error)
            }
        } catch {
            throw APIError.unknownError
        }
    }
}
