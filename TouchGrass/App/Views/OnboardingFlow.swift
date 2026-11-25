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

import SwiftUI

struct WelcomeView: View {
    var onContinue: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.tgMint.ignoresSafeArea()

            // Decorative layer, kept separate from the buttons
            Color.clear
                .overlay(alignment: .bottom) {
                    Image("GrassIllustration")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .clipped()
                        .accessibilityHidden(true)
                }
                .ignoresSafeArea()
                .allowsHitTesting(false) 

            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("TouchGrass")
                        .font(.system(size: 46, weight: .bold))   // Outfit in the prototype
                    Text("Welcome to TouchGrass, look through our menu of digital obstacles, then choose which social media apps to apply them to.")
                        .font(.system(size: 21, weight: .medium))
                        .fixedSize(horizontal: false, vertical: true)
                }

                SetupAgendaCard()

                Spacer(minLength: 0)

                VStack(spacing: 12) {
                    Button("Get started", action: onContinue)
                        .buttonStyle(TGPrimaryButtonStyle())
                }
                .padding(.bottom, 168)   // keeps the buttons above the grass
            }
            .padding(.horizontal, 28)
            .padding(.top, 40)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .foregroundStyle(Color.tgInk)
        .toolbar(.hidden, for: .navigationBar)
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
