import SwiftUI

struct CardView: View {
    let card: Card
    var faceUp: Bool = true
    var width: CGFloat = 58

    private var height: CGFloat { width * 1.45 }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: width * 0.14)
                .fill(faceUp ? AnyShapeStyle(faceGradient) : AnyShapeStyle(backGradient))
                .overlay(
                    RoundedRectangle(cornerRadius: width * 0.14)
                        .strokeBorder(Color.black.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 5, y: 3)

            if faceUp {
                // Faint diagonal sheen so the white card face doesn't look like a flat sticker.
                RoundedRectangle(cornerRadius: width * 0.14)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.55), .clear, .black.opacity(0.04)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )

                VStack {
                    HStack {
                        pip
                        Spacer()
                    }
                    Spacer()
                    Image(systemName: suitSystemImage)
                        .font(.system(size: width * 0.42))
                        .foregroundStyle(suitGradient)
                        .shadow(color: suitColor.opacity(0.25), radius: 1, y: 1)
                    Spacer()
                    HStack {
                        Spacer()
                        pip.rotationEffect(.degrees(180))
                    }
                }
                .padding(width * 0.1)
            } else {
                LinearGradient(
                    colors: [Color.white.opacity(0.08), .clear],
                    startPoint: .top, endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: width * 0.14))

                RoundedRectangle(cornerRadius: width * 0.1)
                    .strokeBorder(Color.brandSecondary.opacity(0.6), lineWidth: 2)
                    .padding(width * 0.12)
                CardBackLattice()
                    .stroke(Color.brandSecondary.opacity(0.28), lineWidth: 1)
                    .padding(width * 0.16)
                Image(systemName: "suit.spade.fill")
                    .font(.system(size: width * 0.3))
                    .foregroundColor(.brandSecondary.opacity(0.55))
            }
        }
        .frame(width: width, height: height)
    }

    private var pip: some View {
        VStack(spacing: 0) {
            Text(card.displayLabel)
                .font(.system(size: width * 0.26, weight: .bold, design: .rounded))
            Image(systemName: suitSystemImage)
                .font(.system(size: width * 0.18))
        }
        .foregroundColor(suitColor)
    }

    private var suitColor: Color {
        card.suit.isRed ? Color(red: 0.75, green: 0.15, blue: 0.15) : Color(red: 0.12, green: 0.12, blue: 0.14)
    }

    private var suitGradient: LinearGradient {
        let base = suitColor
        return LinearGradient(
            colors: [base, base.opacity(0.75)],
            startPoint: .top, endPoint: .bottom
        )
    }

    private var suitSystemImage: String {
        switch card.suit {
        case .clubs: return "suit.club.fill"
        case .hearts: return "suit.heart.fill"
        case .spades: return "suit.spade.fill"
        case .diamonds: return "suit.diamond.fill"
        }
    }

    private var faceGradient: LinearGradient {
        LinearGradient(colors: [Color.white, Color(white: 0.94)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var backGradient: LinearGradient {
        LinearGradient(colors: [Color.brandPrimary, Color(red: 0.1, green: 0.08, blue: 0.06)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

/// A simple criss-cross lattice used as a subtle engraved pattern on face-down card backs.
private struct CardBackLattice: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step = rect.width / 3
        var x = rect.minX
        while x <= rect.maxX {
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
            x += step
        }
        var y = rect.minY
        let stepY = rect.height / 5
        while y <= rect.maxY {
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
            y += stepY
        }
        return path
    }
}
