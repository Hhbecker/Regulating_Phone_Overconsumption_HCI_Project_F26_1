//  RuleStore.swift

import Foundation
import Combine

@MainActor
final class RuleStore: ObservableObject {
    @Published private(set) var rules: [Rule] = RuleArchive.load()

    func save(_ rule: Rule) {
        if let i = rules.firstIndex(where: { $0.id == rule.id }) {
            rules[i] = rule
        } else {
            rules.append(rule)
        }
        RuleArchive.save(rules)
        ScreenTimeManager.shared.apply(rule)
    }

    func delete(_ rule: Rule) {
        rules.removeAll { $0.id == rule.id }
        RuleArchive.save(rules)
        ScreenTimeManager.shared.remove(rule)
    }
}
