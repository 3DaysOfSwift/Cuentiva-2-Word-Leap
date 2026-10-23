import SwiftUI

struct RootTabView: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        TabView {
            Tab("Adventure", systemImage: "books.vertical.fill") { LibraryView() }
            Tab("Settings", systemImage: "gearshape.fill") { SettingsView() }
        }
        .tint(themeManager.worldAccent)
        .toolbarColorScheme(.dark, for: .tabBar)
        .toolbarBackground(themeManager.worldPanel, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}
