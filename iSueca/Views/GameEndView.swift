import SwiftUI

struct GameEndView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var appear = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.brandBackground, Color.brandSurface], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                Spacer()

                Image(systemName: trophyIcon)
                    .font(.system(size: 64))
                    .foregroundStyle(LinearGradient(colors: [.brandPrimary, .brandSecondary], startPoint: .top, endPoint: .bottom))
                    .scaleEffect(appear ? 1 : 0.5)
                    .opacity(appear ? 1 : 0)

                Text(resultTitle)
                    .font(.title.weight(.heavy))
                    .foregroundColor(.brandTextPrimary)
                    .multilineTextAlignment(.center)

                if viewModel.handResult?.wasSueca == true {
                    Text(L.t("game.sueca"))
                        .font(.headline)
                        .foregroundColor(.brandSecondary)
                }

                HStack(spacing: 30) {
                    scoreColumn(titleKey: "game.teamA", points: viewModel.handResult?.teamAPoints ?? 0)
                    scoreColumn(titleKey: "game.teamB", points: viewModel.handResult?.teamBPoints ?? 0)
                }
                .padding(.top, 6)

                Spacer()

                VStack(spacing: 14) {
                    Button {
                        viewModel.playAgain()
                    } label: {
                        Text(L.t("game.playAgain"))
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: 260)
                            .padding(.vertical, 16)
                            .background(
                                Capsule().fill(LinearGradient(colors: [.brandPrimary, .brandSecondary], startPoint: .leading, endPoint: .trailing))
                            )
                            .shadow(color: Color.brandPrimary.opacity(0.4), radius: 14, y: 6)
                    }

                    Button {
                        viewModel.returnToMenu()
                    } label: {
                        Text(L.t("menu.title"))
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.brandTextSecondary)
                    }
                }
                .padding(.bottom, 40)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) { appear = true }
        }
    }

    private var trophyIcon: String {
        viewModel.handResult?.winner == .teamA ? "trophy.fill" : "trophy"
    }

    private var resultTitle: String {
        if viewModel.handResult?.winner == .teamA {
            return L.t("game.youWin")
        }
        return L.t("game.youLose")
    }

    private func scoreColumn(titleKey: String, points: Int) -> some View {
        VStack(spacing: 4) {
            Text(L.t(titleKey))
                .font(.caption.weight(.semibold))
                .foregroundColor(.brandTextSecondary)
            Text("\(points)")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundColor(.brandTextPrimary)
        }
    }
}
