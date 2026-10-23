import Foundation
import Testing
@testable import CuentivaWordLeap
#if canImport(UIKit)
import UIKit
#endif

struct BookBackgroundTests {
    private static let expected: [(String, String)] = [
        ("cafe", "CoastBackdrop"),
        ("garden", "RootsBackdrop"),
        ("train", "RailwayBackdrop"),
        ("sea", "PuddleBackdrop"),
        ("repair", "ObservatoryBackdrop"),
        ("repair-hour", "HarbourBackdrop"),
        ("loan-notebook", "TheatreBackdrop"),
        ("small-guide", "OrchardBackdrop"),
        ("three-paths", "StormBackdrop"),
        ("three-envelopes", "LettersBackdrop")
    ]

    @Test func firstTenBooksHaveDistinctStorySpecificBackgrounds() throws {
        let books = try bundledBooks()
        #expect(Array(books.prefix(10).map(\.id)) == Self.expected.map { $0.0 })
        #expect(Array(books.prefix(10).map(\.backgroundAssetName)) == Self.expected.map { $0.1 })
        #expect(Set(books.prefix(10).map(\.backgroundAssetName)).count == 10)
        #expect(books.dropFirst(10).allSatisfy { $0.environment == .skyFalls })
        #expect(Set(books.map(\.environment)) == Set(BookEnvironment.allCases))
    }

    @Test func sceneryFollowsBookIdentityNotTitleOrOrder() {
        for (id, asset) in Self.expected.reversed() {
            let book = StoryBook(id: id, storyteller: "Pipa", title: "A changed title",
                englishTitle: "", spanishPassages: [])
            #expect(book.backgroundAssetName == asset)
        }
    }

    @Test func newBooksReceiveTheReusableSkyFallsPack() {
        let book = StoryBook(id: "new-from-github", storyteller: "Pipa", title: "",
            englishTitle: "", spanishPassages: [])
        #expect(book.environment == .skyFalls)
        #expect(book.backgroundAssetName == "SkyFallsBackdrop")
        #expect(!ParallaxSceneryRecipe(environment: book.environment).layers.isEmpty)
    }

    #if canImport(UIKit)
    @MainActor @Test func allBundledBackgroundsLoadAsPortraitImages() throws {
        for name in BookEnvironment.allCases.map(\.backdropAssetName) {
            let image = try #require(UIImage(named: name))
            #expect(image.size.width > 0)
            #expect(image.size.height > image.size.width)
        }
    }

    @MainActor @Test func sceneryCutoutsHaveTransparency() throws {
        let names = BookEnvironment.allCases.flatMap {
            ParallaxSceneryRecipe(environment: $0).layers.map(\.assetName)
        }
        for name in names {
            let image = try #require(UIImage(named: name)?.cgImage)
            #expect([CGImageAlphaInfo.first, .last, .premultipliedFirst, .premultipliedLast]
                .contains(image.alphaInfo))
            // An alpha channel alone can still contain a fully opaque rectangle.
            var pixels = [UInt8](repeating: 0, count: 64 * 64 * 4)
            let transparentPixels = try pixels.withUnsafeMutableBytes { bytes in
                let context = try #require(CGContext(data: bytes.baseAddress, width: 64, height: 64,
                    bitsPerComponent: 8, bytesPerRow: 64 * 4, space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
                context.draw(image, in: CGRect(x: 0, y: 0, width: 64, height: 64))
                return stride(from: 3, to: bytes.count, by: 4).filter { bytes[$0] == 0 }.count
            }
            #expect(transparentPixels > 100, "Scenery must have a genuinely transparent surround: \(name)")
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
