import AudioToolbox

enum GameSound {
    case cardPlay
    case trickWin
    case handEnd
    case illegalMove

    var systemSoundID: SystemSoundID {
        switch self {
        case .cardPlay: return 1104
        case .trickWin: return 1025
        case .handEnd: return 1026
        case .illegalMove: return 1053
        }
    }
}

enum SoundPlayer {
    static var isEnabled = true

    static func play(_ sound: GameSound) {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(sound.systemSoundID)
    }
}
