import Testing
@testable import CuentivaWordLeap

struct SpanishWordTokenizerTests {
    @Test func fullStopsBecomePlatformsInReadingOrder() {
        #expect(SpanishWordTokenizer.platformTokens("En este mercado. Otra historia.") ==
                ["En", "este", "mercado", ".", "Otra", "historia", "."])
    }

    @Test func accentsAndQuotedSentenceEndingsArePreserved() {
        #expect(SpanishWordTokenizer.platformTokens("«Mi lápiz», dice.\nÉl sonríe.") ==
                ["Mi", "lápiz", "dice", ".", "Él", "sonríe", "."])
    }

    @Test func noSentenceEndingIsInvented() {
        #expect(SpanishWordTokenizer.platformTokens("una historia") == ["una", "historia"])
        #expect(SpanishWordTokenizer.platformTokens("") == [])
    }

    @Test func finalFullStopIsRequiredToFinishThePlan() async {
        let book = StoryBook(id: "test", storyteller: "Pipa", title: "Test", englishTitle: "Test",
                             spanishPassages: ["Hola."])
        let plan = await LevelPlanBuilder().makePlan(for: book)
        #expect(plan.words == ["Hola", "."])
        #expect(book.platformCount == 2)
    }
}
