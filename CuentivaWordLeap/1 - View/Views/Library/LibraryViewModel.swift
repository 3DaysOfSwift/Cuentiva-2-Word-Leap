import Observation

@MainActor @Observable
final class LibraryViewModel {
    private let libraryFeature: LibraryFeature

    init(libraryFeature: LibraryFeature = AppModel.shared.libraryFeature) {
        self.libraryFeature = libraryFeature
    }

    var books: [StoryBook] { libraryFeature.books }
    var errorMessage: String? { libraryFeature.loadError }
    var isLoading: Bool { libraryFeature.isLoading }

    func load() -> Task<Void, Never> { libraryFeature.load() }
    func refresh() -> Task<Void, Never> { libraryFeature.refresh() }
}
