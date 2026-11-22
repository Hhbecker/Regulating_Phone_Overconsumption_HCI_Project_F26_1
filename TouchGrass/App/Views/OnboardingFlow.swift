//  OnboardingFlow.swift — Welcome → Pick obstacles → Permissions

import SwiftUI
import UserNotifications

struct OnboardingFlow: View {
    @AppStorage("didOnboard") private var didOnboard = false
    @State private var path: [Step] = []

    enum Step: Hashable { case obstacles, permissions }

    var body: some View {
        NavigationStack(path: $path) {
            WelcomeView { path.append(.obstacles) }
                .navigationDestination(for: Step.self) { step in
                    switch step {
                    case .obstacles: ObstacleMenuView { path.append(.permissions) }
                    case .permissions: PermissionsView { didOnboard = true }
                    }
                }
        }
    }
}

struct WelcomeView: View {
    var onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            Image(systemName: "leaf.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.tgForest)
            Text("TouchGrass")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(Color.tgInk)
            Text("Put a small obstacle between you and the apps you scroll too much. You choose the obstacles and when they kick in.")
                .font(.title3)
                .foregroundStyle(Color.tgMuted)
            Spacer()
            Button("Get started", action: onContinue)
                .buttonStyle(TGPrimaryButtonStyle())
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.tgMint.ignoresSafeArea())
    }
}

struct PermissionsView: View {
    @EnvironmentObject private var screenTime: ScreenTimeManager
    var onDone: () -> Void
    @State private var notificationsAllowed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Two quick permissions")
                .font(.tgTitle)
                .foregroundStyle(Color.tgInk)

            permissionCard(
                icon: "hourglass",
                title: "Screen Time",
                text: "Lets TouchGrass put obstacles in front of the apps you pick. Your app list stays on your phone.",
                granted: screenTime.isAuthorized
            ) {
                Task { await screenTime.requestAuthorization() }
            }

            permissionCard(
                icon: "bell.badge",
                title: "Notifications",
                text: "When you tap a blocked app's shield, a notification brings you here to face your obstacle.",
                granted: notificationsAllowed
            ) {
                Task {
                    let ok = try? await UNUserNotificationCenter.current()
                        .requestAuthorization(options: [.alert, .sound])
                    notificationsAllowed = ok ?? false
                }
            }

            Spacer()
            Button("Continue", action: onDone)
                .buttonStyle(TGPrimaryButtonStyle())
        }
        .padding(24)
        .background(Color.tgMint.ignoresSafeArea())
        .task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            notificationsAllowed = settings.authorizationStatus == .authorized
        }
    }

    private func permissionCard(icon: String, title: String, text: String,
                                granted: Bool, action: @escaping () -> Void) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 52, height: 52)
                .background(Color.tgChip, in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(Color.tgForest)
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.headline).foregroundStyle(Color.tgInk)
                Text(text).font(.subheadline).foregroundStyle(Color.tgMuted)
                if granted {
                    Label("Allowed", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.tgForest)
                } else {
                    Button("Allow", action: action)
                        .font(.subheadline.bold())
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.tgCard, in: RoundedRectangle(cornerRadius: 22))
    }
}
