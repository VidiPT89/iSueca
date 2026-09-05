import Foundation

/// Tracks every card seen so far to reason about what opponents can still hold,
/// plays "master" cards when they are guaranteed to win, and only cuts with trump
/// when the trick is worth it or the trump card is otherwise safe to spend.
struct HardBotStrategy: BotStrategy {
    func chooseCard(from legalMoves: [Card], hand: [Card], context: BotContext) -> Card {
        let seen = seenCards(context: context, hand: hand)
        let trick = context.currentTrick

        if trick.cardsPlayed.isEmpty {
            return chooseLead(from: legalMoves, hand: hand, seen: seen, context: context)
        }

        guard let leadSuit = trick.leadSuit else {
            return legalMoves.min { $0.pointValue < $1.pointValue } ?? legalMoves[0]
        }

        let currentWinner = TrickResolver.winner(of: trick, trump: context.trump)
        let partnerWinning = currentWinner.team == context.position.team
        let isLastToPlay = trick.cardsPlayed.count == 3

        let followingSuit = legalMoves.contains { $0.suit == leadSuit }
        if followingSuit {
            let sameSuit = legalMoves.filter { $0.suit == leadSuit }
            if partnerWinning {
                if isLastToPlay {
                    return sameSuit.max { $0.pointValue < $1.pointValue } ?? sameSuit[0]
                }
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
                return chooseDiscard(from: legalMoves, seen: seen, context: context)
            }
            let higherTrumpsUnseen = unseenHigherTrumps(than: trumps.min { $0.rank < $1.rank }!, seen: seen, context: context)
            let trickValue = trick.points
            let worthCutting = trickValue >= 4 || isLastToPlay || higherTrumpsUnseen == 0
            if worthCutting {
                if isLastToPlay {
                    let cheapestWinningTrump = trumps.min { $0.rank < $1.rank }!
                    return cheapestWinningTrump
                }
                let cheapTrumps = trumps.filter { $0.rank != .ace && $0.rank != .seven }
                return cheapTrumps.min { $0.rank < $1.rank } ?? trumps.min { $0.rank < $1.rank }!
            }
            return chooseDiscard(from: legalMoves, seen: seen, context: context)
        }

        return chooseDiscard(from: legalMoves, seen: seen, context: context)
    }

    private func chooseLead(from legalMoves: [Card], hand: [Card], seen: Set<Card>, context: BotContext) -> Card {
        let nonTrump = legalMoves.filter { $0.suit != context.trump }
        let pool = nonTrump.isEmpty ? legalMoves : nonTrump

        for card in pool.sorted(by: { $0.rank > $1.rank }) {
            if isMasterCard(card, seen: seen, context: context) {
                return card
            }
        }

        let safe = pool.filter { $0.rank != .ace && $0.rank != .seven }
        return (safe.isEmpty ? pool : safe).min { $0.pointValue < $1.pointValue } ?? pool[0]
    }

    private func chooseDiscard(from legalMoves: [Card], seen: Set<Card>, context: BotContext) -> Card {
        let safe = legalMoves.filter { $0.rank != .ace && $0.rank != .seven }
        return (safe.isEmpty ? legalMoves : safe).min { $0.pointValue < $1.pointValue } ?? legalMoves[0]
    }

    /// A card is a "master" if every stronger card of its suit has already been played or seen.
    private func isMasterCard(_ card: Card, seen: Set<Card>, context: BotContext) -> Bool {
        for rank in Rank.allCases where rank > card.rank {
            let higher = Card(suit: card.suit, rank: rank)
            if !seen.contains(where: { $0.suit == higher.suit && $0.rank == higher.rank }) {
                return false
            }
        }
        return true
    }

    private func unseenHigherTrumps(than card: Card, seen: Set<Card>, context: BotContext) -> Int {
        Rank.allCases.filter { $0 > card.rank }
            .filter { rank in !seen.contains(where: { $0.suit == context.trump && $0.rank == rank }) }
            .count
    }

    private func seenCards(context: BotContext, hand: [Card]) -> Set<Card> {
        var seen = Set<Card>(hand)
        for trick in context.completedTricks {
            for played in trick.cardsPlayed { seen.insert(played.card) }
        }
        for played in context.currentTrick.cardsPlayed { seen.insert(played.card) }
        return seen
    }
}
