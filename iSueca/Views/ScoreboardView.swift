import SwiftUI

struct ScoreboardView: View {
    let teamAPoints: Int
    let teamBPoints: Int
    let trumpCard: Card?

    var body: some View {
        HStack(spacing: 16) {
            scorePill(titleKey: "game.teamA", points: teamAPoints, color: .brandPrimary)

            if let trumpCard {
                VStack(spacing: 2) {
                    Text(L.t("game.trump"))
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.brandTextSecondary)
                    CardView(card: trumpCard, width: 34)
                }
            }

            scorePill(titleKey: "game.teamB", points: teamBPoints, color: .brandSecondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule().fill(Color.brandSurface.opacity(0.85))
                .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: teamAPoints)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: teamBPoints)
    }

    private func scorePill(titleKey: String, points: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(L.t(titleKey))
                .font(.caption2.weight(.semibold))
                .foregroundColor(.brandTextSecondary)
            Text("\(points)")
                .font(.title3.weight(.heavy))
                .foregroundColor(color)
                .contentTransition(.numericText())
        }
        .frame(minWidth: 48)
    }
}
