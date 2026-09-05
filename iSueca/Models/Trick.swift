import Foundation

struct PlayedCard: Identifiable, Codable, Equatable {
    var id: UUID { card.id }
    let position: PlayerPosition
    let card: Card
}

struct Trick: Codable {
    var cardsPlayed: [PlayedCard] = []
    var leadSuit: Suit?
    var winner: PlayerPosition?

    var isComplete: Bool { cardsPlayed.count == 4 }

    var points: Int { cardsPlayed.reduce(0) { $0 + $1.card.pointValue } }

    mutating func play(_ card: Card, by position: PlayerPosition) {
        if cardsPlayed.isEmpty {
            leadSuit = card.suit
        }
        cardsPlayed.append(PlayedCard(position: position, card: card))
    }
}
