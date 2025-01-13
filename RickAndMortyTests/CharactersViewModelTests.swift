import XCTest
@testable import RickAndMorty

@MainActor
final class CharactersViewModelTests: XCTestCase {
    
    var viewModel: CharactersViewModel!
    var mockAPIService: MockAPIService!
    var mockDataCache: MockDataCache!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        mockDataCache = MockDataCache()
        // Initialize with loadInitialData set to false for tests
        viewModel = CharactersViewModel(apiService: mockAPIService, dataCache: mockDataCache, loadInitialData: false)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAPIService = nil
        mockDataCache = nil
        super.tearDown()
    }
    
    func testInitialLoadWithNoCache() async {
        let character = Character(id: 1, name: "Rick Sanchez", status: "Alive", species: "Human", type: "", gender: "Male", origin: LocationInfo(name: "Earth", url: ""), location: LocationInfo(name: "Earth", url: ""), image: "", episode: [], url: "", created: "")
        let pageInfo = PageInfo(count: 1, pages: 1, next: nil, prev: nil)
        let response = CharacterResponse(info: pageInfo, results: [character])
        mockAPIService.mockResponse = response
        
        await viewModel.loadCharacters()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.characters.count, 1)
        XCTAssertEqual(viewModel.characters.first?.name, "Rick Sanchez")
        XCTAssertFalse(viewModel.canLoadMorePages)
        
        let cachedData: CachedCharacters? = await mockDataCache.getDataAsync(for: "characters_cache")
        XCTAssertNotNil(cachedData)
        XCTAssertEqual(cachedData?.characters.count, 1)
    }
    
    func testInitialLoadWithCache() async {
        let cachedCharacter = Character(id: 2, name: "Morty Smith", status: "Alive", species: "Human", type: "", gender: "Male", origin: LocationInfo(name: "Earth", url: ""), location: LocationInfo(name: "Earth", url: ""), image: "", episode: [], url: "", created: "")
        let cachedData = CachedCharacters(characters: [cachedCharacter], nextPageURL: "https://api.example.com/characters?page=2")
        await mockDataCache.cacheDataAsync(cachedData, for: "characters_cache")
        
        await viewModel.loadCachedData()
        
        XCTAssertEqual(viewModel.characters.count, 1)
        XCTAssertEqual(viewModel.characters.first?.name, "Morty Smith")
        XCTAssertTrue(viewModel.canLoadMorePages)
        
        XCTAssertEqual(mockAPIService.fetchCallCount, 0)
    }
    
    func testLoadCharactersWithAPIError() async {
        mockAPIService.shouldReturnError = true
        
        await viewModel.loadCharacters()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, APIError.unknownError.localizedDescription)
        XCTAssertTrue(viewModel.characters.isEmpty)
    }
    
    func testLoadMoreCharactersIfNeeded() async {
        let firstCharacter = Character(id: 1, name: "Rick Sanchez", status: "Alive", species: "Human", type: "", gender: "Male", origin: LocationInfo(name: "Earth", url: ""), location: LocationInfo(name: "Earth", url: ""), image: "", episode: [], url: "", created: "")
        let pageInfo1 = PageInfo(count: 2, pages: 2, next: "https://api.example.com/characters?page=2", prev: nil)
        let response1 = CharacterResponse(info: pageInfo1, results: [firstCharacter])
        mockAPIService.mockResponse = response1
        
        await viewModel.loadCharacters()
        
        let secondCharacter = Character(id: 2, name: "Morty Smith", status: "Alive", species: "Human", type: "", gender: "Male", origin: LocationInfo(name: "Earth", url: ""), location: LocationInfo(name: "Earth", url: ""), image: "", episode: [], url: "", created: "")
        let pageInfo2 = PageInfo(count: 2, pages: 2, next: nil, prev: "https://api.example.com/characters?page=1")
        let response2 = CharacterResponse(info: pageInfo2, results: [secondCharacter])
        mockAPIService.mockResponse = response2
        
        await viewModel.loadMoreCharactersIfNeeded(currentCharacter: firstCharacter)
        
        XCTAssertEqual(viewModel.characters.count, 2)
        XCTAssertEqual(viewModel.characters.last?.name, "Morty Smith")
        XCTAssertFalse(viewModel.canLoadMorePages)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testClearCache() async {
        let initialCharacter = Character(id: 1, name: "Rick Sanchez", status: "Alive", species: "Human", type: "", gender: "Male", origin: LocationInfo(name: "Earth", url: ""), location: LocationInfo(name: "Earth", url: ""), image: "", episode: [], url: "", created: "")
        let cachedData = CachedCharacters(characters: [initialCharacter], nextPageURL: nil)
        await mockDataCache.cacheDataAsync(cachedData, for: "characters_cache")
        
        let newCharacter = Character(id: 2, name: "Morty Smith", status: "Alive", species: "Human", type: "", gender: "Male", origin: LocationInfo(name: "Earth", url: ""), location: LocationInfo(name: "Earth", url: ""), image: "", episode: [], url: "", created: "")
        let response = CharacterResponse(info: PageInfo(count: 1, pages: 1, next: nil, prev: nil), results: [newCharacter])
        mockAPIService.mockResponse = response
        
        await viewModel.clearCacheAsync()
        
        XCTAssertEqual(viewModel.characters.count, 1)
        XCTAssertEqual(viewModel.characters.first?.name, "Morty Smith")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.canLoadMorePages)
    }
}

class MockAPIService: APIServiceProtocol {
    var shouldReturnError = false
    var mockResponse: CharacterResponse?
    private(set) var fetchCallCount = 0
    
    func fetchCharacters(nextURL: String?) async throws -> CharacterResponse {
        fetchCallCount += 1
        if shouldReturnError {
            throw MockAPIError.failedFetching
        }
        guard let response = mockResponse else {
            throw MockAPIError.failedFetching
        }
        return response
    }
}

class MockDataCache: DataCacheProtocol {
    var cachedData: [String: Data] = [:]
    
    func getDataAsync<T: Codable>(for key: String) async -> T? {
        guard let data = cachedData[key] else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    func cacheDataAsync<T: Codable>(_ item: T, for key: String) async {
        if let encoded = try? JSONEncoder().encode(item) {
            cachedData[key] = encoded
        }
    }
    
    func clearCacheAsync(for key: String) async {
        cachedData.removeValue(forKey: key)
    }
    
    func clearAllCacheAsync() async {
        cachedData.removeAll()
    }
}

enum MockAPIError: Error, LocalizedError {
    case failedFetching
    
    var errorDescription: String? {
        switch self {
        case .failedFetching:
            return "Произошла неизвестная ошибка."
        }
    }
}
