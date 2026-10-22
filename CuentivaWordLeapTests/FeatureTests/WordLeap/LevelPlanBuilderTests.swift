import Testing
import Foundation
@testable import CuentivaWordLeap

struct LevelPlanBuilderTests {
    @Test func spanishVerbsAreRecognisedFromBundledConjugations() async throws {
        let book = StoryBook(id: "verbs", storyteller: "Pipa", title: "Un salto", englishTitle: "A jump",
            spanishPassages: ["Ella tiene un libro. Nosotros comemos pan."])
        let plan = await LevelPlanBuilder(vocabularyURL: try vocabularyURL()).makePlan(for: book)
        #expect(plan.verbCountingAvailable)
        let verbs = Set(plan.verbIndices.map { plan.words[$0] })
        #expect(verbs.contains("tiene"))
        #expect(verbs.contains("comemos"))
        #expect(!verbs.contains("."))
        #expect(!verbs.contains("libro"))
    }

    @Test func emptyBookHasNoVerbEstimates() async throws {
        let book = StoryBook(id: "empty", storyteller: "Pipa", title: "Empty", englishTitle: "Empty",
            spanishPassages: [])
        let plan = await LevelPlanBuilder(vocabularyURL: try vocabularyURL()).makePlan(for: book)
        #expect(plan.words.isEmpty)
        #expect(plan.verbIndices.isEmpty)
    }

    @Test func missingVocabularyDoesNotPretendNoVerbsWereFound() async {
        let book = StoryBook(id: "missing", storyteller: "Pipa", title: "Missing", englishTitle: "Missing",
            spanishPassages: ["Ella tiene un libro."])
        let plan = await LevelPlanBuilder(vocabularyURL: nil).makePlan(for: book)
        #expect(!plan.verbCountingAvailable)
        #expect(!plan.words.isEmpty)
    }

    private func vocabularyURL() throws -> URL {
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        let bundle = Bundle.main
        #endif
        return try #require(bundle.url(forResource: "verbs", withExtension: "json"))
    }
}
