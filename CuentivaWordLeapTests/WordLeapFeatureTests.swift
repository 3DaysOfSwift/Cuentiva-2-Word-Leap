import Testing
@testable import CuentivaWordLeap

@MainActor
struct WordLeapFeatureTests {
    @Test func completingTheFinalWordCompletesTheLevel() async {
        let feature = WordLeapFeature(levelPlanBuilder: LevelPlanBuilder())
        let book = StoryBook(
            id: "mora-01",
            storyteller: "Mora",
            title: "La corona",
            englishTitle: "The Crown",
            spanishPassages: ["Mora encuentra una corona"]
        )

        await feature.start(book: book).value
        let wordCount = feature.activeLevel?.words.count ?? 0
        feature.recordLanding(at: wordCount - 1)

        #expect(feature.landedWordCount == wordCount)
        #expect(feature.isLevelComplete)
    }
}
