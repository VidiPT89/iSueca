import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var shakeCardID: UUID?

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [Color.brandBackground, Color.brandSurface.opacity(0.7)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    ScoreboardView(teamAPoints: viewModel.teamAPoints, teamBPoints: viewModel.teamBPoints, trumpCard: viewModel.trumpCard)
                        .padding(.top, 8)

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

                    humanHand
                        .padding(.bottom, 10)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentTrick.cardsPlayed.count)
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
        VStack(spacing: 4) {
            seatLabel(position)
            VStack(spacing: -46) {
                ForEach(0..<(viewModel.handsByPosition[position]?.count ?? 0), id: \.self) { _ in
                    CardView(card: Card(suit: .clubs, rank: .two), faceUp: false, width: 34)
                        .rotationEffect(.degrees(90))
                }
            }
        }
    }

    private func seatLabel(_ position: PlayerPosition) -> some View {
        Text(L.t(position.nameKey))
            .font(.caption.weight(.semibold))
            .foregroundColor(viewModel.currentPlayerTurn == position ? .brandPrimary : .brandTextSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(viewModel.currentPlayerTurn == position ? Color.brandPrimary.opacity(0.18) : Color.clear)
            )
    }

    private func trickArea(size: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.brandSurface.opacity(0.5))
                .frame(width: min(size.width * 0.5, 210), height: min(size.width * 0.5, 210))

            ForEach(viewModel.currentTrick.cardsPlayed) { played in
                CardView(card: played.card, width: 50)
                    .offset(offset(for: played.position))
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.4).combined(with: .opacity),
                        removal: .move(edge: edge(for: played.position)).combined(with: .opacity)
                    ))
                    .id(played.card.id)
            }
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

    private var humanHand: some View {
        let cards = viewModel.handsByPosition[.south] ?? []
        let legal = Set(viewModel.humanLegalMoves.map { $0.id })
        let isHumanTurn = viewModel.currentPlayerTurn == .south && (viewModel.phase == .playing)

        return HStack(spacing: -14) {
            ForEach(cards) { card in
                CardView(card: card, width: 62)
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
