import Foundation
import Testing
@testable import CuentivaWordLeap

@MainActor
struct AdventureRunFeatureTests {
    @Test func nextLevelKeepsRunTotalsButFreshAdventureResetsThem() async throws {
        guard let defaults = UserDefaults(suiteName: "AdventureRunFeatureTests-\(UUID())") else {
            throw CocoaError(.fileWriteUnknown)
        }
        let feature = WordLeapFeature(levelPlanBuilder: LevelPlanBuilder(),
            levelProgressStore: LevelProgressStore(defaults: defaults))
        let first = book(id: "one")
        let second = book(id: "two")
        await feature.start(book: first).value
        feature.recordLanding(at: 0)
        feature.recordRunProgress(doubloons: 3, activeSeconds: 75)
        await feature.start(book: second, continuingRun: true).value
        feature.recordLanding(at: 0)
        feature.recordRunProgress(doubloons: 2, activeSeconds: 10)
        #expect(feature.runStatistics.wordsCollected == 2)
        #expect(feature.runStatistics.doubloonsCollected == 5)
        #expect(feature.runStatistics.activeSeconds == 85)
        feature.endLevel()
        await feature.start(book: first).value
        #expect(feature.runStatistics.wordsCollected == 0)
        #expect(feature.runStatistics.activeSeconds == 0)
    }

    private func book(id: String) -> StoryBook {
        StoryBook(id: id, storyteller: "Pipa", title: "Pipa salta", englishTitle: "Pipa jumps",
            spanishPassages: ["Pipa salta."])
    }
}
