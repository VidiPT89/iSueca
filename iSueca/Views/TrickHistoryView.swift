import SwiftUI

struct TrickHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    let tricks: [Trick]

    var body: some View {
        NavigationView {
            Group {
                if tricks.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 36))
                            .foregroundColor(.brandTextSecondary)
                        Text(L.t("history.empty"))
                            .font(.subheadline)
                            .foregroundColor(.brandTextSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(Array(tricks.enumerated().reversed()), id: \.offset) { index, trick in
                            trickRow(number: index + 1, trick: trick)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color.brandBackground.ignoresSafeArea())
            .navigationTitle(L.t("history.title"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L.t("common.back")) { dismiss() }
                }
            }
        }
    }

    private func trickRow(number: Int, trick: Trick) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(String(format: L.t("history.trickNumber"), number))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.brandTextPrimary)
                Spacer()
                Text("\(trick.points) \(L.t("history.points"))")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.brandSecondary)
            }

            HStack(spacing: 10) {
                ForEach(trick.cardsPlayed) { played in
                    VStack(spacing: 4) {
                        CardView(card: played.card, width: 40)
                        Text(L.t(played.position.nameKey))
                            .font(.caption2)
                            .foregroundColor(played.position == trick.winner ? .brandPrimary : .brandTextSecondary)
                    }
                }
            }
        }
        .padding(.vertical, 6)
        .listRowBackground(Color.brandSurface.opacity(0.6))
    }
}
