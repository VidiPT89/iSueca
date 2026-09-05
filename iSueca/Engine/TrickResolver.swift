import Foundation

enum TrickResolver {
    static func winner(of trick: Trick, trump: Suit) -> PlayerPosition {
        precondition(!trick.cardsPlayed.isEmpty, "cannot resolve an empty trick")

        let trumpsPlayed = trick.cardsPlayed.filter { $0.card.suit == trump }
        if !trumpsPlayed.isEmpty {
            return trumpsPlayed.max { $0.card.rank < $1.card.rank }!.position
        }

        guard let leadSuit = trick.leadSuit else {
            return trick.cardsPlayed.first!.position
        }
        let ledSuitCards = trick.cardsPlayed.filter { $0.card.suit == leadSuit }
        return ledSuitCards.max { $0.card.rank < $1.card.rank }!.position
    }
}
