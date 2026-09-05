import Foundation

enum PlayerPosition: Int, CaseIterable, Codable, Identifiable {
    case south = 0, west, north, east
    // South = human. South+North = Team A, West+East = Team B.

    var id: Int { rawValue }

    var next: PlayerPosition {
        PlayerPosition(rawValue: (rawValue + 1) % 4)!
    }

    var partner: PlayerPosition {
        switch self {
        case .south: return .north
        case .north: return .south
        case .west: return .east
        case .east: return .west
        }
    }

    var team: Team {
        switch self {
        case .south, .north: return .teamA
        case .west, .east: return .teamB
        }
    }

    var nameKey: String {
        switch self {
        case .south: return "player.you"
        case .north: return "player.partner"
        case .west: return "player.west"
        case .east: return "player.east"
        }
    }
}

enum Team: String, Codable {
    case teamA, teamB

    var nameKey: String {
        switch self {
        case .teamA: return "game.teamA"
        case .teamB: return "game.teamB"
        }
    }

    var opponent: Team { self == .teamA ? .teamB : .teamA }
}

struct Player: Identifiable, Codable {
    let id: UUID
    let position: PlayerPosition
    var hand: [Card]
    let isBot: Bool

    init(position: PlayerPosition, hand: [Card] = [], isBot: Bool) {
        self.id = UUID()
        self.position = position
        self.hand = hand
        self.isBot = isBot
    }
}
