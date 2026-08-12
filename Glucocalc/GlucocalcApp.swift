import SwiftUI

@main
struct GlucocalcApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Compact, resizable window on iPad (no effect on iPhone).
        .defaultSize(width: 420, height: 620)
        .windowResizability(.contentMinSize)
    }
}
