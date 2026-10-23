import SwiftUI

private struct WorldPanel: ViewModifier {
    @Environment(ThemeManager.self) private var themeManager
    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(themeManager.worldPanel)
                    .overlay {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .strokeBorder(themeManager.worldAccent.opacity(0.38), lineWidth: 1)
                    }
            }
            .shadow(color: .black.opacity(0.24), radius: 12, y: 6)
    }
}

extension View {
    func worldPanel(cornerRadius: CGFloat = 22) -> some View {
        modifier(WorldPanel(radius: cornerRadius))
    }

    func worldNavigation() -> some View {
        toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
