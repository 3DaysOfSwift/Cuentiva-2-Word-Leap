import Observation

@MainActor @Observable
final class LibraryViewModel {
    private let libraryFeature: LibraryFeature
    var selectedBook: StoryBook?

    init(libraryFeature: LibraryFeature = AppModel.shared.libraryFeature) {
        self.libraryFeature = libraryFeature
    }

    var books: [StoryBook] { libraryFeature.books }
    var castles: [AdventureCastle] { libraryFeature.castles }
    var conqueredCount: Int { libraryFeature.conqueredCastleCount }
    var doubloonBalance: Int { libraryFeature.doubloonBalance }
    var errorMessage: String? { libraryFeature.loadError }
    var isLoading: Bool { libraryFeature.isLoading }

    func select(_ book: StoryBook) {
        guard libraryFeature.canPlay(book) else { return }
        selectedBook = book
    }

    func load() -> Task<Void, Never> { libraryFeature.load() }
    func refresh() -> Task<Void, Never> { libraryFeature.refresh() }
    func refreshProgress() -> Task<Void, Never> { libraryFeature.refreshProgress() }
}
