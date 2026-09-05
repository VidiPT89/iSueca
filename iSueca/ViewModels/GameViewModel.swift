import Foundation
import Combine
import SwiftUI
import UIKit

enum GamePhase: Equatable {
    case menu
    case dealing
    case playing
    case trickEnd
    case handEnd
}

enum DealingStage: Equatable {
    case revealTrump
    case dealCards
    case announceLeader
}

struct HandResult: Equatable {
    let teamAPoints: Int
    let teamBPoints: Int
    let winner: Team?
    let wasSueca: Bool
}

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var phase: GamePhase = .menu
    @Published private(set) var handsByPosition: [PlayerPosition: [Card]] = [:]
    @Published private(set) var trumpSuit: Suit = .spades
    @Published private(set) var trumpCard: Card?
    @Published private(set) var currentTrick: Trick = Trick()
    @Published private(set) var teamAPoints: Int = 0
    @Published private(set) var teamBPoints: Int = 0
    @Published private(set) var currentPlayerTurn: PlayerPosition = .south
    @Published private(set) var lastTrickWinner: PlayerPosition?
    @Published private(set) var handResult: HandResult?
    @Published private(set) var tricksWonCount: [PlayerPosition: Int] = [:]
    @Published private(set) var completedTricks: [Trick] = []
    @Published private(set) var dealingStage: DealingStage?
    @Published var invalidMoveAttempt: Card?

    private var settings: SettingsViewModel?
    private var state: GameState?
    private var dealer: PlayerPosition = .west
    private let feedback = UIImpactFeedbackGenerator(style: .light)

    func configure(settings: SettingsViewModel) {
        self.settings = settings
    }

    var humanLegalMoves: [Card] {
        guard let state else { return [] }
        return RulesEngine.legalMoves(hand: state.hand(for: .south), trick: state.currentTrick, trump: state.trumpSuit)
    }

    func startNewGame() {
        dealer = PlayerPosition.allCases.randomElement() ?? .west
        beginHand()
    }

    func playAgain() {
        dealer = dealer.next
        beginHand()
    }

    func returnToMenu() {
        phase = .menu
        handResult = nil
    }

    private func beginHand() {
        let result = DealerService.deal(dealer: dealer)
        let firstToPlay = dealer.next
        let newState = GameState(players: result.players, trumpSuit: result.trumpSuit, trumpCard: result.trumpCard,
                                  dealerPosition: dealer, firstToPlay: firstToPlay)
        state = newState
        trumpSuit = result.trumpSuit
        trumpCard = nil
        currentTrick = Trick()
        teamAPoints = 0
        teamBPoints = 0
        currentPlayerTurn = firstToPlay
        lastTrickWinner = nil
        handResult = nil
        tricksWonCount = [.south: 0, .west: 0, .north: 0, .east: 0]
        completedTricks = []
        handsByPosition = [.south: [], .west: [], .north: [], .east: []]

        phase = .dealing
        runDealingSequence(finalHands: result.players.mapValues { $0.hand }, trumpCard: result.trumpCard)
    }

    private func runDealingSequence(finalHands: [PlayerPosition: [Card]], trumpCard: Card) {
        Task {
            guard self.phase == .dealing else { return }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                self.dealingStage = .revealTrump
                self.trumpCard = trumpCard
            }
            SoundPlayer.play(.trickWin)
            try? await Task.sleep(nanoseconds: 900_000_000)

            guard self.phase == .dealing else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                self.dealingStage = .dealCards
            }

            let cardsPerHand = finalHands.values.map(\.count).max() ?? 10
            for round in 0..<cardsPerHand {
                guard self.phase == .dealing else { return }
                withAnimation(.easeOut(duration: 0.16)) {
                    for position in PlayerPosition.allCases {
                        guard let hand = finalHands[position], round < hand.count else { continue }
                        self.handsByPosition[position, default: []].append(hand[round])
                    }
                }
                SoundPlayer.play(.cardPlay)
                try? await Task.sleep(nanoseconds: 65_000_000)
            }

            guard self.phase == .dealing else { return }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                self.dealingStage = .announceLeader
            }
            try? await Task.sleep(nanoseconds: 1_100_000_000)

            guard self.phase == .dealing else { return }
            withAnimation(.easeOut(duration: 0.25)) {
                self.dealingStage = nil
            }
            self.phase = .playing
            self.advanceIfNeeded()
        }
    }

    func playHumanCard(_ card: Card) {
        guard phase == .playing, currentPlayerTurn == .south, let state else { return }
        guard RulesEngine.isLegal(card, hand: state.hand(for: .south), trick: state.currentTrick, trump: state.trumpSuit) else {
            invalidMoveAttempt = card
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            SoundPlayer.play(.illegalMove)
            return
        }
        play(card, by: .south)
    }

    private func play(_ card: Card, by position: PlayerPosition) {
        guard let state else { return }
        feedback.impactOccurred()
        SoundPlayer.play(.cardPlay)
        state.remove(card, from: position)
        state.currentTrick.play(card, by: position)
        handsByPosition[position] = state.hand(for: position)
        currentTrick = state.currentTrick

        if state.currentTrick.isComplete {
            resolveTrick()
        } else {
            currentPlayerTurn = position.next
            state.currentPlayerTurn = currentPlayerTurn
            advanceIfNeeded()
        }
    }

    private func resolveTrick() {
        guard let state else { return }
        phase = .trickEnd
        let winner = TrickResolver.winner(of: state.currentTrick, trump: state.trumpSuit)
        ScoreCalculator.addPoints(from: state.currentTrick, winner: winner, teamAPoints: &state.teamAPoints, teamBPoints: &state.teamBPoints)
        teamAPoints = state.teamAPoints
        teamBPoints = state.teamBPoints
        lastTrickWinner = winner
        tricksWonCount[winner, default: 0] += 1
        state.currentTrick.winner = winner
        state.completedTricks.append(state.currentTrick)
        completedTricks = state.completedTricks
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        SoundPlayer.play(.trickWin)

        Task {
            try? await Task.sleep(nanoseconds: 900_000_000)
            self.state?.currentTrick = Trick()
            self.currentTrick = Trick()
            self.currentPlayerTurn = winner
            self.state?.currentPlayerTurn = winner

            if (self.state?.completedTricks.count ?? 0) >= 10 {
                self.finishHand()
            } else {
                self.phase = .playing
                self.advanceIfNeeded()
            }
        }
    }

    private func finishHand() {
        guard let state else { return }
        let winner = ScoreCalculator.handWinner(teamAPoints: state.teamAPoints, teamBPoints: state.teamBPoints)
        let wasSueca = ScoreCalculator.isSueca(teamPoints: state.teamAPoints) || ScoreCalculator.isSueca(teamPoints: state.teamBPoints)
        let result = HandResult(teamAPoints: state.teamAPoints, teamBPoints: state.teamBPoints, winner: winner, wasSueca: wasSueca)
        handResult = result
        MatchStatsStore.shared.recordHandResult(humanTeamWon: winner == .teamA, wasSueca: wasSueca)
        UINotificationFeedbackGenerator().notificationOccurred(winner == .teamA ? .success : .error)
        SoundPlayer.play(.handEnd)
        phase = .handEnd
    }

    private func advanceIfNeeded() {
        guard phase == .playing, let state, currentPlayerTurn != .south else { return }
        let position = currentPlayerTurn
        let difficulty = settings?.aiDifficulty ?? .normal
        let speedRange = (settings?.aiSpeed ?? .normal).delayRange
        let strategy = makeBotStrategy(for: difficulty)
        let hand = state.hand(for: position)
        let legalMoves = RulesEngine.legalMoves(hand: hand, trick: state.currentTrick, trump: state.trumpSuit)
        let context = BotContext(position: position, trump: state.trumpSuit, currentTrick: state.currentTrick,
                                  completedTricks: state.completedTricks, teamAPoints: state.teamAPoints,
                                  teamBPoints: state.teamBPoints, cardsRemainingInOthersHands: hand.count)

        Task {
            let delay = Double.random(in: speedRange)
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard self.phase == .playing, self.currentPlayerTurn == position else { return }
            let card = strategy.chooseCard(from: legalMoves, hand: hand, context: context)
            self.play(card, by: position)
        }
    }
}
