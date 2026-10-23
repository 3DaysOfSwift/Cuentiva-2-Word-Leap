import Foundation
import CoreGraphics
import Testing
@testable import CuentivaWordLeap

struct ParallaxLayoutTests {
    @Test func sceneryBeginsAtItsDesignedPosition() {
        for initialY: CGFloat in [-400, -100, 0, 300, 450] {
            #expect(abs(position(initialY: initialY, climb: 0) - initialY) < 0.001)
        }
    }

    @Test func nearSceneryMovesFasterThanDistantScenery() {
        #expect(abs(position(climb: 100, speed: 0.14) + 14) < 0.001)
        #expect(abs(position(climb: 100, speed: 0.34) + 34) < 0.001)
        #expect(abs(position(climb: 100, speed: 0.52) + 52) < 0.001)
    }

    @Test func recyclingOnlyOccursBeyondBothScreenEdges() {
        // Viewport ±400, sprite half-height 100, plus 16-point guard.
        let justBeforeWrap = position(climb: 515.9, speed: 1)
        let justAfterWrap = position(climb: 516.1, speed: 1)
        #expect(justBeforeWrap + 100 < -400)
        #expect(justAfterWrap - 100 > 400)
        #expect(abs(position(climb: 1032, speed: 1)) < 0.001)
    }

    @Test func fullBookClimbsStayBoundedAndAreFrameRateIndependent() {
        for climb in stride(from: CGFloat(0), through: 100_000, by: 37) {
            let y = position(climb: climb)
            #expect(y >= -516 && y <= 516)
        }
        // Direct positioning from altitude has no accumulating integration error.
        let final = position(climb: 12345)
        for frameRate in [30, 60, 120] {
            var last: CGFloat = 0
            for frame in 0...frameRate {
                last = position(climb: 12345 * CGFloat(frame) / CGFloat(frameRate))
            }
            #expect(abs(last - final) < 0.001)
        }
    }

    @Test func reduceMotionKeepsSceneryStillAndRetryRestoresAltitude() {
        #expect(position(initialY: 75, climb: 100_000, reduceMotion: true) == 75)
        #expect(position(initialY: 75, climb: -50) == 75)
        let checkpoint = position(climb: 2000)
        _ = position(climb: 2500)
        #expect(position(climb: 2000) == checkpoint)
    }

    @Test func differentViewportSizesWrapOutsideTheirOwnBounds() {
        for height: CGFloat in [320, 667, 844, 1024, 1366] {
            let lower = -(height + 200) / 2 - 16
            let y = ParallaxLayout.verticalPosition(initialY: 0, cameraClimb: -lower + 0.1,
                speed: 1, viewportHeight: height, spriteHeight: 200, reduceMotion: false)
            #expect(y - 100 > height / 2)
        }
    }

    private func position(initialY: CGFloat = 0, climb: CGFloat, speed: CGFloat = 0.34,
                          reduceMotion: Bool = false) -> CGFloat {
        ParallaxLayout.verticalPosition(initialY: initialY, cameraClimb: climb, speed: speed,
            viewportHeight: 800, spriteHeight: 200, reduceMotion: reduceMotion)
    }
}
