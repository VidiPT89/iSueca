import Foundation

struct MatchStats: Codable {
    var gamesPlayed: Int = 0
    var gamesWon: Int = 0
    var currentStreak: Int = 0
    var bestStreak: Int = 0
    var suecasMade: Int = 0
}

@MainActor
final class MatchStatsStore: ObservableObject {
    static let shared = MatchStatsStore()

    @Published private(set) var stats: MatchStats

    private static let storageKey = "app.matchStats"

    private init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode(MatchStats.self, from: data) {
            stats = decoded
        } else {
            stats = MatchStats()
        }
    }

    func recordHandResult(humanTeamWon: Bool, wasSueca: Bool) {
        stats.gamesPlayed += 1
        if humanTeamWon {
            stats.gamesWon += 1
            stats.currentStreak += 1
            stats.bestStreak = max(stats.bestStreak, stats.currentStreak)
        } else {
            stats.currentStreak = 0
        }
        if wasSueca { stats.suecasMade += 1 }
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
}
