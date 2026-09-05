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
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)

            if faceUp {
                VStack {
                    HStack {
                        pip
                        Spacer()
                    }
                    Spacer()
                    Image(systemName: suitSystemImage)
                        .font(.system(size: width * 0.42))
                        .foregroundColor(suitColor)
                    Spacer()
                    HStack {
                        Spacer()
                        pip.rotationEffect(.degrees(180))
                    }
                }
                .padding(width * 0.1)
            } else {
                RoundedRectangle(cornerRadius: width * 0.1)
                    .strokeBorder(Color.brandSecondary.opacity(0.55), lineWidth: 2)
                    .padding(width * 0.14)
                Image(systemName: "suit.spade.fill")
                    .font(.system(size: width * 0.3))
                    .foregroundColor(.brandSecondary.opacity(0.5))
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
