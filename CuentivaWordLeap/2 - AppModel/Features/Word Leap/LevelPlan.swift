import Foundation

struct LevelPlan: Sendable {
    let book: StoryBook
    let words: [String]
}

actor LevelPlanBuilder {
    func makePlan(for book: StoryBook) -> LevelPlan {
        LevelPlan(book: book, words: book.spanishPassages.flatMap(SpanishWordTokenizer.words))
    }
}
