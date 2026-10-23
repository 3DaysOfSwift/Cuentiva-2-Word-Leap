import Foundation
import Testing
@testable import CuentivaWordLeap

struct LevelProgressStoreTests {
    @Test func balanceSurvivesReopeningWithoutChangingCompletedCastles() async throws {
        let suiteName = "DoubloonBalanceTests-\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName) }
        let store = LevelProgressStore(defaults: defaults)
        #expect(await store.doubloonBalance() == 0)
        await store.recordCompletion(of: "one")
        #expect(await store.addDoubloons(7) == 7)
        #expect(await store.addDoubloons(-3) == 7)
        let reopenedDefaults = try #require(UserDefaults(suiteName: suiteName))
        let reopened = LevelProgressStore(defaults: reopenedDefaults)
        #expect(await reopened.doubloonBalance() == 7)
        #expect(await reopened.completedBookIDs() == ["one"])
        #expect(await reopened.addDoubloons(2) == 9)
        #expect(await store.doubloonBalance() == 9)
    }
}
