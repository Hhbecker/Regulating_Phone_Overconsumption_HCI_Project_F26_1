import SwiftUI
internal import Combine

@MainActor
final class RulesStore: ObservableObject {
    static let limit = 5

    @Published private(set) var rules: [ObstacleRule] = []

    var canAdd: Bool { rules.count < Self.limit }

    func contains(_ rule: ObstacleRule) -> Bool {
        rules.contains { $0.id == rule.id }
    }

    /// 1-based position used for names like "Rule 2". New rules get the next number.
    func number(for rule: ObstacleRule) -> Int {
        (rules.firstIndex { $0.id == rule.id } ?? rules.count) + 1
    }

    func save(_ rule: ObstacleRule) {
        if let index = rules.firstIndex(where: { $0.id == rule.id }) {
            rules[index] = rule
        } else if canAdd {
            rules.append(rule)
        }
    }

    func delete(_ rule: ObstacleRule) {
        rules.removeAll { $0.id == rule.id }
    }
}
