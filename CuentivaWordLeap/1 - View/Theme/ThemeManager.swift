import Observation
import SwiftUI

enum WordLeapTheme: String, CaseIterable, Identifiable {
    case system, storybook, sunrise, forest, ocean, twilight, midnight

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .twilight, .midnight: .dark
        case .storybook, .sunrise, .forest, .ocean: .light
        }
    }
    var tint: Color {
        switch self {
        case .system: .orange
        case .storybook: .brown
        case .sunrise: .red
        case .forest: .green
        case .ocean, .twilight, .midnight: .mint
        }
    }
    var background: Color {
        switch self {
        case .system: Color(.systemGroupedBackground)
        case .storybook: Color(red: 0.94, green: 0.89, blue: 0.78)
        case .sunrise: Color(red: 1, green: 0.91, blue: 0.82)
        case .forest: Color(red: 0.86, green: 0.93, blue: 0.84)
        case .ocean: Color(red: 0.84, green: 0.94, blue: 0.96)
        case .twilight: Color(red: 0.13, green: 0.10, blue: 0.25)
        case .midnight: Color(red: 0.03, green: 0.08, blue: 0.16)
        }
    }
}

@MainActor @Observable
final class ThemeManager {
    private let storageKey = "selectedWordLeapTheme"
    var selectedTheme: WordLeapTheme {
        didSet { UserDefaults.standard.set(selectedTheme.rawValue, forKey: storageKey) }
    }

    init() {
        selectedTheme = WordLeapTheme(rawValue: UserDefaults.standard.string(forKey: storageKey) ?? "") ?? .system
    }

    var tint: Color { selectedTheme.tint }
    var background: Color { selectedTheme.background }
    var colorScheme: ColorScheme? { selectedTheme.colorScheme }
}
