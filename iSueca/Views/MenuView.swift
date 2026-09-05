import SwiftUI

struct MenuView: View {
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject private var statsStore = MatchStatsStore.shared
    @ObservedObject private var localization = LocalizationManager.shared
    @State private var showSettings = false
    @State private var showAbout = false
    @State private var showRules = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.brandBackground, Color.brandSurface.opacity(0.6)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    languageToggle
                }
                .padding(.horizontal)
                .padding(.top, 6)

                Spacer()

                titleBlock

                Spacer()

                Button {
                    viewModel.startNewGame()
                } label: {
                    Text(L.t("menu.startGame"))
                        .font(.headline.weight(.bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: 260)
                        .padding(.vertical, 16)
                        .background(
                            Capsule().fill(
                                LinearGradient(colors: [.brandPrimary, .brandSecondary], startPoint: .leading, endPoint: .trailing)
                            )
                        )
                        .shadow(color: Color.brandPrimary.opacity(0.4), radius: 14, y: 6)
                }
                .accessibilityIdentifier("menu.play")

                VStack(spacing: 12) {
                    menuButton(L.t("menu.rules"), icon: "book.closed.fill") { showRules = true }
                    menuButton(L.t("menu.settings"), icon: "gearshape.fill") { showSettings = true }
                    menuButton(L.t("menu.about"), icon: "info.circle.fill") { showAbout = true }
                }
                .padding(.top, 24)

                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showAbout) { AboutView() }
        .sheet(isPresented: $showRules) { RulesView() }
    }

    private var languageToggle: some View {
        Button {
            localization.language = localization.language == .portuguese ? .english : .portuguese
        } label: {
            Text(localization.language == .portuguese ? "PT" : "EN")
                .font(.caption.weight(.bold))
                .foregroundColor(.brandPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.brandSurface))
        }
    }

    private var titleBlock: some View {
        VStack(spacing: 6) {
            Text(L.t("menu.title"))
                .font(.system(size: 54, weight: .black, design: .rounded))
                .tracking(1)
                .foregroundStyle(
                    LinearGradient(colors: [.brandPrimary, .brandSecondary], startPoint: .leading, endPoint: .trailing)
                )
                .shadow(color: Color.brandPrimary.opacity(0.25), radius: 12, y: 4)
            Text(L.t("menu.subtitle"))
                .font(.subheadline)
                .foregroundColor(.brandTextSecondary)
                .multilineTextAlignment(.center)

            if statsStore.stats.gamesPlayed > 0 {
                Text(String(format: L.t("stats.record"), statsStore.stats.gamesWon, statsStore.stats.gamesPlayed))
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.brandTextSecondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        Capsule().fill(Color.brandSurface)
                            .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
                    )
                    .padding(.top, 10)
            }
        }
    }

    private func menuButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.brandPrimary.opacity(0.14))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .foregroundColor(.brandPrimary)
                        .font(.subheadline.weight(.semibold))
                }
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.brandTextSecondary.opacity(0.6))
            }
            .font(.subheadline.weight(.medium))
            .foregroundColor(.brandTextPrimary)
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.brandSurface)
                    .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
            )
        }
        .frame(maxWidth: 280)
    }
}
