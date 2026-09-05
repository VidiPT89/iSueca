import Foundation

enum RulesEngine {
    /// Cards a player is legally allowed to play, given the current trick and trump.
    static func legalMoves(hand: [Card], trick: Trick, trump: Suit) -> [Card] {
        guard let leadSuit = trick.leadSuit else {
            return hand
        }

        let sameSuit = hand.filter { $0.suit == leadSuit }
        if !sameSuit.isEmpty {
            return sameSuit
        }

        let trumps = hand.filter { $0.suit == trump }
        if !trumps.isEmpty {
            return trumps
        }

        return hand
    }

    static func isLegal(_ card: Card, hand: [Card], trick: Trick, trump: Suit) -> Bool {
        legalMoves(hand: hand, trick: trick, trump: trump).contains { $0.id == card.id }
    }
}
