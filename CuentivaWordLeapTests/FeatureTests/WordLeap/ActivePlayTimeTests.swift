import CoreGraphics
import Testing
@testable import CuentivaWordLeap

struct ActivePlayTimeTests {
    @Test func onlyActiveGameplayAddsTimeAndRetryPreservesIt() {
        var game = WordLeapSimulation(words: ["Pipa", "salta", "."], viewport: CGSize(width: 390, height: 844))
        _ = game.advance(delta: 1, steeringTargetX: nil)
        #expect(game.activeSeconds == 0)
        _ = game.launch()
        _ = game.advance(delta: 0.02, steeringTargetX: nil)
        #expect(game.activeSeconds == 0.02)
        let died = game.detectFall(below: game.position.y + 1)
        #expect(died)
        _ = game.advance(delta: 60, steeringTargetX: nil)
        #expect(game.activeSeconds == 0.02)
        game.resetToCheckpoint()
        _ = game.advance(delta: 60, steeringTargetX: nil)
        #expect(game.activeSeconds == 0.02)
        _ = game.launch()
        _ = game.advance(delta: 0.02, steeringTargetX: nil)
        #expect(game.activeSeconds == 0.04)
        let resized = WordLeapSimulation(words: ["Pipa", "salta", "."], viewport: CGSize(width: 844, height: 390),
            checkpointIndex: game.furthestPlatformIndex, activeSeconds: game.activeSeconds)
        #expect(resized.activeSeconds == game.activeSeconds)
    }
}
