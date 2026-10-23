import Foundation
import Testing
@testable import CuentivaWordLeap

/// One isolated catalogue, progress store and shared feature graph per test.
@MainActor
final class AdventureTestFixture {
    let directory: URL
    let suiteName: String
    let repository: CuentivaBookRepository
    let progress: LevelProgressStore
    let library: LibraryFeature
    let game: WordLeapFeature

    init() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        suiteName = "AdventureTests-\(UUID())"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            throw CocoaError(.fileWriteUnknown)
        }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let manuscript = """
        @one|Pipa|Uno|One|First book
        Pipa salta. | Pipa jumps.
        @two|Musgo|Dos|Two|Second book
        Musgo corre. | Musgo runs.
        @three|Mora|Tres|Three|Third book
        Mora mira. | Mora looks.
        """
        let url = directory.appendingPathComponent("stories.txt")
        try Data(manuscript.utf8).write(to: url)
        repository = CuentivaBookRepository(networkingManager: NetworkingManager(), bundledStoriesURL: url)
        progress = LevelProgressStore(defaults: defaults)
        library = LibraryFeature(bookRepository: repository, levelProgressStore: progress)
        game = WordLeapFeature(levelPlanBuilder: LevelPlanBuilder(vocabularyURL: nil), libraryFeature: library)
    }

    func cleanUp() throws {
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
        try FileManager.default.removeItem(at: directory)
    }
}
