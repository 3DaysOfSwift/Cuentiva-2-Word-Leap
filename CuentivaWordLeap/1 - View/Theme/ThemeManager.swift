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

    // Illustrated screens keep light ink on dark surfaces in every colour theme.
    var worldText: Color { Color(red: 1, green: 0.96, blue: 0.86) }
    var worldSecondaryText: Color { Color(red: 0.83, green: 0.85, blue: 0.86) }
    var worldShadow: Color { Color(red: 0.025, green: 0.055, blue: 0.10) }
    var worldAccent: Color {
        switch selectedTheme {
        case .system, .storybook: Color(red: 1, green: 0.78, blue: 0.40)
        case .sunrise: Color(red: 1, green: 0.70, blue: 0.48)
        case .forest: Color(red: 0.64, green: 0.89, blue: 0.60)
        case .ocean: Color(red: 0.49, green: 0.86, blue: 0.94)
        case .twilight: Color(red: 0.83, green: 0.72, blue: 1)
        case .midnight: Color(red: 0.66, green: 0.81, blue: 1)
        }
    }
    var worldPanel: Color {
        switch selectedTheme {
        case .system: Color(red: 0.035, green: 0.09, blue: 0.15).opacity(0.90)
        case .storybook: Color(red: 0.19, green: 0.12, blue: 0.08).opacity(0.92)
        case .sunrise: Color(red: 0.24, green: 0.10, blue: 0.09).opacity(0.92)
        case .forest: Color(red: 0.045, green: 0.15, blue: 0.12).opacity(0.92)
        case .ocean: Color(red: 0.035, green: 0.13, blue: 0.21).opacity(0.92)
        case .twilight: Color(red: 0.15, green: 0.08, blue: 0.24).opacity(0.92)
        case .midnight: Color(red: 0.025, green: 0.045, blue: 0.10).opacity(0.94)
        }
    }
}
