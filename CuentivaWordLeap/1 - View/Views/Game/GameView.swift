import SpriteKit
import SwiftUI

struct GameView: View {
    let book: StoryBook
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = GameViewModel()
    @State private var isReadingBook = false

    var body: some View {
        ZStack {
            if let scene = viewModel.scene {
                SpriteView(scene: scene, isPaused: scenePhase != .active, options: [.shouldCullNonVisibleNodes])
                    .allowsHitTesting(!viewModel.isDeathPresented && !viewModel.isLevelComplete)
                    .ignoresSafeArea()
            } else {
                Color(red: 0.03, green: 0.10, blue: 0.26).ignoresSafeArea()
                ProgressView("Building \(book.title)…").tint(.white).foregroundStyle(.white)
            }

            VStack(spacing: 16) {
                GameHUD(book: currentBook, wordsRead: viewModel.wordsRead, wordCount: activeWordCount,
                        coins: viewModel.collectedDoubloons, leave: leave)
                Spacer()
                if !viewModel.isLevelComplete {
                    GameReadingCard(word: viewModel.lastReadWord)
                        .allowsHitTesting(false)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .allowsHitTesting(!viewModel.isDeathPresented)
            .accessibilityHidden(viewModel.isDeathPresented)

            if viewModel.isBookRevealed {
                Color.black.opacity(0.32).ignoresSafeArea().allowsHitTesting(false)
                BookCompletionReveal(book: currentBook, title: viewModel.completionTitle,
                    coins: viewModel.collectedDoubloons, hasNextLevel: viewModel.nextBook != nil,
                    read: { isReadingBook = true }, next: viewModel.startNextLevel, leave: leave)
                    .padding(.top, 70)
                    .transition(.opacity)
            } else if viewModel.isLevelComplete {
                Text(viewModel.completionTitle)
                    .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                    .multilineTextAlignment(.center).foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.7), radius: 8)
                    .padding(24).allowsHitTesting(false)
            }

            if viewModel.isDeathPresented {
                GameOverSummary(statistics: viewModel.gameOverStatistics, retry: retry, leave: leave)
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: viewModel.isDeathPresented)
        .animation(.easeOut(duration: 0.3), value: viewModel.isBookRevealed)
        .onChange(of: scenePhase) { _, _ in viewModel.scene?.resetFrameClock() }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.prepare(book, reduceMotion: reduceMotion).value
        }
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $isReadingBook) {
            NavigationStack {
                CompletedBookPages(book: currentBook)
                    .navigationTitle(currentBook.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { isReadingBook = false }
                        }
                    }
            }
        }
    }

    private var currentBook: StoryBook { viewModel.activeLevel?.book ?? book }

    private var activeWordCount: Int {
        viewModel.activeLevel?.words.count ?? currentBook.platformCount
    }

    private func leave() {
        viewModel.leaveLevel()
        dismiss()
    }

    private func retry() {
        viewModel.retry()
    }
}

private struct GameHUD: View {
    let book: StoryBook
    let wordsRead: Int
    let wordCount: Int
    let coins: Int
    let leave: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: leave) {
                Image(systemName: "xmark")
                    .font(.headline.weight(.bold))
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .foregroundStyle(.white)

            VStack(spacing: 2) {
                Text(book.title).font(.headline.weight(.heavy)).lineLimit(1)
                Text("\(wordsRead) / \(wordCount) platforms")
                    .font(.caption.weight(.bold)).monospacedDigit().opacity(0.82)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .padding(.horizontal, 14)
            .background(.black.opacity(0.24), in: Capsule())

            HStack(spacing: 4) {
                DoubloonArtwork(size: 28)
                Text("\(coins)").font(.headline.monospacedDigit()).foregroundStyle(.white)
            }
            .padding(9)
            .background(.black.opacity(0.35), in: Capsule())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(coins) doubloons collected")
        }
    }
}

private struct GameReadingCard: View {
    let word: String

    var body: some View {
        Text(word.isEmpty ? "Touch to jump. Hold left or right to steer." : word)
            .font(.title3.weight(.bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background(.black.opacity(0.38), in: Capsule())
    }
}
