//import XCTest
//@testable import RickAndMorty
//
//@MainActor
//final class CharactersViewModelTests: XCTestCase {
//    
//    var viewModel: CharactersViewModel!
//    var mockAPIService: MockAPIService!
//    var mockDataCache: MockDataCache!
//    
//    override func setUp() {
//        super.setUp()
//        mockAPIService = MockAPIService()
//        mockDataCache = MockDataCache()
//        viewModel = CharactersViewModel(apiService: mockAPIService, dataCache: mockDataCache)
//    }
//    
//    override func tearDown() {
//        viewModel = nil
//        mockAPIService = nil
//        mockDataCache = nil
//        super.tearDown()
//    }
//    
//    func testInitialLoadWithNoCache() async {
//        // Подготовка: API возвращает успешный ответ
//        let character = Character(id: 1, name: "Rick Sanchez", status: "Alive", species: "Human", type: "", gender: "Male", origin: LocationInfo(name: "Earth", url: ""), location: LocationInfo(name: "Earth", url: ""), image: "", episode: [], url: "", created: "")
//        let pageInfo = PageInfo(count: 1, pages: 1, next: nil, prev: nil)
//        let response = CharacterResponse(info: pageInfo, results: [character])
//        mockAPIService.mockResponse = response
//        
//        // Действие
//        await viewModel.loadCharacters()
//        
//        // Проверки
//        XCTAssertFalse(viewModel.isLoading)
//        XCTAssertNil(viewModel.errorMessage)
//        XCTAssertEqual(viewModel.characters.count, 1)
//        XCTAssertEqual(viewModel.characters.first?.name, "Rick Sanchez")
//        XCTAssertNil(viewModel.nextPageURL)
//        
//        // Проверка кэширования
//        let cachedData: CachedCharacters? = await mockDataCache.getDataAsync(for: "characters_cache")
//        XCTAssertNotNil(cachedData)
//        XCTAssertEqual(cachedData?.characters.count, 1)
//    }
//    
//    func testInitialLoadWithCache() async {
//        // Подготовка: кэш содержит данные
//        let cachedCharacter = Character(id: 2, name: "Morty Smith", status: "Alive", species: "Human", type: "", gender: "Male", origin: LocationInfo(name: "Earth", url: ""), location: LocationInfo(name: "Earth", url: ""), image: "", episode: [], url: "", created: "")
//        let cachedData = CachedCharacters(characters: [cachedCharacter], nextPageURL: "https://api.example.com/characters?page=2")
//        await mockDataCache.cacheDataAsync(cachedData, for: "characters_cache")
//        
//        // Действие
//        await viewModel.loadCachedData()
//        
//        // Проверки
//        XCTAssertEqual(viewModel.characters.count, 1)
//        XCTAssertEqual(viewModel.characters.first?.name, "Morty Smith")
//        XCTAssertEqual(viewModel.nextPageURL, "https://api.example.com/characters?page=2")
//        
//        // API не должен быть вызван, так как данные есть в кэше
//        XCTAssertNil(mockAPIService.mockResponse)
//    }
//    
//    func testLoadCharactersWithAPIError() async {
//        // Подготовка: API возвращает ошибку
//        mockAPIService.shouldReturnError = true
//        
//        // Действие
//        await viewModel.loadCharacters()
//        
//        // Проверки
//        XCTAssertFalse(viewModel.isLoading)
//        XCTAssertNotNil(viewModel.errorMessage)
//        XCTAssertEqual(viewModel.errorMessage, MockAPIError.failedFetching.localizedDescription)
//        XCTAssertTrue(viewModel.characters.isEmpty)
//    }
//    
//    func testLoadMoreCharactersIfNeeded() async {
//        // Подготовка: первая загрузка с одной страницей
//        let firstCharacter = Character(id: 1, name: "Rick Sanchez", status: "Alive", species: "Human", type: "", gender: "Male", origin: LocationInfo(name: "Earth", url: ""), location: LocationInfo(name: "Earth", url: ""), image: "", episode: [], url: "", created: "")
//        let pageInfo1 = PageInfo(count: 2, pages: 2, next: "https://api.example.com/characters?page=2", prev: nil)
//        let response1 = CharacterResponse(info: pageInfo1, results: [firstCharacter])
//        mockAPIService.mockResponse = response1
//        
//        // Загружаем первую страницу
//        await viewModel.loadCharacters()
//        
//        // Проверяем загрузку первой страницы
//        XCTAssertEqual(viewModel.characters.count, 1)
//        XCTAssertEqual(viewModel.characters.first?.name, "Rick Sanchez")
//        XCTAssertEqual(viewModel.nextPageURL, "https://api.example.com/characters?page=2")
//        
//        // Подготовка: вторая страница
//        let secondCharacter = Character(id: 2, name: "Morty Smith", status: "Alive", species: "Human", type: "", gender: "Male", origin: LocationInfo(name: "Earth", url: ""), location: LocationInfo(name: "Earth", url: ""), image: "", episode: [], url: "", created: "")
//        let pageInfo2 = PageInfo(count: 2, pages: 2, next: nil, prev: "https://api.example.com/characters?page=1")
//        let response2 = CharacterResponse(info: pageInfo2, results: [secondCharacter])
//        mockAPIService.mockResponse = response2
//        
//        await viewModel.loadMoreCharactersIfNeeded(currentCharacter: firstCharacter)
//        
//        try? await Task.sleep(nanoseconds: 100_000_000)
//        
//        XCTAssertEqual(viewModel.characters.count, 2)
//        XCTAssertEqual(viewModel.characters.last?.name, "Morty Smith")
//        XCTAssertNil(viewModel.nextPageURL)
//        XCTAssertFalse(viewModel.isLoading)
//    }
//    
//    func testClearCacheAsync() async {
//        // Подготовка: кэш содержит данные
//        let cachedCharacter = Character(id: 3, name: "Summer Smith", status: "Alive", species: "Human", type: "", gender: "Female", origin: LocationInfo(name: "Earth", url: ""), location: LocationInfo(name: "Earth", url: ""), image: "", episode: [], url: "", created: "")
//        let cachedData = CachedCharacters(characters: [cachedCharacter], nextPageURL: nil)
//        await mockDataCache.cacheDataAsync(cachedData, for: "characters_cache")
//        
//        // Загрузка кэшированных данных
//        await viewModel.loadCachedData()
//        XCTAssertEqual(viewModel.characters.count, 1)
//        
//        // Подготовка: API возвращает новые данные после очистки кэша
//        let newCharacter = Character(id: 4, name: "Beth Smith", status: "Alive", species: "Human", type: "", gender: "Female", origin: LocationInfo(name: "Earth", url: ""), location: LocationInfo(name: "Earth", url: ""), image: "", episode: [], url: "", created: "")
//        let newPageInfo = PageInfo(count: 1, pages: 1, next: nil, prev: nil)
//        let newResponse = CharacterResponse(info: newPageInfo, results: [newCharacter])
//        mockAPIService.mockResponse = newResponse
//        
//        // Действие: очистка кэша
//        await viewModel.clearCacheAsync()
//        
//        // Проверки
//        XCTAssertEqual(viewModel.characters.count, 1)
//        XCTAssertEqual(viewModel.characters.first?.name, "Beth Smith")
//        
//        // Проверка, что кэш обновлен новыми данными
//        let cachedDataAfterClear: CachedCharacters? = await mockDataCache.getDataAsync(for: "characters_cache")
//        XCTAssertNotNil(cachedDataAfterClear)
//        XCTAssertEqual(cachedDataAfterClear?.characters.count, 1)
//        XCTAssertEqual(cachedDataAfterClear?.characters.first?.name, "Beth Smith")
//    }
//}
//
//class MockDataCache: DataCacheProtocol {
//    var cachedData: [String: Data] = [:]
//    
//    func getDataAsync<T: Codable>(for key: String) async -> T? {
//        guard let data = cachedData[key] else { return nil }
//        let decoder = JSONDecoder()
//        return try? decoder.decode(T.self, from: data)
//    }
//    
//    func cacheDataAsync<T: Codable>(_ item: T, for key: String) async {
//        let encoder = JSONEncoder()
//        if let encoded = try? encoder.encode(item) {
//            cachedData[key] = encoded
//        }
//    }
//    
//    func clearCacheAsync(for key: String) async {
//        cachedData.removeValue(forKey: key)
//    }
//    
//    func clearAllCacheAsync() async {
//        cachedData.removeAll()
//    }
//}
//
//enum MockAPIError: Error, LocalizedError {
//    case failedFetching
//    
//    var errorDescription: String? {
//        switch self {
//        case .failedFetching:
//            return "Произошла неизвестная ошибка."
//        }
//    }
//}
//
//class MockAPIService: APIServiceProtocol {
//    var shouldReturnError = false
//    var mockResponse: CharacterResponse?
//    
//    func fetchCharacters(nextURL: String?) async throws -> CharacterResponse {
//        if shouldReturnError {
//            throw MockAPIError.failedFetching
//        }
//        guard let response = mockResponse else {
//            throw MockAPIError.failedFetching
//        }
//        return response
//    }
//}
