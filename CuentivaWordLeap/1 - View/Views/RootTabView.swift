import SwiftUI

struct RootTabView: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        TabView {
            Tab("Adventure", systemImage: "books.vertical.fill") {
                LibraryView()
                    .toolbarColorScheme(.dark, for: .tabBar)
                    .toolbarBackground(themeManager.worldShadow, for: .tabBar)
                    .toolbarBackground(.visible, for: .tabBar)
            }
            Tab("Settings", systemImage: "gearshape.fill") {
                SettingsView()
                    .toolbarColorScheme(.dark, for: .tabBar)
                    .toolbarBackground(themeManager.worldShadow, for: .tabBar)
                    .toolbarBackground(.visible, for: .tabBar)
            }
        }
        .tint(themeManager.worldAccent)
    }
}
