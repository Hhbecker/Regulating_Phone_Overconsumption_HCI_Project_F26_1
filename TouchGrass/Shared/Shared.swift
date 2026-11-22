//  Shared.swift
//  Target membership: TouchGrass app + ALL THREE extensions.

import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

enum Shared {
    /// Change this to the App Group you create in Signing & Capabilities.
    /// It must be identical in the app and every extension.
    static let appGroupID = "group.com.yourname.touchgrass"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    static let rulesKey = "rules.v1"
    /// Set by the Shield Action extension when someone taps "Face my obstacle".
    static let pendingUnlockKey = "pendingUnlockRuleID"
}

// MARK: - Names used by Screen Time APIs

extension DeviceActivityName {
    /// The repeating schedule for a rule (e.g. every day 10pm–2am).
    static func rule(_ id: UUID) -> Self { Self("rule.\(id.uuidString)") }
    /// A one-off unlock window after someone clears their obstacle.
    static func unlock(_ id: UUID) -> Self { Self("unlock.\(id.uuidString)") }
}

extension DeviceActivityEvent.Name {
    static let timeLimit = Self("timeLimit")
}

extension ManagedSettingsStore.Name {
    static func rule(_ id: UUID) -> Self { Self("rule.\(id.uuidString)") }
}

// MARK: - Applying and lifting shields

enum Shield {
    static func apply(_ rule: Rule) {
        let store = ManagedSettingsStore(named: .rule(rule.id))
        let s = rule.selection
        store.shield.applications = s.applicationTokens.isEmpty ? nil : s.applicationTokens
        store.shield.applicationCategories = s.categoryTokens.isEmpty ? nil : .specific(s.categoryTokens)
        store.shield.webDomains = s.webDomainTokens.isEmpty ? nil : s.webDomainTokens
    }

    static func lift(_ ruleID: UUID) {
        ManagedSettingsStore(named: .rule(ruleID)).clearAllSettings()
    }
}
