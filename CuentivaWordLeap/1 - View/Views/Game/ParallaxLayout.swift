import Foundation
import CoreGraphics

/// Camera-relative geometry only; this never changes the playable world.
enum ParallaxLayout {
    static func verticalPosition(initialY: CGFloat, cameraClimb: CGFloat,
                                 speed: CGFloat, viewportHeight: CGFloat,
                                 spriteHeight: CGFloat, reduceMotion: Bool) -> CGFloat {
        guard !reduceMotion, viewportHeight > 0 else { return initialY }
        // Wrapping happens with the entire sprite outside the viewport.
        let lowerBound = -(viewportHeight + spriteHeight) / 2 - 16
        let span = viewportHeight + spriteHeight + 32
        let offset = initialY - max(0, cameraClimb) * speed - lowerBound
        let remainder = offset.truncatingRemainder(dividingBy: span)
        return lowerBound + (remainder < 0 ? remainder + span : remainder)
    }
}
