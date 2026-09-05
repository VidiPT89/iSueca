import Foundation

final class GameState {
    var players: [PlayerPosition: Player]
    var trumpSuit: Suit
    var trumpCard: Card
    var currentTrick: Trick
    var completedTricks: [Trick] = []
    var teamAPoints: Int = 0
    var teamBPoints: Int = 0
    var currentPlayerTurn: PlayerPosition
    var dealerPosition: PlayerPosition
    var playedCardsHistory: [Card] = []

    init(players: [PlayerPosition: Player], trumpSuit: Suit, trumpCard: Card,
         dealerPosition: PlayerPosition, firstToPlay: PlayerPosition) {
        self.players = players
        self.trumpSuit = trumpSuit
        self.trumpCard = trumpCard
        self.currentTrick = Trick()
        self.dealerPosition = dealerPosition
        self.currentPlayerTurn = firstToPlay
    }

    func hand(for position: PlayerPosition) -> [Card] {
        players[position]?.hand ?? []
    }

    func remove(_ card: Card, from position: PlayerPosition) {
        players[position]?.hand.removeAll { $0.id == card.id }
    }
}
