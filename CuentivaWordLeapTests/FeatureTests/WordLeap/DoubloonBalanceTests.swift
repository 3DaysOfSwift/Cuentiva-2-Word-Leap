import Testing
@testable import CuentivaWordLeap

@MainActor
struct DoubloonBalanceTests {
    @Test func duplicateAndLowerCountsDoNotCreditTheSameCoinsAgain() async throws {
        let fixture = try AdventureTestFixture()
        defer { try? fixture.cleanUp() }
        await fixture.library.load().value
        let book = try #require(fixture.library.books.first)
        await fixture.game.start(book: book).value
        await fixture.game.recordCollectedDoubloons(2)?.value
        await fixture.game.recordCollectedDoubloons(2)?.value
        await fixture.game.recordCollectedDoubloons(1)?.value
        await fixture.game.recordCollectedDoubloons(-1)?.value
        fixture.game.recordRunProgress(doubloons: 2, activeSeconds: 10)
        await fixture.game.recordCollectedDoubloons(2)?.value
        #expect(fixture.library.doubloonBalance == 2)
        await fixture.game.recordCollectedDoubloons(3)?.value
        #expect(fixture.library.doubloonBalance == 3)
    }

    @Test func earnedCoinsSurviveLeavingAndFreshAdventuresCanEarnMore() async throws {
        let fixture = try AdventureTestFixture()
        defer { try? fixture.cleanUp() }
        await fixture.library.load().value
        let book = try #require(fixture.library.books.first)
        await fixture.game.start(book: book).value
        let credit = fixture.game.recordCollectedDoubloons(2)
        fixture.game.endLevel()
        await credit?.value
        #expect(await fixture.progress.doubloonBalance() == 2)
        await fixture.game.start(book: book).value
        await fixture.game.recordCollectedDoubloons(1)?.value
        #expect(fixture.library.doubloonBalance == 3)
    }

    @Test func inactiveGamesAndCountsAboveAvailableCoinsCannotInflateBalance() async throws {
        let fixture = try AdventureTestFixture()
        defer { try? fixture.cleanUp() }
        await fixture.game.recordCollectedDoubloons(30)?.value
        #expect(fixture.library.doubloonBalance == 0)
        await fixture.library.load().value
        let book = try #require(fixture.library.books.first)
        await fixture.game.start(book: book).value
        let level = try #require(fixture.game.activeLevel)
        await fixture.game.recordCollectedDoubloons(100)?.value
        #expect(fixture.library.doubloonBalance == min(30, level.words.count))
    }

    @Test func overlappingCreditsAndRefreshKeepTheNewestBalance() async throws {
        let fixture = try AdventureTestFixture()
        defer { try? fixture.cleanUp() }
        await fixture.library.load().value
        let book = try #require(fixture.library.books.first)
        await fixture.game.start(book: book).value
        let first = fixture.game.recordCollectedDoubloons(1)
        let refresh = fixture.library.refreshProgress()
        let second = fixture.game.recordCollectedDoubloons(2)
        let third = fixture.game.recordCollectedDoubloons(3)
        await first?.value
        await refresh.value
        await second?.value
        await third?.value
        #expect(fixture.library.doubloonBalance == 3)
        #expect(await fixture.progress.doubloonBalance() == 3)
    }
}
