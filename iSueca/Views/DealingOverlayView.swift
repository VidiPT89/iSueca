import SwiftUI

struct DealingOverlayView: View {
    let stage: DealingStage
    let trumpCard: Card?
    let leaderNameKey: String

    var body: some View {
        ZStack {
            Color.black.opacity(stage == .dealCards ? 0 : 0.45)
                .ignoresSafeArea()

            switch stage {
            case .revealTrump:
                trumpBanner
            case .dealCards:
                EmptyView()
            case .announceLeader:
                leaderBanner
            }
        }
        .allowsHitTesting(false)
    }

    private var trumpBanner: some View {
        VStack(spacing: 12) {
            Text(L.t("game.trumpRevealed"))
                .font(.caption.weight(.semibold))
                .foregroundColor(.brandTextSecondary)
                .textCase(.uppercase)
                .tracking(1.5)

            if let trumpCard {
                CardView(card: trumpCard, width: 82)
                    .shadow(color: Color.brandPrimary.opacity(0.5), radius: 16, y: 6)
            }

            if let trumpCard {
                Text(L.t(trumpCard.suit.nameKey))
                    .font(.title2.weight(.heavy))
                    .foregroundStyle(
                        LinearGradient(colors: [.brandPrimary, .brandSecondary], startPoint: .leading, endPoint: .trailing)
                    )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.brandSurface.opacity(0.95))
                .shadow(color: .black.opacity(0.35), radius: 20, y: 8)
        )
        .transition(.scale(scale: 0.75).combined(with: .opacity))
    }

    private var leaderBanner: some View {
        Text(String(format: L.t("game.leaderStarts"), L.t(leaderNameKey)))
            .font(.headline.weight(.bold))
            .foregroundColor(.brandTextPrimary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 22)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(Color.brandSurface.opacity(0.95))
                    .shadow(color: .black.opacity(0.3), radius: 14, y: 6)
            )
            .transition(.move(edge: .top).combined(with: .opacity))
    }
}
