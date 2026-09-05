import Foundation
import Combine

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english = "en"
    case portuguese = "pt-PT"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return L.t("settings.language.system")
        case .english: return "English"
        case .portuguese: return "Português"
        }
    }
}

@MainActor
final class LocalizationManager: ObservableObject {
    // Accessed from `L.t(_:)`, which is `nonisolated` so plain model types can call it synchronously.
    nonisolated(unsafe) static let shared = MainActor.assumeIsolated { LocalizationManager() }

    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: Self.storageKey)
            setLanguage(language)
        }
    }

    private static let storageKey = "app.language.override"
    // `string(_:)` is called from plain, non-actor model types (e.g. `Card.accessibilityLabel`),
    // so this state must stay safely mutable off the main actor. A lock — not `nonisolated(unsafe)` —
    // guards it, since `didSet` (main actor) and `string(_:)` (any thread) can race otherwise.
    private nonisolated(unsafe) var currentLanguage: AppLanguage = .system
    private nonisolated(unsafe) var bundle: Bundle = .main
    private nonisolated(unsafe) var cachedLanguage: AppLanguage?
    private nonisolated let lock = NSLock()

    private init() {
        let stored = UserDefaults.standard.string(forKey: Self.storageKey)
        let initial = AppLanguage(rawValue: stored ?? "system") ?? .system
        language = initial
        setLanguage(initial)
    }

    private nonisolated func setLanguage(_ newLanguage: AppLanguage) {
        lock.lock()
        currentLanguage = newLanguage
        lock.unlock()
        updateBundle()
    }

    private nonisolated func updateBundle() {
        lock.lock()
        defer { lock.unlock() }
        guard cachedLanguage != currentLanguage else { return }
        cachedLanguage = currentLanguage
        let code: String
        switch currentLanguage {
        case .system:
            bundle = .main
            return
        case .english:
            code = "en"
        case .portuguese:
            code = "pt-PT"
        }
        if let path = Bundle.main.path(forResource: code, ofType: "lproj"),
           let langBundle = Bundle(path: path) {
            bundle = langBundle
        } else {
            bundle = .main
        }
    }

    nonisolated func string(_ key: String) -> String {
        updateBundle()
        lock.lock()
        let currentBundle = bundle
        lock.unlock()
        return NSLocalizedString(key, bundle: currentBundle, comment: "")
    }
}

enum L {
    static func t(_ key: String) -> String {
        LocalizationManager.shared.string(key)
    }
}
