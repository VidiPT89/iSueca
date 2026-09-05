import Foundation

enum ScoreCalculator {
    static let totalPoints = 120
    static let winThreshold = 61

    static func addPoints(from trick: Trick, winner: PlayerPosition, teamAPoints: inout Int, teamBPoints: inout Int) {
        let points = trick.points
        switch winner.team {
        case .teamA: teamAPoints += points
        case .teamB: teamBPoints += points
        }
    }

    static func handWinner(teamAPoints: Int, teamBPoints: Int) -> Team? {
        if teamAPoints >= winThreshold { return .teamA }
        if teamBPoints >= winThreshold { return .teamB }
        return nil
    }

    static func isSueca(teamPoints: Int) -> Bool {
        teamPoints == totalPoints
    }
}
