import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            Tab("Library", systemImage: "books.vertical.fill") { LibraryView() }
            Tab("Settings", systemImage: "gearshape.fill") { SettingsView() }
        }
    }
}
