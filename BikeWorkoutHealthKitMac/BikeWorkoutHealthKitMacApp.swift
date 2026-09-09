import SwiftUI

@main
struct BikeWorkoutHealthKitMacApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 600, minHeight: 500)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Preferences") {
                    // Preferences implementation
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}
