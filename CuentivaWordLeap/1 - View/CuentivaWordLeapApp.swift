import SwiftUI

@main
struct CuentivaWordLeapApp: App {
    @State private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(themeManager)
                .tint(themeManager.tint)
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
}
