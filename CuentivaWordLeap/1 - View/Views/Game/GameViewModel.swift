import Observation

@MainActor @Observable
final class GameViewModel {
    private let wordLeapFeature: WordLeapFeature
    private(set) var lastReadWord = ""

    init(wordLeapFeature: WordLeapFeature = AppModel.shared.wordLeapFeature) { self.wordLeapFeature = wordLeapFeature }

    var activeLevel: LevelPlan? { wordLeapFeature.activeLevel }
    var wordsRead: Int { wordLeapFeature.landedWordCount }
    var isLevelComplete: Bool { wordLeapFeature.isLevelComplete }

    func prepare(_ book: StoryBook) -> Task<Void, Never> {
        wordLeapFeature.start(book: book)
    }

    func recordLanding(at wordIndex: Int, word: String) {
        wordLeapFeature.recordLanding(at: wordIndex)
        lastReadWord = word
    }

    func leaveLevel() { wordLeapFeature.endLevel() }
}
