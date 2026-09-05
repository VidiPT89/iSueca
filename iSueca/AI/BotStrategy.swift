import Foundation

/// Context handed to a bot so it can reason about the table without touching hidden hands.
struct BotContext {
    let position: PlayerPosition
    let trump: Suit
    let currentTrick: Trick
    let completedTricks: [Trick]
    let teamAPoints: Int
    let teamBPoints: Int
    let cardsRemainingInOthersHands: Int
}

protocol BotStrategy {
    func chooseCard(from legalMoves: [Card], hand: [Card], context: BotContext) -> Card
}

func makeBotStrategy(for difficulty: AIDifficulty) -> BotStrategy {
    switch difficulty {
    case .easy: return EasyBotStrategy()
    case .normal: return MediumBotStrategy()
    case .hard: return HardBotStrategy()
    }
}
