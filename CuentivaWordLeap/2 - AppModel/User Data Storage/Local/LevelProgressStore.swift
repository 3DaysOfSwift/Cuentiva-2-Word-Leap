import Foundation

/// The small, local source of truth for the story worlds the player has finished.
actor LevelProgressStore {
    private let completedBookIDsKey = "completedWordLeapBookIDs"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func completedBookIDs() -> Set<String> {
        Set(defaults.stringArray(forKey: completedBookIDsKey) ?? [])
    }

    func recordCompletion(of bookID: String) {
        var completed = completedBookIDs()
        completed.insert(bookID)
        defaults.set(completed.sorted(), forKey: completedBookIDsKey)
    }
}
