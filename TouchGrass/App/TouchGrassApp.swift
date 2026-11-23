import SwiftUI

@main
struct TouchGrassApp: App {
    @StateObject private var rulesStore = RulesStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(rulesStore)
        }
    }
}
