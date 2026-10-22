import Observation

@MainActor @Observable
final class WordLeapFeature {
    private let levelPlanBuilder: LevelPlanBuilder
    private(set) var activeLevel: LevelPlan?
    private(set) var preparationError: String?
    private(set) var landedWordCount = 0
    private(set) var isLevelComplete = false
    @ObservationIgnored private var preparationTask: Task<Void, Never>?

    init(levelPlanBuilder: LevelPlanBuilder) { self.levelPlanBuilder = levelPlanBuilder }

    func start(book: StoryBook) -> Task<Void, Never> {
        if let preparationTask { return preparationTask }
        let task = Task { [levelPlanBuilder] in
            let plan = await levelPlanBuilder.makePlan(for: book)
            self.activeLevel = plan
            self.landedWordCount = 0
            self.isLevelComplete = false
            self.preparationError = nil
            self.preparationTask = nil
        }
        preparationTask = task
        return task
    }

    func recordLanding(at wordIndex: Int) {
        guard let activeLevel, activeLevel.words.indices.contains(wordIndex) else { return }
        landedWordCount = max(landedWordCount, wordIndex + 1)
        isLevelComplete = landedWordCount == activeLevel.words.count
    }

    func endLevel() {
        activeLevel = nil
        landedWordCount = 0
        isLevelComplete = false
    }
}
