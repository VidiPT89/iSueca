import Foundation

enum DealerService {
    struct DealResult {
        let players: [PlayerPosition: Player]
        let trumpSuit: Suit
        let trumpCard: Card
    }

    /// Deals 10 cards to each of the 4 seats and reveals the dealer's last card as trump.
    static func deal(dealer: PlayerPosition) -> DealResult {
        let deck = DeckBuilder.shuffledDeck()
        var hands: [PlayerPosition: [Card]] = [.south: [], .west: [], .north: [], .east: []]

        var seat = dealer.next
        var index = 0
        for _ in 0..<40 {
            hands[seat]?.append(deck[index])
            index += 1
            seat = seat.next
        }

        let trumpCard = hands[dealer]!.last!
        let trumpSuit = trumpCard.suit

        var players: [PlayerPosition: Player] = [:]
        for position in PlayerPosition.allCases {
            let sorted = sortForDisplay(hands[position] ?? [], trump: trumpSuit)
            players[position] = Player(position: position, hand: sorted, isBot: position != .south)
        }

        return DealResult(players: players, trumpSuit: trumpSuit, trumpCard: trumpCard)
    }

    static func sortForDisplay(_ cards: [Card], trump: Suit) -> [Card] {
        cards.sorted { lhs, rhs in
            if lhs.suit == rhs.suit {
                return lhs.rank > rhs.rank
            }
            if lhs.suit == trump { return true }
            if rhs.suit == trump { return false }
            return lhs.suit.rawValue < rhs.suit.rawValue
        }
    }
}
