import Observation

@MainActor @Observable
final class LibraryFeature {
    private let bookRepository: CuentivaBookRepository
    private(set) var books: [StoryBook] = []
    private(set) var loadError: String?
    private(set) var isLoading = false
    @ObservationIgnored private var loadingTask: Task<Void, Never>?

    init(bookRepository: CuentivaBookRepository) { self.bookRepository = bookRepository }

    func load() -> Task<Void, Never> {
        if let loadingTask { return loadingTask }
        let task = Task { [bookRepository] in
            await self.loadBooks(from: bookRepository)
        }
        loadingTask = task
        return task
    }

    func refresh() -> Task<Void, Never> {
        if let loadingTask { return loadingTask }
        let task = Task { [bookRepository] in
            await self.refreshBooks(from: bookRepository)
        }
        loadingTask = task
        return task
    }

    private func loadBooks(from repository: CuentivaBookRepository) async {
        isLoading = true
        defer { isLoading = false; loadingTask = nil }
        do { books = try await repository.books(); loadError = nil }
        catch { loadError = "The Cuentiva book collection could not be opened." }
    }

    private func refreshBooks(from repository: CuentivaBookRepository) async {
        isLoading = true
        defer { isLoading = false; loadingTask = nil }
        do { books = try await repository.refreshFromGitHub(); loadError = nil }
        catch { loadError = "GitHub could not refresh the collection. Your bundled books are still ready to play." }
    }
}
