import Foundation
import CoreGraphics
import Testing
@testable import CuentivaWordLeap

struct WordLeapSimulationTests {
    @Test func spawnRemainsSupportedUntilTouch() throws {
        var game = WordLeapSimulation(words: ["En", "este", "mercado"], viewport: CGSize(width: 420, height: 912))
        let first = try #require(game.platforms.first)
        let spawn = game.position
        for _ in 0..<600 { _ = game.advance(delta: 1.0 / 60, steeringTargetX: 0) }
        #expect(game.position == spawn)
        #expect(game.position.x == first.frame.midX)
        #expect(abs(game.position.y - WordLeapSimulation.footOffset - first.frame.maxY) < 0.000001)
        #expect(game.isWaitingForLaunch)
    }

    @Test(arguments: [30, 60, 120])
    func topEdgeContactBouncesInsteadOfFallingThrough(fps: Int) throws {
        var game = WordLeapSimulation(words: ["En", "este", "mercado"], viewport: CGSize(width: 420, height: 912))
        let first = try #require(game.platforms.first)
        #expect(game.launch() == 0)
        var bounces = 0
        for _ in 0..<(fps * 8) {
            let velocity = game.verticalVelocity
            _ = game.advance(delta: 1.0 / Double(fps), steeringTargetX: nil)
            if velocity < 0, game.verticalVelocity > 0 { bounces += 1 }
            #expect(game.position.y - WordLeapSimulation.footOffset >= first.frame.maxY - 0.001)
        }
        #expect(bounces > 3)
    }

    @Test func checkpointAndResizeRemainSupported() throws {
        var game = WordLeapSimulation(words: ["En", "este", "mercado"],
            viewport: CGSize(width: 420, height: 912), checkpointIndex: 1)
        _ = game.launch()
        for _ in 0..<180 { _ = game.advance(delta: 1.0 / 60, steeringTargetX: 420) }
        game.resetToCheckpoint()
        let checkpoint = game.platforms[game.furthestPlatformIndex]
        #expect(game.position.x == checkpoint.frame.midX)
        #expect(game.position.y == checkpoint.frame.maxY + WordLeapSimulation.footOffset)
        #expect(game.isWaitingForLaunch)
        let resized = WordLeapSimulation(words: game.platforms.map(\.word),
            viewport: CGSize(width: 852, height: 393), checkpointIndex: game.furthestPlatformIndex)
        #expect(resized.position.x == resized.platforms[resized.furthestPlatformIndex].frame.midX)
        #expect(resized.isWaitingForLaunch)
    }

    @Test(arguments: [30, 60, 120])
    func everyBundledBookCanBeCompletedWithReactionTime(fps: Int) throws {
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        let bundle = Bundle.main
        #endif
        let url = try #require(bundle.url(forResource: "stories", withExtension: "txt"))
        let books = try CuentivaBookRepository.decode(Data(contentsOf: url))
        #expect(!books.isEmpty)
        for size in [CGSize(width: 320, height: 568), CGSize(width: 390, height: 844),
                     CGSize(width: 420, height: 912), CGSize(width: 852, height: 393),
                     CGSize(width: 1024, height: 1366)] {
            for book in books {
                let words = book.spanishPassages.flatMap(SpanishWordTokenizer.words)
                var game = WordLeapSimulation(words: words, viewport: size)
                _ = game.launch()
                for platform in game.platforms {
                    #expect(platform.frame.minX >= 0 && platform.frame.maxX <= size.width)
                }
                for destination in game.platforms.dropFirst() {
                    // Allow a human reaction delay at the beginning of each jump.
                    var landed: Int?
                    for frame in 0..<(fps * 2) {
                        let target = Double(frame) / Double(fps) < Double(WordLeapSimulation.steeringGracePeriod)
                            ? nil : destination.frame.midX
                        if let index = game.advance(delta: 1.0 / Double(fps), steeringTargetX: target) {
                            landed = index
                            break
                        }
                    }
                    try #require(landed == destination.index,
                        "Unreachable word \(destination.index) in \(book.id), \(size), \(fps) fps")
                }
                #expect(game.furthestPlatformIndex == words.count - 1)
            }
        }
    }
}
