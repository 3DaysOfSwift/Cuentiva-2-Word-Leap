import Observation

@MainActor @Observable
final class WordLeapFeature {
    private let levelPlanBuilder: LevelPlanBuilder
    private let levelProgressStore: LevelProgressStore
    private(set) var activeLevel: LevelPlan?
    private(set) var preparationError: String?
    private(set) var landedWordCount = 0
    private(set) var isLevelComplete = false
    private(set) var runStatistics = AdventureRunStatistics()
    @ObservationIgnored private var preparationTask: Task<Void, Never>?

    init(levelPlanBuilder: LevelPlanBuilder, levelProgressStore: LevelProgressStore = LevelProgressStore()) {
        self.levelPlanBuilder = levelPlanBuilder
        self.levelProgressStore = levelProgressStore
    }

    func start(book: StoryBook, continuingRun: Bool = false) -> Task<Void, Never> {
        if let preparationTask { return preparationTask }
        let task = Task { [levelPlanBuilder] in
            let plan = await levelPlanBuilder.makePlan(for: book)
            guard !Task.isCancelled else { return }
            if !continuingRun { self.runStatistics = AdventureRunStatistics() }
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
        guard let activeLevel, !isLevelComplete, activeLevel.words.indices.contains(wordIndex) else { return }
        runStatistics.recordLanding(in: activeLevel, at: wordIndex)
        landedWordCount = max(landedWordCount, wordIndex + 1)
        isLevelComplete = landedWordCount == activeLevel.words.count
        if isLevelComplete {
            let bookID = activeLevel.book.id
            let levelProgressStore = levelProgressStore
            Task { await levelProgressStore.recordCompletion(of: bookID) }
        }
    }

    func recordRunProgress(doubloons: Int, activeSeconds: Double) {
        guard let activeLevel else { return }
        runStatistics.recordProgress(bookID: activeLevel.book.id,
            doubloons: doubloons, activeSeconds: activeSeconds)
    }

    func endLevel() {
        preparationTask?.cancel()
        preparationTask = nil
        activeLevel = nil
        landedWordCount = 0
        isLevelComplete = false
    }
}
