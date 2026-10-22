import SwiftUI

/// Display values prepared by GameViewModel; this component owns no gameplay rules.
struct GameStatistic: Identifiable {
    let title: String
    let value: String
    let symbol: String
    var detail: String = ""
    var id: String { title }
}

struct GameOverSummary: View {
    let statistics: [GameStatistic]
    let retry: () -> Void
    let leave: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.78).ignoresSafeArea()
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 16) {
                        Image("WordLeapSkeleton")
                            .resizable().scaledToFit()
                            .frame(height: 132)
                            .shadow(color: .cyan.opacity(0.4), radius: 24)
                            .accessibilityHidden(true)

                        VStack(spacing: 5) {
                            Text("GAME OVER")
                                .font(.system(.largeTitle, design: .rounded, weight: .black))
                                .accessibilityAddTraits(.isHeader)
                            Text("A little less skin. A lot more story.")
                                .font(.subheadline).foregroundStyle(.white.opacity(0.8))
                        }
                        .multilineTextAlignment(.center)

                        Text("THIS ADVENTURE")
                            .font(.caption.weight(.heavy)).tracking(3)
                            .foregroundStyle(.orange)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(statistics) { statistic in
                                VStack(spacing: 5) {
                                    if statistic.symbol == "doubloon" {
                                        DoubloonArtwork(size: 25)
                                    } else {
                                        Image(systemName: statistic.symbol)
                                            .font(.title3).foregroundStyle(.orange).frame(height: 25)
                                    }
                                    Text(statistic.value)
                                        .font(.system(.title2, design: .rounded, weight: .heavy))
                                        .monospacedDigit()
                                    Text(statistic.title).font(.caption.weight(.semibold))
                                    if !statistic.detail.isEmpty {
                                        Text(statistic.detail).font(.caption2).foregroundStyle(.white.opacity(0.65))
                                    }
                                }
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, minHeight: 100)
                                .padding(8)
                                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18))
                                .accessibilityElement(children: .combine)
                            }
                        }

                        Button(action: retry) {
                            Label("Continue from checkpoint", systemImage: "arrow.counterclockwise")
                                .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 16)
                        }
                        .buttonStyle(.plain).foregroundStyle(.black)
                        .background(.orange, in: Capsule())

                        Button("Back to Adventure", action: leave)
                            .font(.subheadline.weight(.semibold)).padding(12)
                    }
                    .foregroundStyle(.white)
                    .padding(24)
                    .frame(maxWidth: 440)
                    .frame(maxWidth: .infinity, minHeight: geometry.size.height)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}
