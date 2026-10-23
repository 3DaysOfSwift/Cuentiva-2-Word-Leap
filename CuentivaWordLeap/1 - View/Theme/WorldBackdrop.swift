import SwiftUI

/// Shared, non-interactive scenery for menus and reading surfaces.
struct WorldBackdrop: View {
    @Environment(ThemeManager.self) private var themeManager
    var assetName = "WorldVillage"
    var shade = 0.18
    var showsVignette = true

    var body: some View {
        GeometryReader { geometry in
            Image(assetName)
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .overlay(themeManager.worldShadow.opacity(shade))
                .overlay {
                    if showsVignette {
                        LinearGradient(
                            colors: [.black.opacity(0.25), .clear, themeManager.worldShadow.opacity(0.55)],
                            startPoint: .top, endPoint: .bottom)
                    }
                }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
