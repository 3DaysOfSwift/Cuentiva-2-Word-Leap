import Foundation
import Observation

@MainActor @Observable
final class WordLeapFeature {
    /// Artwork/profile catalogue only, not an inventory of unlocked characters.
    let characterProfiles = GameCharacter.cuentivaCast
    private let levelPlanBuilder: LevelPlanBuilder
    private let libraryFeature: LibraryFeature
    private(set) var activeLevel: LevelPlan?
    private(set) var preparationError: String?
    private(set) var landedWordCount = 0
    private(set) var isLevelComplete = false
    private(set) var runStatistics = AdventureRunStatistics()
    @ObservationIgnored private var preparationTask: Task<Void, Never>?
    // Completion must be saved before an immediate Next level request checks access.
    @ObservationIgnored private var completionTask: Task<Void, Never>?
    @ObservationIgnored private var doubloonSaveTask: Task<Void, Never>?
    private var creditedLevelDoubloons = 0

    init(levelPlanBuilder: LevelPlanBuilder, libraryFeature: LibraryFeature) {
        self.levelPlanBuilder = levelPlanBuilder
        self.libraryFeature = libraryFeature
    }

    func start(book: StoryBook, continuingRun: Bool = false) -> Task<Void, Never> {
        if let preparationTask { return preparationTask }
        preparationError = nil
        let task = Task { [levelPlanBuilder, libraryFeature, completionTask] in
            do {
                await completionTask?.value
                try Task.checkCancellation()
                let playableBook = try await libraryFeature.bookForPlay(id: book.id)
                try Task.checkCancellation()
                let plan = await levelPlanBuilder.makePlan(for: playableBook)
                try Task.checkCancellation()
                if !continuingRun { self.runStatistics = AdventureRunStatistics() }
                self.activeLevel = plan
                self.creditedLevelDoubloons = 0
                self.landedWordCount = 0
                self.isLevelComplete = false
            } catch {
                guard !Task.isCancelled else { return }
                self.preparationError = error.localizedDescription
            }
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
            completionTask = Task { [libraryFeature] in
                await libraryFeature.recordCompletion(of: bookID)
            }
        }
    }

    func recordRunProgress(doubloons: Int, activeSeconds: Double) {
        guard let activeLevel else { return }
        _ = recordCollectedDoubloons(doubloons)
        runStatistics.recordProgress(bookID: activeLevel.book.id,
            doubloons: doubloons, activeSeconds: activeSeconds)
    }

    /// The scene reports a cumulative count. Credit only its increase, including across retries.
    @discardableResult
    func recordCollectedDoubloons(_ count: Int) -> Task<Void, Never>? {
        guard let activeLevel else { return doubloonSaveTask }
        let collected = min(max(0, count), min(30, activeLevel.words.count))
        let earned = collected - creditedLevelDoubloons
        guard earned > 0 else { return doubloonSaveTask }
        creditedLevelDoubloons = collected
        let task = Task { [libraryFeature, doubloonSaveTask] in
            await doubloonSaveTask?.value
            await libraryFeature.bankDoubloons(earned)
        }
        // Durable credits continue if the player leaves or begins another level.
        doubloonSaveTask = task
        return task
    }

    func endLevel() {
        preparationTask?.cancel()
        preparationTask = nil
        activeLevel = nil
        landedWordCount = 0
        isLevelComplete = false
    }
}
