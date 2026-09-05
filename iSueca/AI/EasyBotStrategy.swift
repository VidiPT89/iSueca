import Foundation

/// Plays any legal card at random, no lookahead at all.
struct EasyBotStrategy: BotStrategy {
    func chooseCard(from legalMoves: [Card], hand: [Card], context: BotContext) -> Card {
        legalMoves.randomElement() ?? hand[0]
    }
}
