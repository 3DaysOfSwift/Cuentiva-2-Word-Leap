import SwiftUI

struct LibraryView: View {
    @Environment(ThemeManager.self) private var themeManager
    @State private var viewModel = LibraryViewModel()
    @State private var selectedBook: StoryBook?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.books.isEmpty, viewModel.isLoading {
                    ProgressView("Opening the word worlds…")
                } else {
                    List {
                        if let errorMessage = viewModel.errorMessage {
                            Section {
                                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.orange)
                            }
                        }
                        Section("Cuentiva book levels") {
                            ForEach(viewModel.books) { book in
                                Button { selectedBook = book } label: { BookLevelRow(book: book) }
                                    .buttonStyle(.plain)
                            }
                        }
                    }
                    .refreshable { await viewModel.refresh().value }
                }
            }
            .background(themeManager.background)
            .navigationTitle("Cuentiva 2")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Refresh", systemImage: "arrow.clockwise") { _ = viewModel.refresh() } } }
            .task { await viewModel.load().value }
            .navigationDestination(item: $selectedBook) { book in GameView(book: book) }
        }
    }
}

private struct BookLevelRow: View {
    let book: StoryBook

    var body: some View {
        HStack(spacing: 14) {
            Image(book.portraitAssetName).resizable().scaledToFill().frame(width: 56, height: 56).clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title).font(.headline)
                Text(book.englishTitle).font(.subheadline).foregroundStyle(.secondary)
                Text("\(book.storyteller) · \(book.wordCount) word platforms").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "play.circle.fill").font(.title2).foregroundStyle(.orange)
        }
        .padding(.vertical, 5)
        .accessibilityLabel("\(book.title), a level with \(book.wordCount) Spanish words")
    }
}
