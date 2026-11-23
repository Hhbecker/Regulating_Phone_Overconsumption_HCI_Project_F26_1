import Foundation

enum Obstacle: String, CaseIterable, Identifiable, Hashable, Codable {
    case timer, puzzle, math, steps, grayscale

    var id: String { rawValue }

    /// Short label used on rule chips.
    var chipName: String {
        switch self {
        case .timer:     return "Timer"
        case .puzzle:    return "Puzzle"
        case .math:      return "Math"
        case .steps:     return "Steps"
        case .grayscale: return "Grayscale"
        }
    }

    /// Name used in rule summaries.
    var summaryName: String {
        switch self {
        case .timer:     return "10-sec timer"
        case .puzzle:    return "Puzzle"
        case .math:      return "Mental math"
        case .steps:     return "1,000 steps"
        case .grayscale: return "Grayscale"
        }
    }

    /// Title shown in the obstacles menu.
    var title: String {
        switch self {
        case .timer:     return "Countdown timer"
        case .puzzle:    return "Sliding puzzle"
        case .math:      return "Mental math"
        case .steps:     return "Step goal"
        case .grayscale: return "Grayscale"
        }
    }

    var detail: String {
        switch self {
        case .timer:     return "Wait out 10 seconds before the app opens."
        case .puzzle:    return "Slide the tiles back into order, 1 to 8."
        case .math:      return "Solve one problem in your head, correctly."
        case .steps:     return "Hit 1,000 steps today to unlock."
        case .grayscale: return "The app opens in black and white."
        }
    }

    /// SF Symbol stand-ins for the prototype's custom icons.
    var symbol: String {
        switch self {
        case .timer:     return "timer"
        case .puzzle:    return "puzzlepiece"
        case .math:      return "plus.forwardslash.minus"
        case .steps:     return "figure.walk"
        case .grayscale: return "circle.lefthalf.filled"
        }
    }
}
