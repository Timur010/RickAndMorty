import Foundation

/// Определяет контракт для операций API сервиса
protocol APIServiceProtocol {
    /// Загружает персонажей из API
    /// - Parameter nextURL: Опциональный URL для следующей страницы результатов
    /// - Returns: Ответ с персонажами, содержащий результаты и информацию о пагинации
    /// - Throws: APIError в случае ошибки запроса
    func fetchCharacters(nextURL: String?) async throws -> CharacterResponse
}
