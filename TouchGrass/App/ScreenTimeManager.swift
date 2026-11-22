//  ScreenTimeManager.swift
//  Talks to Apple's Screen Time frameworks. These only really work on a physical iPhone.

import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import Combine

@MainActor
final class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()

    @Published private(set) var isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
    private let center = DeviceActivityCenter()

    func refreshStatus() {
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        } catch {
            print("Screen Time authorization failed:", error)
        }
        refreshStatus()
    }

    /// Starts (or restarts) monitoring for a rule. The DeviceActivityMonitor extension
    /// then turns shields on and off at the right times, even when TouchGrass isn't running.
    func apply(_ rule: Rule) {
        remove(rule)
        guard rule.isEnabled, isAuthorized else { return }

        var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
        if case .afterMinutes(let minutes) = rule.trigger {
            events[.timeLimit] = DeviceActivityEvent(
                applications: rule.selection.applicationTokens,
                categories: rule.selection.categoryTokens,
                webDomains: rule.selection.webDomainTokens,
                threshold: DateComponents(minute: minutes)
            )
        }

        do {
            try center.startMonitoring(.rule(rule.id), during: schedule(for: rule), events: events)
        } catch {
            print("Could not start monitoring:", error)
        }

        // If we're already inside the window, shield right away rather than waiting.
        if case .onOpen = rule.trigger, rule.isActive() {
            Shield.apply(rule)
        }
    }

    func remove(_ rule: Rule) {
        center.stopMonitoring([.rule(rule.id), .unlock(rule.id)])
        Shield.lift(rule.id)
    }

    /// Called after the person clears their obstacles. Lifts the shield and starts a
    /// one-off window; when it ends, the monitor extension puts the shield back.
    func grantUnlock(for rule: Rule) {
        Shield.lift(rule.id)
        Shared.defaults.removeObject(forKey: Shared.pendingUnlockKey)

        let now = Date()
        let end = now.addingTimeInterval(TimeInterval(max(rule.unlockMinutes, 15) * 60))
        let cal = Calendar.current
        let window = DeviceActivitySchedule(
            intervalStart: cal.dateComponents([.hour, .minute, .second], from: now),
            intervalEnd: cal.dateComponents([.hour, .minute, .second], from: end),
            repeats: false
        )
        center.stopMonitoring([.unlock(rule.id)])
        do {
            try center.startMonitoring(.unlock(rule.id), during: window)
        } catch {
            print("Could not start unlock window:", error)
        }
    }

    private func schedule(for rule: Rule) -> DeviceActivitySchedule {
        if rule.allDay {
            return DeviceActivitySchedule(
                intervalStart: DateComponents(hour: 0, minute: 0),
                intervalEnd: DateComponents(hour: 23, minute: 59),
                repeats: true
            )
        }
        // Days of the week are checked inside the monitor extension.
        return DeviceActivitySchedule(intervalStart: rule.start, intervalEnd: rule.end, repeats: true)
    }
}
