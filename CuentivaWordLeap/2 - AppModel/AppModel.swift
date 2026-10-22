import Foundation

@MainActor
final class AppModel {
    static let shared = live()
    let libraryFeature: LibraryFeature
    let wordLeapFeature: WordLeapFeature
    let settingsFeature: SettingsFeature

    init(libraryFeature: LibraryFeature, wordLeapFeature: WordLeapFeature, settingsFeature: SettingsFeature) {
        self.libraryFeature = libraryFeature
        self.wordLeapFeature = wordLeapFeature
        self.settingsFeature = settingsFeature
    }

    static func live() -> AppModel {
        let networkingManager = NetworkingManager()
        let bookRepository = CuentivaBookRepository(networkingManager: networkingManager)
        let levelPlanBuilder = LevelPlanBuilder()
        let libraryFeature = LibraryFeature(bookRepository: bookRepository)
        let wordLeapFeature = WordLeapFeature(levelPlanBuilder: levelPlanBuilder)
        return AppModel(libraryFeature: libraryFeature, wordLeapFeature: wordLeapFeature, settingsFeature: SettingsFeature())
    }
}
