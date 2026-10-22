import SwiftUI

/// A book's home on the story map. Storyteller-specific outposts make the
/// collection feel like a world to explore rather than a table of records.
struct StoryOutpost: View {
    let book: StoryBook
    let index: Int
    let isConquered: Bool

    private var style: OutpostStyle { OutpostStyle(storyteller: book.storyteller) }
    private var isLeading: Bool { index.isMultiple(of: 2) }

    var body: some View {
        ZStack(alignment: isLeading ? .leading : .trailing) {
            MapTrail(isLeading: isLeading)
                .padding(.horizontal, 34)

            VStack(alignment: isLeading ? .leading : .trailing, spacing: 10) {
                ZStack(alignment: .bottom) {
                    OutpostBuilding(style: style, isConquered: isConquered)
                        .frame(width: 190, height: 150)

                    Image(book.portraitAssetName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 58, height: 58)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white.opacity(0.8), lineWidth: 3))
                        .shadow(color: .black.opacity(0.18), radius: 6, y: 3)
                        .offset(y: 20)
                }
                .padding(.bottom, 15)

                VStack(alignment: isLeading ? .leading : .trailing, spacing: 4) {
                    Text(book.title)
                        .font(.headline.weight(.bold))
                        .multilineTextAlignment(isLeading ? .leading : .trailing)
                        .lineLimit(2)
                    Text(book.englishTitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(isLeading ? .leading : .trailing)
                        .lineLimit(1)
                    Label(
                        isConquered ? "Conquered" : "\(book.platformCount) platforms",
                        systemImage: isConquered ? "flag.checkered" : "arrow.up.right.circle.fill"
                    )
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isConquered ? style.accent : .secondary)
                }
                .frame(width: 224, alignment: isLeading ? .leading : .trailing)
                .padding(14)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .frame(maxWidth: .infinity, alignment: isLeading ? .leading : .trailing)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
        }
        .frame(minHeight: 274)
        .contentShape(Rectangle())
        .accessibilityLabel("\(book.title), \(isConquered ? "conquered" : "ready to play")")
        .accessibilityHint("Opens this book's word-leap level")
    }
}

private struct MapTrail: View {
    let isLeading: Bool

    var body: some View {
        HStack {
            if isLeading { Spacer(minLength: 0) }
            VStack(spacing: 4) {
                Circle().fill(.secondary.opacity(0.25)).frame(width: 8, height: 8)
                Capsule().fill(.secondary.opacity(0.18)).frame(width: 3, height: 192)
                Circle().fill(.secondary.opacity(0.25)).frame(width: 8, height: 8)
            }
            if !isLeading { Spacer(minLength: 0) }
        }
    }
}

private struct OutpostBuilding: View {
    let style: OutpostStyle
    let isConquered: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            Circle()
                .fill(style.accent.opacity(0.18))
                .frame(width: 176, height: 92)
                .offset(y: 12)

            HStack(alignment: .bottom, spacing: 7) {
                tower(height: 78)
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .fill(style.wall)
                    .frame(width: 94, height: 96)
                    .overlay {
                        VStack(spacing: 9) {
                            Image(systemName: style.symbol)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white.opacity(0.92))
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.white.opacity(0.7))
                                .frame(width: 28, height: 22)
                        }
                    }
                tower(height: 70)
            }

            if isConquered {
                Image(systemName: "flag.checkered.circle.fill")
                    .font(.title)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, style.accent)
                    .offset(x: 57, y: -91)
            } else {
                Image(systemName: "play.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(style.wall)
                    .frame(width: 34, height: 34)
                    .background(.white, in: Circle())
                    .offset(x: 57, y: -91)
            }
        }
    }

    private func tower(height: CGFloat) -> some View {
        VStack(spacing: -4) {
            Triangle()
                .fill(style.roof)
                .frame(width: 42, height: 35)
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(style.wall.opacity(0.88))
                .frame(width: 40, height: height)
                .overlay(alignment: .top) {
                    Capsule()
                        .fill(.white.opacity(0.55))
                        .frame(width: 9, height: 19)
                        .padding(.top, 12)
                }
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

private struct OutpostStyle {
    let wall: Color
    let roof: Color
    let accent: Color
    let symbol: String

    init(storyteller: String) {
        switch storyteller {
        case "Pipa": (wall, roof, accent, symbol) = (.teal, .orange, .mint, "sailboat.fill")
        case "Musgo": (wall, roof, accent, symbol) = (.green, .brown, .mint, "leaf.fill")
        case "Zumi": (wall, roof, accent, symbol) = (.cyan, .indigo, .cyan, "sparkles")
        case "Luma": (wall, roof, accent, symbol) = (.indigo, .purple, .purple, "moon.stars.fill")
        case "Nube": (wall, roof, accent, symbol) = (.blue, .cyan, .blue, "cloud.fill")
        case "Tilo": (wall, roof, accent, symbol) = (.mint, .green, .green, "book.closed.fill")
        case "Mora": (wall, roof, accent, symbol) = (.pink, .purple, .pink, "crown.fill")
        case "Faro": (wall, roof, accent, symbol) = (.orange, .red, .orange, "light.beacon.max.fill")
        default: (wall, roof, accent, symbol) = (.blue, .indigo, .blue, "star.fill")
        }
    }
}
