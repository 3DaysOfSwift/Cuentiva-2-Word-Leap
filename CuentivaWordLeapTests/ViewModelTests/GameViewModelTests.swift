import Foundation
import Testing
@testable import CuentivaWordLeap

@MainActor
struct GameViewModelTests {
    @Test func deathPresentsStatsAndCheckpointRetryKeepsThem() async throws {
        guard let defaults = UserDefaults(suiteName: "GameViewModelTests-\(UUID())") else {
            throw CocoaError(.fileWriteUnknown)
        }
        let progress = LevelProgressStore(defaults: defaults)
        let feature = WordLeapFeature(levelPlanBuilder: LevelPlanBuilder(), levelProgressStore: progress)
        let library = LibraryFeature(bookRepository: CuentivaBookRepository(networkingManager: NetworkingManager()),
            levelProgressStore: progress)
        let model = GameViewModel(wordLeapFeature: feature, libraryFeature: library)
        let book = StoryBook(id: "test", storyteller: "Pipa", title: "Salta", englishTitle: "Jump",
            spanishPassages: ["Pipa salta alto."])
        await model.prepare(book, reduceMotion: true).value
        model.recordLanding(at: 0, word: "Pipa")
        model.showDeath(coins: 4, seconds: 125)
        #expect(model.isDeathPresented)
        #expect(model.gameOverStatistics.first { $0.title == "Time played" }?.value == "2:05")
        #expect(model.gameOverStatistics.first { $0.title == "Words collected" }?.value == "1")
        #expect(model.collectedDoubloons == 4)
        model.retry()
        #expect(!model.isDeathPresented)
        #expect(feature.runStatistics.doubloonsCollected == 4)
        await model.prepare(book).value
        #expect(feature.runStatistics.wordsCollected == 0)
        #expect(feature.runStatistics.activeSeconds == 0)
        model.leaveLevel()
        #expect(model.scene == nil)
        #expect(feature.activeLevel == nil)
    }
}
