import SwiftUI

struct LibraryView: View {
    @Environment(ThemeManager.self) private var themeManager
    @State private var viewModel = LibraryViewModel()
    @State private var selectedBook: StoryBook?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.books.isEmpty, viewModel.isLoading {
                    ProgressView("Building the story map…")
                } else { storyMap }
            }
            .background(themeManager.background)
            .navigationTitle("Word Leap")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Refresh", systemImage: "arrow.clockwise") { _ = viewModel.refresh() } } }
            .task { await viewModel.load().value }
            .onAppear { _ = viewModel.refreshProgress() }
            .navigationDestination(item: $selectedBook) { book in GameView(book: book) }
        }
    }

    private var storyMap: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                LibraryMapHeader(
                    bookCount: viewModel.books.count,
                    conqueredCount: viewModel.completedBookIDs.count
                )

                if let errorMessage = viewModel.errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                        .padding(14)
                        .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }

                ForEach(Array(viewModel.books.enumerated()), id: \.element.id) { index, book in
                    Button { selectedBook = book } label: {
                        StoryOutpost(
                            book: book,
                            index: index,
                            isConquered: viewModel.completedBookIDs.contains(book.id)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 34)
        }
        .scrollIndicators(.hidden)
        .refreshable { await viewModel.refresh().value }
    }
}

private struct LibraryMapHeader: View {
    let bookCount: Int
    let conqueredCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CUENTIVA STORY MAP")
                .font(.caption.weight(.bold))
                .tracking(1.8)
                .foregroundStyle(.secondary)
            Text("Choose your next\nadventure.")
                .font(.system(size: 34, weight: .bold, design: .rounded))
            Text("Every book is a climb through its Spanish words.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                Label("\(bookCount) worlds", systemImage: "map.fill")
                Text("·")
                Label("\(conqueredCount) conquered", systemImage: "flag.checkered")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 18)
        .padding(.bottom, 26)
    }
}
