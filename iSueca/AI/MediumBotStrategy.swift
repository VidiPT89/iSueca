import Foundation

/// Simple heuristics: keeps high trumps in reserve, cuts only when it pays off,
/// tries not to burn an Ace or 7 for nothing, and helps a winning partner cheaply.
struct MediumBotStrategy: BotStrategy {
    func chooseCard(from legalMoves: [Card], hand: [Card], context: BotContext) -> Card {
        let trick = context.currentTrick

        if trick.cardsPlayed.isEmpty {
            return chooseLead(from: legalMoves, hand: hand, context: context)
        }

        guard let leadSuit = trick.leadSuit else {
            return legalMoves.min { $0.pointValue < $1.pointValue } ?? legalMoves[0]
        }

        let followingSuit = legalMoves.contains { $0.suit == leadSuit }
        let currentWinner = TrickResolver.winner(of: trick, trump: context.trump)
        let partnerWinning = currentWinner.team == context.position.team

        if followingSuit {
            let sameSuit = legalMoves.filter { $0.suit == leadSuit }
            if partnerWinning {
                return sameSuit.min { $0.pointValue < $1.pointValue } ?? sameSuit[0]
            }
            let currentWinningCard = trick.cardsPlayed.first { $0.position == currentWinner }!.card
            let winningOptions = sameSuit.filter { $0.rank > currentWinningCard.rank }
            if let cheapestWin = winningOptions.min(by: { $0.pointValue < $1.pointValue }) {
                return cheapestWin
            }
            return sameSuit.min { $0.pointValue < $1.pointValue } ?? sameSuit[0]
        }

        let trumps = legalMoves.filter { $0.suit == context.trump }
        if !trumps.isEmpty {
            if partnerWinning {
                return chooseDiscard(from: legalMoves)
            }
            let trickValue = trick.points
            let cheapTrumps = trumps.filter { $0.rank != .ace && $0.rank != .seven }
            if trickValue >= 5 || trumps.count == legalMoves.count {
                return cheapTrumps.min { $0.rank < $1.rank } ?? trumps.min { $0.rank < $1.rank }!
            }
            return trumps.min { $0.rank < $1.rank } ?? trumps[0]
        }

        return chooseDiscard(from: legalMoves)
    }

    private func chooseLead(from legalMoves: [Card], hand: [Card], context: BotContext) -> Card {
        let nonTrump = legalMoves.filter { $0.suit != context.trump }
        let pool = nonTrump.isEmpty ? legalMoves : nonTrump
        let safe = pool.filter { $0.rank != .ace && $0.rank != .seven }
        return (safe.isEmpty ? pool : safe).min { $0.pointValue < $1.pointValue } ?? pool[0]
    }

    private func chooseDiscard(from legalMoves: [Card]) -> Card {
        let safe = legalMoves.filter { $0.rank != .ace && $0.rank != .seven }
        return (safe.isEmpty ? legalMoves : safe).min { $0.pointValue < $1.pointValue } ?? legalMoves[0]
    }
}
