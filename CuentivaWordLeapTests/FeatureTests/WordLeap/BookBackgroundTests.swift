import Foundation
import Testing
@testable import CuentivaWordLeap
#if canImport(UIKit)
import UIKit
#endif

struct BookBackgroundTests {
    private static let expected: [(String, String)] = [
        ("cafe", "BookBackgroundCafe"),
        ("garden", "BookBackgroundGarden"),
        ("train", "BookBackgroundTrain"),
        ("sea", "BookBackgroundSea"),
        ("repair", "BookBackgroundRepair"),
        ("repair-hour", "BookBackgroundRepairHour"),
        ("loan-notebook", "BookBackgroundLoanNotebook"),
        ("small-guide", "BookBackgroundSmallGuide"),
        ("three-paths", "BookBackgroundThreePaths"),
        ("three-envelopes", "BookBackgroundThreeEnvelopes")
    ]

    @Test func firstTenBooksHaveDistinctStorySpecificBackgrounds() throws {
        let books = try bundledBooks()
        #expect(Array(books.prefix(10).map(\.id)) == Self.expected.map { $0.0 })
        #expect(Array(books.prefix(10).map(\.backgroundAssetName)) == Self.expected.map { $0.1 })
        #expect(Set(books.prefix(10).map(\.backgroundAssetName)).count == 10)
        #expect(books.dropFirst(10).allSatisfy { $0.backgroundAssetName == "WordLeapSky" })
    }

    @Test func sceneryFollowsBookIdentityNotTitleOrOrder() {
        for (id, asset) in Self.expected.reversed() {
            let book = StoryBook(id: id, storyteller: "Pipa", title: "A changed title",
                englishTitle: "", spanishPassages: [])
            #expect(book.backgroundAssetName == asset)
        }
    }

    @Test func newBooksKeepTheOriginalSky() {
        let book = StoryBook(id: "new-from-github", storyteller: "Pipa", title: "",
            englishTitle: "", spanishPassages: [])
        #expect(book.backgroundAssetName == "WordLeapSky")
    }

    #if canImport(UIKit)
    @MainActor @Test func allBundledBackgroundsLoadAsPortraitImages() throws {
        for name in Self.expected.map({ $0.1 }) + ["WordLeapSky"] {
            let image = try #require(UIImage(named: name))
            #expect(image.size.width > 0)
            #expect(image.size.height > image.size.width)
        }
    }
    #endif

    private func bundledBooks() throws -> [StoryBook] {
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        let bundle = Bundle.main
        #endif
        let url = try #require(bundle.url(forResource: "stories", withExtension: "txt"))
        return try CuentivaBookRepository.decode(Data(contentsOf: url))
    }
}
