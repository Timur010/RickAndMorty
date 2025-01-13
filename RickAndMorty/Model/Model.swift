import Foundation

struct CharacterResponse: Codable {
    let info: PageInfo
    let results: [Character]
}

struct PageInfo: Codable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}

struct Character: Codable, Identifiable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: LocationInfo
    let location: LocationInfo
    let image: String
    let episode: [String]
    let url: String
    let created: String
}

struct LocationInfo: Codable {
    let name: String
    let url: String
}
