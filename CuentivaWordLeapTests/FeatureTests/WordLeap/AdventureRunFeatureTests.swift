import Testing
@testable import CuentivaWordLeap

@MainActor
struct AdventureRunFeatureTests {
    @Test func nextLevelKeepsRunTotalsButFreshAdventureResetsThem() async throws {
        let fixture = try AdventureTestFixture()
        defer { try? fixture.cleanUp() }
        let feature = fixture.game
        await fixture.library.load().value
        let first = try #require(fixture.library.books.first)
        let second = try #require(fixture.library.books.first { $0.id == "two" })
        await feature.start(book: first).value
        let plan = try #require(feature.activeLevel)
        for index in plan.words.indices { feature.recordLanding(at: index) }
        let firstWordCount = feature.runStatistics.wordsCollected
        feature.recordRunProgress(doubloons: 3, activeSeconds: 75)
        await feature.start(book: second, continuingRun: true).value
        feature.recordLanding(at: 0)
        feature.recordRunProgress(doubloons: 2, activeSeconds: 10)
        #expect(feature.runStatistics.wordsCollected == firstWordCount + 1)
        #expect(feature.runStatistics.doubloonsCollected == 5)
        #expect(feature.runStatistics.activeSeconds == 85)
        feature.endLevel()
        await feature.start(book: first).value
        #expect(feature.runStatistics.wordsCollected == 0)
        #expect(feature.runStatistics.activeSeconds == 0)
    }
}
