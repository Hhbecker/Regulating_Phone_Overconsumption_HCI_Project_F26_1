import Foundation

enum Weekday: Int, CaseIterable, Identifiable, Hashable, Codable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday

    var id: Int { rawValue }

    var initial: String {
        switch self {
        case .monday:    return "M"
        case .tuesday:   return "T"
        case .wednesday: return "W"
        case .thursday:  return "T"
        case .friday:    return "F"
        case .saturday:  return "S"
        case .sunday:    return "S"
        }
    }

    var shortName: String {
        switch self {
        case .monday:    return "Mon"
        case .tuesday:   return "Tue"
        case .wednesday: return "Wed"
        case .thursday:  return "Thu"
        case .friday:    return "Fri"
        case .saturday:  return "Sat"
        case .sunday:    return "Sun"
        }
    }

    var fullName: String {
        switch self {
        case .monday:    return "Monday"
        case .tuesday:   return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday:  return "Thursday"
        case .friday:    return "Friday"
        case .saturday:  return "Saturday"
        case .sunday:    return "Sunday"
        }
    }
}

enum RuleTrigger: Hashable, Codable {
    case onOpen
    case afterDelay
}

enum SocialApp {
    static let all = [
        "Instagram", "TikTok", "Snapchat", "X", "YouTube",
        "Reddit", "Facebook", "Threads", "Pinterest"
    ]
}

struct ObstacleRule: Identifiable, Hashable, Codable {
    var id = UUID()
    var obstacles: [Obstacle] = [.timer]          // order = order they run
    var trigger: RuleTrigger = .onOpen
    var minutes: Int = 15                          // used when trigger == .afterDelay
    var days: Set<Weekday> = Set(Weekday.allCases)
    var allDay: Bool = false
    var start: Date = ObstacleRule.time(hour: 22)
    var end: Date = ObstacleRule.time(hour: 2)
    var apps: [String] = []                        // selection order

    static let minMinutes = 5
    static let maxMinutes = 120

    static func time(hour: Int, minute: Int = 0) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }

    // MARK: Validation

    var missingItems: [String] {
        var items: [String] = []
        if obstacles.isEmpty { items.append("an obstacle") }
        if days.isEmpty { items.append("a day") }
        if apps.isEmpty { items.append("at least one app") }
        return items
    }

    var isValid: Bool { missingItems.isEmpty }

    var runsOvernight: Bool {
        guard !allDay else { return false }
        return Self.minutesOfDay(end) < Self.minutesOfDay(start)
    }

    private static func minutesOfDay(_ date: Date) -> Int {
        let c = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (c.hour ?? 0) * 60 + (c.minute ?? 0)
    }

    // MARK: Summary text (used by the rule cards and the "all set" screen)

    var obstaclesText: String {
        obstacles.map(\.summaryName).joined(separator: " + ")
    }

    var triggerText: String {
        switch trigger {
        case .onOpen:     return "As soon as the app opens"
        case .afterDelay: return "After \(minutes) min in the app"
        }
    }

    var daysText: String {
        let set = days
        if set.count == 7 { return "Every day" }
        if set == Self.weekdays { return "Weekdays" }
        if set == Self.weekend { return "Weekends" }
        if set == Self.schoolNights { return "School nights (Sun–Thu)" }
        return Weekday.allCases.filter(set.contains).map(\.shortName).joined(separator: ", ")
    }

    var scheduleText: String {
        let time = allDay
            ? "all day"
            : "\(start.formatted(date: .omitted, time: .shortened))–\(end.formatted(date: .omitted, time: .shortened))"
        return "\(daysText), \(time)"
    }

    var appsText: String {
        if apps.count <= 3 { return apps.joined(separator: ", ") }
        return apps.prefix(3).joined(separator: ", ") + " +\(apps.count - 3) more"
    }

    // MARK: Day presets

    static let weekdays: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]
    static let weekend: Set<Weekday> = [.saturday, .sunday]
    static let schoolNights: Set<Weekday> = [.sunday, .monday, .tuesday, .wednesday, .thursday]
}
