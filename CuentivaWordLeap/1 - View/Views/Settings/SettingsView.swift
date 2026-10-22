import SwiftUI

struct SettingsView: View {
    @Environment(ThemeManager.self) private var themeManager
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        @Bindable var themeManager = themeManager

        NavigationStack {
            List {
                Section("Appearance") {
                    Picker("Colour theme", selection: $themeManager.selectedTheme) {
                        ForEach(WordLeapTheme.allCases) { theme in
                            Text(theme.title).tag(theme)
                        }
                    }
                }

                Section("About") {
                    LabeledContent("App") {
                        Label("Cuentiva 2: Word Leap", systemImage: "figure.jump.rope")
                            .foregroundStyle(themeManager.tint)
                    }
                    LabeledContent("Learning content") {
                        Text(viewModel.contentAttribution)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(.secondary)
                    }
                    LabeledContent("Architecture") {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(viewModel.architecture)
                            Text("Built with SwiftUI and SpriteKit.")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
                    LabeledContent("Version", value: viewModel.version)
                }
            }
            .scrollContentBackground(.hidden)
            .background(themeManager.background)
            .navigationTitle("Settings")
        }
    }
}
