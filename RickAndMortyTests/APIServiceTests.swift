import XCTest
import Alamofire
@testable import RickAndMorty

final class APIServiceTests: XCTestCase {
    var apiService: APIService!
    var session: Session!
    var reachability: MockReachability!
    
    override func setUp() {
        super.setUp()
        
        // Настройка URLSession с MockURLProtocol
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = Session(configuration: configuration)
    }
    
    override func tearDown() {
        apiService = nil
        session = nil
        reachability = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
    
    func testFetchCharactersSuccess() async throws {
        let jsonString = """
        {
            "info": {
                "count": 2,
                "pages": 1,
                "next": null,
                "prev": null
            },
            "results": [
                {
                    "id": 1,
                    "name": "Rick Sanchez",
                    "status": "Alive",
                    "species": "Human",
                    "type": "",
                    "gender": "Male",
                    "origin": {
                        "name": "Earth",
                        "url": "https://rickandmortyapi.com/api/location/1"
                    },
                    "location": {
                        "name": "Earth",
                        "url": "https://rickandmortyapi.com/api/location/20"
                    },
                    "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
                    "episode": [
                        "https://rickandmortyapi.com/api/episode/1",
                        "https://rickandmortyapi.com/api/episode/2"
                    ],
                    "url": "https://rickandmortyapi.com/api/character/1",
                    "created": "2017-11-04T18:48:46.250Z"
                },
                {
                    "id": 2,
                    "name": "Morty Smith",
                    "status": "Alive",
                    "species": "Human",
                    "type": "",
                    "gender": "Male",
                    "origin": {
                        "name": "Earth",
                        "url": "https://rickandmortyapi.com/api/location/1"
                    },
                    "location": {
                        "name": "Earth",
                        "url": "https://rickandmortyapi.com/api/location/20"
                    },
                    "image": "https://rickandmortyapi.com/api/character/avatar/2.jpeg",
                    "episode": [
                        "https://rickandmortyapi.com/api/episode/1",
                        "https://rickandmortyapi.com/api/episode/2"
                    ],
                    "url": "https://rickandmortyapi.com/api/character/2",
                    "created": "2017-11-04T18:50:21.651Z"
                }
            ]
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, "https://rickandmortyapi.com/api/character")
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, data)
        }
        
        reachability = MockReachability(isReachable: true)
        
        apiService = APIService(session: session, reachabilityManager: reachability)
        
        let characterResponse = try await apiService.fetchCharacters()
        
        // Проверка результатов
        XCTAssertEqual(characterResponse.info.count, 2)
        XCTAssertEqual(characterResponse.results.count, 2)
        XCTAssertEqual(characterResponse.results[0].name, "Rick Sanchez")
        XCTAssertEqual(characterResponse.results[1].name, "Morty Smith")
    }
    
    func testFetchCharactersDecodingError() async {
        let jsonString = """
        {
            "results": []
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        // Настройка обработчика запросов
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, "https://rickandmortyapi.com/api/character")
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, data)
        }
        
        reachability = MockReachability(isReachable: true)
        
        apiService = APIService(session: session, reachabilityManager: reachability)
        
        do {
            _ = try await apiService.fetchCharacters()
            XCTFail("Ожидалась ошибка декодирования, но запрос прошёл успешно.")
        } catch let error as APIError {
            XCTAssertEqual(error, APIError.decodingError)
        } catch {
            XCTFail("Получена неожиданная ошибка: \(error)")
        }
    }
    
    func testFetchCharactersRequestFailed() async {
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, "https://rickandmortyapi.com/api/character")
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 500,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, Data())
        }
        
        reachability = MockReachability(isReachable: true)
        
        apiService = APIService(session: session, reachabilityManager: reachability)
        
        do {
            _ = try await apiService.fetchCharacters()
            XCTFail("Ожидалась ошибка запроса, но запрос прошёл успешно.")
        } catch let error as APIError {
            switch error {
            case .requestFailed(let afError):
                XCTAssertTrue(afError.isResponseValidationError)
            default:
                XCTFail("Ожидалась ошибка запроса, но получена другая ошибка: \(error)")
            }
        } catch {
            XCTFail("Получена неожиданная ошибка: \(error)")
        }
    }
    
    func testFetchCharactersNoInternetConnection() async {
        reachability = MockReachability(isReachable: false)
        
        apiService = APIService(session: session, reachabilityManager: reachability)
        
        do {
            _ = try await apiService.fetchCharacters()
            XCTFail("Ожидалась ошибка отсутствия интернета, но запрос прошёл успешно.")
        } catch let error as APIError {
            XCTAssertEqual(error, APIError.noInternetConnection)
        } catch {
            XCTFail("Получена неожиданная ошибка: \(error)")
        }
    }
    
    func testAPIErrorDecodingErrorLocalizedDescription() async {
        let jsonString = """
            {
                "results": []
            }
            """
        let data = jsonString.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, "https://rickandmortyapi.com/api/character")
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, data)
        }
        
        reachability = MockReachability(isReachable: true)
        
        apiService = APIService(session: session, reachabilityManager: reachability)
        
        do {
            _ = try await apiService.fetchCharacters()
            XCTFail("Ожидалась ошибка декодирования, но запрос прошёл успешно.")
        } catch let error as APIError {
            XCTAssertEqual(error, APIError.decodingError)
            XCTAssertEqual(error.localizedDescription, "Не удалось декодировать ответ.")
        } catch {
            XCTFail("Получена неожиданная ошибка: \(error)")
        }
    }
    
    func testAPIErrorNoInternetConnectionLocalizedDescription() async {
        reachability = MockReachability(isReachable: false)
        
        apiService = APIService(session: session, reachabilityManager: reachability)
        
        do {
            _ = try await apiService.fetchCharacters()
            XCTFail("Ожидалась ошибка отсутствия интернета, но запрос прошёл успешно.")
        } catch let error as APIError {
            XCTAssertEqual(error, APIError.noInternetConnection)
            XCTAssertEqual(error.localizedDescription, "Отсутствует интернет-соединение.")
        } catch {
            XCTFail("Получена неожиданная ошибка: \(error)")
        }
    }
    
    func testAPIErrorUnknownErrorLocalizedDescription() async {
        MockURLProtocol.requestHandler = { request in
            throw MockError.custom
        }
        
        reachability = MockReachability(isReachable: true)
        
        apiService = APIService(session: session, reachabilityManager: reachability)
        
        do {
            _ = try await apiService.fetchCharacters()
            XCTFail("Ожидалась неизвестная ошибка, но запрос прошёл успешно.")
        } catch let error as APIError {
            XCTAssertEqual(error, APIError.unknownError)
            XCTAssertEqual(error.localizedDescription, "Произошла неизвестная ошибка.")
        } catch {
            XCTFail("Получена неожиданная ошибка: \(error)")
        }
    }
    
    func testAPIErrorRequestFailedLocalizedDescription() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        
        reachability = MockReachability(isReachable: true)
        apiService = APIService(session: session, reachabilityManager: reachability)
        
        do {
            _ = try await apiService.fetchCharacters()
            XCTFail("Ожидалась ошибка запроса, но запрос прошёл успешно.")
        } catch let error as APIError {
            if case .requestFailed(let afError) = error {
                XCTAssertTrue(afError.isResponseValidationError)
                XCTAssertEqual(afError.responseCode, 500)
            } else {
                XCTFail("Ожидалась ошибка requestFailed, но получена другая ошибка: \(error)")
            }
        } catch {
            XCTFail("Получена неожиданная ошибка: \(error)")
        }
    }
}

import Foundation

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler не установлен.")
        }
        
        do {
            let (response, data) = try handler(request)
            
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}


import Alamofire

class MockReachability: ReachabilityProtocol {
    var isReachable: Bool
    
    init(isReachable: Bool) {
        self.isReachable = isReachable
    }
}

enum MockError: Error {
    case custom
}
