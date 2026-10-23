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
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        let bundle = Bundle(for: AdventureTestFixture.self)
        #endif
        let source = try #require(bundle.url(forResource: "AdventureLibrary", withExtension: "dat"))
        let url = directory.appendingPathComponent("Library.dat")
        try FileManager.default.copyItem(at: source, to: url)
        repository = CuentivaBookRepository(networkingManager: NetworkingManager(), bundledLibraryURL: url)
        progress = LevelProgressStore(defaults: defaults)
        library = LibraryFeature(bookRepository: repository, levelProgressStore: progress)
        game = WordLeapFeature(levelPlanBuilder: LevelPlanBuilder(vocabularyURL: nil), libraryFeature: library)
    }

    func cleanUp() throws {
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
        try FileManager.default.removeItem(at: directory)
    }
}
