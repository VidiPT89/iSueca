import Foundation

enum DeckBuilder {
    static func fullDeck() -> [Card] {
        var deck: [Card] = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                deck.append(Card(suit: suit, rank: rank))
            }
        }
        return deck
    }

    static func shuffledDeck() -> [Card] {
        fullDeck().shuffled()
    }
}
