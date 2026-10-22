import Observation

@MainActor @Observable
final class LibraryFeature {
    private let bookRepository: CuentivaBookRepository
    private let levelProgressStore: LevelProgressStore
    private(set) var books: [StoryBook] = []
    private(set) var completedBookIDs: Set<String> = []
    private(set) var loadError: String?
    private(set) var isLoading = false
    @ObservationIgnored private var loadingTask: Task<Void, Never>?

    init(bookRepository: CuentivaBookRepository, levelProgressStore: LevelProgressStore) {
        self.bookRepository = bookRepository
        self.levelProgressStore = levelProgressStore
    }

    func load() -> Task<Void, Never> {
        if let loadingTask { return loadingTask }
        let task = Task { [bookRepository, levelProgressStore] in
            await self.loadBooks(from: bookRepository, levelProgressStore: levelProgressStore)
        }
        loadingTask = task
        return task
    }

    func refresh() -> Task<Void, Never> {
        if let loadingTask { return loadingTask }
        let task = Task { [bookRepository, levelProgressStore] in
            await self.refreshBooks(from: bookRepository, levelProgressStore: levelProgressStore)
        }
        loadingTask = task
        return task
    }

    func refreshProgress() -> Task<Void, Never> {
        Task { [levelProgressStore] in
            completedBookIDs = await levelProgressStore.completedBookIDs()
        }
    }

    private func loadBooks(
        from repository: CuentivaBookRepository,
        levelProgressStore: LevelProgressStore
    ) async {
        isLoading = true
        defer { isLoading = false; loadingTask = nil }
        do {
            books = try await repository.books()
            completedBookIDs = await levelProgressStore.completedBookIDs()
            loadError = nil
        }
        catch { loadError = "The Cuentiva book collection could not be opened." }
    }

    private func refreshBooks(
        from repository: CuentivaBookRepository,
        levelProgressStore: LevelProgressStore
    ) async {
        isLoading = true
        defer { isLoading = false; loadingTask = nil }
        do {
            books = try await repository.refreshFromGitHub()
            completedBookIDs = await levelProgressStore.completedBookIDs()
            loadError = nil
        }
        catch { loadError = "GitHub could not refresh the collection. Your bundled books are still ready to play." }
    }
}
