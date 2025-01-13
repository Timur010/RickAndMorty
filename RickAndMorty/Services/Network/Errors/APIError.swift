import Foundation

/// Представляет возможные ошибки API, которые могут возникнуть во время сетевых операций
enum APIError: Error, Equatable {
    case decodingError(String)
    case networkError(String)
    case serverError(Int)
    case noInternetConnection
    case unknownError
    
    var localizedDescription: String {
        switch self {
        case .decodingError:
            return "Ошибка декодирования"
        case .networkError:
            return "Сетевая ошибка"
        case .serverError(let code):
            return "Ошибка сервера: \(code)"
        case .noInternetConnection:
            return "Отсутствует интернет-соединение."
        case .unknownError:
            return "Произошла неизвестная ошибка"
        }
    }
    
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.decodingError(let lm), .decodingError(let rm)): return lm == rm
        case (.networkError(let lm), .networkError(let rm)): return lm == rm
        case (.serverError(let lc), .serverError(let rc)): return lc == rc
        case (.noInternetConnection, .noInternetConnection): return true
        case (.unknownError, .unknownError): return true
        default: return false
        }
    }
}
