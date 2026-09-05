import SwiftUI

@main
struct iSuecaApp: App {
    @StateObject private var settings = SettingsViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(settings)
        }
    }
}
