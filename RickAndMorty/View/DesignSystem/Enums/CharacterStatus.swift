import SwiftUI

enum CharacterStatus: String {
    case alive = "Alive"
    case dead = "Dead"
    case unknown = "Unknown"
    
    var textColor: Color {
        switch self {
        case .alive: return .ramGreen
        case .dead: return .ramRed
        case .unknown: return .ramGrey
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .alive: return .lightGreen
        case .dead: return .lightPeach
        case .unknown: return .lightGrey
        }
    }
    var imageSaturation: Double {
        switch self {
        case .unknown: return 0
        default: return 1
        }
    }
}
