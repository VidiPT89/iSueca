import SwiftUI

struct RulesView: View {
    @Environment(\.dismiss) private var dismiss

    private let sectionKeys = [
        "rules.section.overview",
        "rules.section.values",
        "rules.section.dealing",
        "rules.section.play",
        "rules.section.winning"
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(sectionKeys, id: \.self) { key in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L.t(key + ".title"))
                                .font(.headline)
                                .foregroundColor(.brandPrimary)
                            Text(L.t(key + ".body"))
                                .font(.subheadline)
                                .foregroundColor(.brandTextPrimary)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(L.t("rules.title"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L.t("common.back")) { dismiss() }
                }
            }
        }
    }
}
