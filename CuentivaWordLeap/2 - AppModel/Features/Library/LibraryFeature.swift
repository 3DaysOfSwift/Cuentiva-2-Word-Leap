import Observation

@MainActor @Observable
final class LibraryFeature {
    private let bookRepository: CuentivaBookRepository
    private let levelProgressStore: LevelProgressStore
    private(set) var books: [StoryBook] = []
    private(set) var completedBookIDs: Set<String> = []
    private(set) var doubloonBalance = 0
    private(set) var loadError: String?
    private(set) var isLoading = false
    @ObservationIgnored private var loadingTask: Task<Void, Never>?

    init(bookRepository: CuentivaBookRepository, levelProgressStore: LevelProgressStore) {
        self.bookRepository = bookRepository
        self.levelProgressStore = levelProgressStore
    }

    var castles: [AdventureCastle] {
        books.enumerated().map { index, book in
            let completed = completedBookIDs.contains(book.id)
            let previousCompleted = index == 0 || completedBookIDs.contains(books[index - 1].id)
            return AdventureCastle(book: book, number: index + 1, isCompleted: completed,
                isUnlocked: completed || previousCompleted)
        }
    }

    var conqueredCastleCount: Int { castles.filter(\.isCompleted).count }

    func canPlay(_ book: StoryBook) -> Bool {
        castles.first { $0.id == book.id }?.isUnlocked == true
    }

    /// Every gameplay entry point uses the same policy and the canonical catalogue book.
    func bookForPlay(id: String) async throws -> StoryBook {
        if books.isEmpty { await load().value }
        if let loadingTask { await loadingTask.value }
        guard !books.isEmpty else { throw CastleAccessError.libraryUnavailable }
        await refreshProgress().value
        guard let castle = castles.first(where: { $0.id == id }) else {
            throw CastleAccessError.unknownBook
        }
        guard castle.isUnlocked else {
            throw CastleAccessError.locked(previousCastle: castle.number - 1)
        }
        return castle.book
    }

    func recordCompletion(of bookID: String) async {
        guard books.contains(where: { $0.id == bookID }) else { return }
        await levelProgressStore.recordCompletion(of: bookID)
        completedBookIDs.insert(bookID)
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
            completedBookIDs.formUnion(await levelProgressStore.completedBookIDs())
            await refreshDoubloonBalance()
        }
    }

    func bankDoubloons(_ amount: Int) async {
        let savedBalance = await levelProgressStore.addDoubloons(amount)
        // Treasure only increases; a late read must not overwrite a newer credit.
        doubloonBalance = max(doubloonBalance, savedBalance)
    }

    private func refreshDoubloonBalance() async {
        let savedBalance = await levelProgressStore.doubloonBalance()
        doubloonBalance = max(doubloonBalance, savedBalance)
    }

    func nextBook(after book: StoryBook) -> StoryBook? {
        guard let index = books.firstIndex(where: { $0.id == book.id }), index + 1 < books.count else { return nil }
        return books[index + 1]
    }

    func bookNumber(for book: StoryBook) -> Int? {
        books.firstIndex(where: { $0.id == book.id }).map { $0 + 1 }
    }

    private func loadBooks(
        from repository: CuentivaBookRepository,
        levelProgressStore: LevelProgressStore
    ) async {
        isLoading = true
        defer { isLoading = false; loadingTask = nil }
        await refreshDoubloonBalance()
        do {
            books = try await repository.books()
            completedBookIDs.formUnion(await levelProgressStore.completedBookIDs())
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
        await refreshDoubloonBalance()
        do {
            books = try await repository.refreshFromGitHub()
            completedBookIDs.formUnion(await levelProgressStore.completedBookIDs())
            loadError = nil
        }
        catch { loadError = "GitHub could not refresh the collection. Your bundled books are still ready to play." }
    }
}
