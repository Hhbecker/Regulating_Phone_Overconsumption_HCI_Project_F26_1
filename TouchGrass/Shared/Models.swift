//  Models.swift
//  Target membership: TouchGrass app + ALL THREE extensions.

import Foundation
import FamilyControls

enum ObstacleKind: String, Codable, CaseIterable, Identifiable {
    case timer, puzzle, math, steps, grayscale

    var id: String { rawValue }

    var title: String {
        switch self {
        case .timer: "Countdown timer"
        case .puzzle: "Sliding puzzle"
        case .math: "Mental math"
        case .steps: "Step goal"
        case .grayscale: "Grayscale"
        }
    }

    var shortTitle: String {
        switch self {
        case .timer: "Timer"
        case .puzzle: "Puzzle"
        case .math: "Math"
        case .steps: "Steps"
        case .grayscale: "Grayscale"
        }
    }

    var detail: String {
        switch self {
        case .timer: "Wait out 10 seconds before the app opens."
        case .puzzle: "Slide the tiles back into order, 1 to 8."
        case .math: "Solve one problem in your head, correctly."
        case .steps: "Hit 1,000 steps today to unlock."
        case .grayscale: "The app opens in black and white."
        }
    }

    var symbol: String {
        switch self {
        case .timer: "timer"
        case .puzzle: "square.grid.3x3"
        case .math: "plus.forwardslash.minus"
        case .steps: "figure.walk"
        case .grayscale: "circle.lefthalf.filled"
        }
    }
}

enum Trigger: Codable, Equatable {
    case onOpen
    case afterMinutes(Int)
}

struct Rule: Codable, Identifiable, Equatable {
    var id = UUID()
    var name = "New rule"
    var selection = FamilyActivitySelection()
    var obstacles: [ObstacleKind] = [.timer]          // run in this order
    var trigger: Trigger = .onOpen
    var weekdays: Set<Int> = Set(1...7)               // Calendar weekday: 1 = Sunday … 7 = Saturday
    var allDay = true
    var start = DateComponents(hour: 22, minute: 0)
    var end = DateComponents(hour: 2, minute: 0)
    var unlockMinutes = 15                            // Screen Time schedules can't be shorter than 15 min
    var isEnabled = true

    var appCount: Int {
        selection.applicationTokens.count + selection.categoryTokens.count + selection.webDomainTokens.count
    }

    func appliesToday(_ date: Date = .now) -> Bool {
        weekdays.contains(Calendar.current.component(.weekday, from: date))
    }

    /// True if this rule's day/time window covers `date`.
    func isActive(at date: Date = .now) -> Bool {
        guard isEnabled, appliesToday(date) else { return false }
        if allDay { return true }
        let cal = Calendar.current
        let now = cal.component(.hour, from: date) * 60 + cal.component(.minute, from: date)
        let s = (start.hour ?? 0) * 60 + (start.minute ?? 0)
        let e = (end.hour ?? 0) * 60 + (end.minute ?? 0)
        return s <= e ? (now >= s && now < e) : (now >= s || now < e)   // handles overnight windows
    }
}

/// Rules live in the App Group so the extensions can read them.
enum RuleArchive {
    static func load() -> [Rule] {
        guard let data = Shared.defaults.data(forKey: Shared.rulesKey),
              let rules = try? JSONDecoder().decode([Rule].self, from: data) else { return [] }
        return rules
    }

    static func save(_ rules: [Rule]) {
        if let data = try? JSONEncoder().encode(rules) {
            Shared.defaults.set(data, forKey: Shared.rulesKey)
        }
    }

    static func rule(withID id: UUID) -> Rule? {
        load().first { $0.id == id }
    }
}
