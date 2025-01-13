import Alamofire
import Foundation

/// Сервис, ответственный за выполнение API запросов
final class APIService: APIServiceProtocol {
    private let session: Session
    private let baseURL: String
    private let reachabilityManager: ReachabilityProtocol?
    private let decoder: JSONDecoder
    
    init(baseURL: String = "https://rickandmortyapi.com/api/character",
         session: Session = .default,
         reachabilityManager: ReachabilityProtocol? = NetworkReachabilityManager(),
         decoder: JSONDecoder = JSONDecoder()) {
        self.baseURL = baseURL
        self.session = session
        self.reachabilityManager = reachabilityManager
        self.decoder = decoder
        
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    func fetchCharacters(nextURL: String? = nil) async throws -> CharacterResponse {
        guard reachabilityManager?.isReachable == true else {
            throw APIError.noInternetConnection
        }
        
        let urlToUse = nextURL ?? baseURL
        
        do {
            let request = session.request(urlToUse)
                .validate()
                .serializingDecodable(CharacterResponse.self, decoder: decoder)
            
            let response = try await request.value
            return response
        } catch let error as AFError {
            throw mapAFErrorToAPIError(error)
        } catch {
            throw APIError.unknownError
        }
    }
    
    private func mapAFErrorToAPIError(_ error: AFError) -> APIError {
            switch error {
            case .responseSerializationFailed:
                return .decodingError(error.localizedDescription)
            case .responseValidationFailed(let reason):
                switch reason {
                case .unacceptableStatusCode(let code):
                    return .serverError(code)
                default:
                    return .unknownError
                }
            default:
                return .unknownError
            }
        }
}
