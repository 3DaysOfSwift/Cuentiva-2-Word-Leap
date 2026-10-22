import SpriteKit
import SwiftUI

struct GameView: View {
    let book: StoryBook
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = GameViewModel()
    @State private var scene: WordLeapScene?

    var body: some View {
        ZStack {
            if let scene {
                SpriteView(scene: scene, options: [.shouldCullNonVisibleNodes])
                    .ignoresSafeArea()
            } else {
                Color(red: 0.03, green: 0.10, blue: 0.26).ignoresSafeArea()
                ProgressView("Building \(book.title)…").tint(.white).foregroundStyle(.white)
            }

            VStack(spacing: 16) {
                GameHUD(book: book, wordsRead: viewModel.wordsRead, wordCount: activeWordCount, leave: leave)
                Spacer()
                if viewModel.isLevelComplete {
                    GameCompletionCard(bookTitle: book.title, leave: leave)
                } else {
                    GameReadingCard(word: viewModel.lastReadWord)
                        .allowsHitTesting(false)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.prepare(book).value
            if let activeLevel = viewModel.activeLevel {
                scene = WordLeapScene(size: CGSize(width: 390, height: 740), levelPlan: activeLevel) { wordIndex, word in
                    viewModel.recordLanding(at: wordIndex, word: word)
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }

    private var activeWordCount: Int {
        viewModel.activeLevel?.words.count ?? book.wordCount
    }

    private func leave() {
        viewModel.leaveLevel()
        dismiss()
    }
}

private struct GameHUD: View {
    let book: StoryBook
    let wordsRead: Int
    let wordCount: Int
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
                Text("\(wordsRead) / \(wordCount) words")
                    .font(.caption.weight(.bold)).monospacedDigit().opacity(0.82)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .padding(.horizontal, 14)
            .background(.black.opacity(0.24), in: Capsule())

            Image(book.portraitAssetName)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .overlay(Circle().stroke(.white.opacity(0.8), lineWidth: 2))
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

private struct GameCompletionCard: View {
    let bookTitle: String
    let leave: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "star.fill").font(.largeTitle).foregroundStyle(.yellow)
            Text("Level complete").font(.title2.weight(.heavy)).foregroundStyle(.white)
            Text("You leapt through \(bookTitle).").foregroundStyle(.white.opacity(0.82))
            Button("Choose another story", action: leave).buttonStyle(.borderedProminent).tint(.orange)
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
    }
}
