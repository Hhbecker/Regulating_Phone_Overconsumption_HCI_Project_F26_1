//  TouchGrassApp.swift  — replaces the one Xcode generated.

import SwiftUI
import UserNotifications
import Combine

@main
struct TouchGrassApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = RuleStore()
    @ObservedObject private var screenTime = ScreenTimeManager.shared
    @ObservedObject private var router = Router.shared
    @AppStorage("didOnboard") private var didOnboard = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            Group {
                if didOnboard { HomeView() } else { OnboardingFlow() }
            }
            .tint(.tgForest)
            .environmentObject(store)
            .environmentObject(screenTime)
            .sheet(item: $router.unlockRule) { rule in
                UnlockFlowView(rule: rule)
                    .environmentObject(screenTime)
                    .interactiveDismissDisabled()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                screenTime.refreshStatus()
                router.checkPendingUnlock()
            }
        }
    }
}

/// Decides which sheet to show when the app opens from a shield notification.
@MainActor
final class Router: ObservableObject {
    static let shared = Router()
    @Published var unlockRule: Rule?

    func checkPendingUnlock() {
        guard unlockRule == nil,
              let idString = Shared.defaults.string(forKey: Shared.pendingUnlockKey),
              let id = UUID(uuidString: idString),
              let rule = RuleArchive.rule(withID: id) else { return }
        unlockRule = rule
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // Tapping the "Your obstacle is ready" notification lands here.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        await MainActor.run { Router.shared.checkPendingUnlock() }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
