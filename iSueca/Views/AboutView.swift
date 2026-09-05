import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(colors: [.brandPrimary, .brandSecondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 72, height: 96)
                    .overlay(Text("S").font(.system(size: 42, weight: .heavy, design: .rounded)).foregroundColor(.white))
                    .shadow(color: .brandPrimary.opacity(0.4), radius: 14, y: 6)

                Text(L.t("about.developedBy"))
                    .font(.subheadline)
                    .foregroundColor(.brandTextSecondary)
                Text(L.t("about.author"))
                    .font(.title3.weight(.bold))
                    .foregroundColor(.brandTextPrimary)

                VStack(spacing: 14) {
                    if let websiteURL = URL(string: "https://ividi.dev/") {
                        Link(destination: websiteURL) {
                            linkRow(icon: "globe", title: L.t("about.website"), value: "ividi.dev")
                        }
                    }
                    if let githubURL = URL(string: "https://github.com/VidiPT89/") {
                        Link(destination: githubURL) {
                            linkRow(icon: "chevron.left.slash.chevron.right", title: L.t("about.github"), value: "VidiPT89")
                        }
                    }
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding()
            .navigationTitle(L.t("about.title"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L.t("common.back")) { dismiss() }
                }
            }
        }
    }

    private func linkRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon).foregroundColor(.brandPrimary)
            Text(title).foregroundColor(.brandTextPrimary)
            Spacer()
            Text(value).foregroundColor(.brandSecondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.brandSurface))
        .frame(maxWidth: 320)
    }
}
