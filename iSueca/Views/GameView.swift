import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var shakeCardID: UUID?
    @State private var showHistory = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [Color.brandBackground, Color.brandSurface.opacity(0.7)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        ScoreboardView(teamAPoints: viewModel.teamAPoints, teamBPoints: viewModel.teamBPoints, trumpCard: viewModel.trumpCard)
                        Spacer()
                        historyButton
                    }
                    .padding(.top, 8)
                    .padding(.trailing, 12)

                    opponentRow(position: .north)
                        .padding(.top, 10)

                    Spacer(minLength: 0)

                    HStack {
                        opponentColumn(position: .west)
                        Spacer()
                        trickArea(size: proxy.size)
                        Spacer()
                        opponentColumn(position: .east)
                    }
                    .padding(.horizontal, 6)

                    Spacer(minLength: 0)

                    humanHand(availableWidth: proxy.size.width)
                        .padding(.bottom, 10)
                }
                // Belt-and-braces: `humanHand` now sizes its own cards to always fit
                // `proxy.size.width` (see its doc comment), but pinning the VStack to the measured
                // screen size guards against any future row that might grow wider than the screen —
                // without this, one overflowing row would inflate the width PROPOSED to every
                // sibling row (e.g. the West/East seats below), pushing the last item past a
                // Spacer() in some other row beyond the right edge, invisible with no visual clip.
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()

                if let stage = viewModel.dealingStage {
                    DealingOverlayView(stage: stage, trumpCard: viewModel.trumpCard, leaderNameKey: viewModel.currentPlayerTurn.nameKey)
                        .transition(.opacity)
                        .zIndex(2)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentTrick.cardsPlayed.count)
        .animation(.easeInOut(duration: 0.25), value: viewModel.dealingStage)
        .sheet(isPresented: $showHistory) {
            TrickHistoryView(tricks: viewModel.completedTricks)
        }
    }

    private var historyButton: some View {
        Button {
            showHistory = true
        } label: {
            Image(systemName: "clock.arrow.circlepath")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.brandTextSecondary)
                .padding(8)
                .background(Circle().fill(Color.brandSurface.opacity(0.85)))
        }
        .accessibilityLabel(L.t("history.title"))
    }

    private func opponentRow(position: PlayerPosition) -> some View {
        VStack(spacing: 4) {
            seatLabel(position)
            HStack(spacing: -22) {
                ForEach(0..<(viewModel.handsByPosition[position]?.count ?? 0), id: \.self) { _ in
                    CardView(card: Card(suit: .clubs, rank: .two), faceUp: false, width: 34)
                }
            }
        }
    }

    private func opponentColumn(position: PlayerPosition) -> some View {
        let cardWidth: CGFloat = 34
        let cardHeight = cardWidth * 1.45
        return VStack(spacing: 4) {
            seatLabel(position)
            VStack(spacing: -cardWidth * 0.55) {
                ForEach(0..<(viewModel.handsByPosition[position]?.count ?? 0), id: \.self) { _ in
                    CardView(card: Card(suit: .clubs, rank: .two), faceUp: false, width: cardWidth)
                        .rotationEffect(.degrees(90))
                        // `.rotationEffect` doesn't swap the layout size it reports to the parent,
                        // so without this the VStack keeps reserving the pre-rotation (portrait)
                        // box, which visually mismatches the post-rotation (landscape) pixels.
                        .frame(width: cardHeight, height: cardWidth)
                }
            }
        }
        .frame(width: cardHeight)
    }

    private func seatLabel(_ position: PlayerPosition) -> some View {
        let isActive = viewModel.currentPlayerTurn == position
        let isThinking = isActive && position != .south && viewModel.phase == .playing

        return HStack(spacing: 5) {
            if isThinking {
                ThinkingDot()
            }
            Text(L.t(position.nameKey))
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundColor(isActive ? .brandPrimary : .brandTextSecondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            Capsule().fill(isActive ? Color.brandPrimary.opacity(0.18) : Color.clear)
        )
    }

    private func trickArea(size: CGSize) -> some View {
        let boxSize = min(size.width * 0.5, 210)
        return ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.brandSurface.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Color.brandPrimary.opacity(0.22), style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
                )
                .frame(width: boxSize, height: boxSize)

            if let leadSuit = viewModel.currentTrick.leadSuit {
                VStack {
                    HStack {
                        Image(systemName: leadSuitSystemImage(leadSuit))
                            .font(.caption2)
                            .foregroundColor(leadSuit.isRed ? .red.opacity(0.55) : .brandTextSecondary)
                            .padding(6)
                            .background(Circle().fill(Color.brandSurface.opacity(0.9)))
                        Spacer()
                    }
                    Spacer()
                }
                .frame(width: boxSize, height: boxSize)
                .padding(6)
                .transition(.opacity)
            }

            ForEach(viewModel.currentTrick.cardsPlayed) { played in
                let isWinner = viewModel.phase == .trickEnd && viewModel.lastTrickWinner == played.position
                CardView(card: played.card, width: 50)
                    .shadow(color: isWinner ? Color.brandSecondary.opacity(0.9) : .clear, radius: isWinner ? 10 : 0)
                    .scaleEffect(isWinner ? 1.12 : 1.0)
                    .offset(offset(for: played.position))
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.4).combined(with: .opacity),
                        removal: .move(edge: edge(for: played.position)).combined(with: .opacity)
                    ))
                    .animation(.spring(response: 0.35, dampingFraction: 0.6), value: viewModel.phase)
                    .id(played.card.id)
            }
        }
    }

    private func leadSuitSystemImage(_ suit: Suit) -> String {
        switch suit {
        case .clubs: return "suit.club.fill"
        case .hearts: return "suit.heart.fill"
        case .spades: return "suit.spade.fill"
        case .diamonds: return "suit.diamond.fill"
        }
    }

    private func offset(for position: PlayerPosition) -> CGSize {
        switch position {
        case .south: return CGSize(width: 0, height: 34)
        case .north: return CGSize(width: 0, height: -34)
        case .west: return CGSize(width: -34, height: 0)
        case .east: return CGSize(width: 34, height: 0)
        }
    }

    private func edge(for position: PlayerPosition) -> Edge {
        switch position {
        case .south: return .bottom
        case .north: return .top
        case .west: return .leading
        case .east: return .trailing
        }
    }

    /// The hand fans out with overlapping cards; without a width cap a full 10-card hand would be
    /// wider than the screen, cutting off the outermost cards. Shrinking `cardWidth` (bounded to
    /// stay legible) as the hand grows keeps every card fully on screen and tappable.
    private func humanHand(availableWidth: CGFloat) -> some View {
        let cards = viewModel.handsByPosition[.south] ?? []
        let legal = Set(viewModel.humanLegalMoves.map { $0.id })
        let isHumanTurn = viewModel.currentPlayerTurn == .south && (viewModel.phase == .playing)

        let overlapRatio: CGFloat = 0.3
        let maxCardWidth: CGFloat = 62
        let minCardWidth: CGFloat = 42
        let usableWidth = max(availableWidth - 16, minCardWidth)
        let count = max(cards.count, 1)
        let widthDenominator = 1 + CGFloat(count - 1) * (1 - overlapRatio)
        let cardWidth = min(maxCardWidth, max(minCardWidth, usableWidth / widthDenominator))

        return HStack(spacing: -cardWidth * overlapRatio) {
            ForEach(cards) { card in
                CardView(card: card, width: cardWidth)
                    .offset(y: shakeCardID == card.id ? 0 : (isHumanTurn && legal.contains(card.id) ? -10 : 0))
                    .opacity(isHumanTurn && !legal.contains(card.id) ? 0.55 : 1.0)
                    .modifier(ShakeEffect(shakes: shakeCardID == card.id ? 2 : 0))
                    .onTapGesture {
                        guard isHumanTurn else { return }
                        if legal.contains(card.id) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                viewModel.playHumanCard(card)
                            }
                        } else {
                            triggerShake(card.id)
                        }
                    }
                    .zIndex(shakeCardID == card.id ? 1 : 0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isHumanTurn)
            }
        }
        .frame(maxWidth: .infinity)
        .onChange(of: viewModel.invalidMoveAttempt) { newValue in
            if let id = newValue?.id { triggerShake(id) }
        }
    }

    private func triggerShake(_ id: UUID) {
        withAnimation(.default) { shakeCardID = id }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if shakeCardID == id { shakeCardID = nil }
        }
    }
}

private struct ThinkingDot: View {
    @State private var isPulsing = false

    var body: some View {
        Circle()
            .fill(Color.brandPrimary)
            .frame(width: 6, height: 6)
            .scaleEffect(isPulsing ? 1.3 : 0.7)
            .opacity(isPulsing ? 1.0 : 0.5)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
    }
}

private struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat
    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = 6 * sin(shakes * .pi * 4)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
