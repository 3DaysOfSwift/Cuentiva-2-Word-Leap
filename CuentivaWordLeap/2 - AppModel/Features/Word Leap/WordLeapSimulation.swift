import Foundation
import CoreGraphics

struct WordPlatform {
    let index: Int
    let word: String
    let frame: CGRect
}

/// Shared by the live scene and regression tests, in scene points and seconds.
struct WordLeapSimulation {
    static let gravity: CGFloat = 1_520
    static let jumpSpeed: CGFloat = 720
    static let footOffset: CGFloat = 32
    static let maximumHorizontalSpeed: CGFloat = 340
    static let maximumJumpHeight = jumpSpeed * jumpSpeed / (2 * gravity)
    // Leave 40% of the jump height as headroom, rather than requiring a perfect jump.
    static let platformRise = floor(maximumJumpHeight * 0.60)
    static let steeringGracePeriod: CGFloat = 0.18
    static let landingTime = (jumpSpeed + sqrt(jumpSpeed * jumpSpeed - 2 * gravity * platformRise)) / gravity
    static let maximumCentreStep = min(96, maximumHorizontalSpeed * (landingTime - steeringGracePeriod) * 0.5)

    let viewport: CGSize
    let platforms: [WordPlatform]
    private(set) var position: CGPoint = .zero
    private(set) var verticalVelocity: CGFloat = 0
    private(set) var furthestPlatformIndex: Int = -1
    private(set) var isWaitingForLaunch = true

    init(words: [String], viewport: CGSize, checkpointIndex: Int = -1) {
        self.viewport = viewport
        var generated: [WordPlatform] = []
        var previousX = viewport.width / 2
        for (index, word) in words.enumerated() {
            let desiredWidth: CGFloat = index == 0 ? 240 : max(112, min(194, CGFloat(word.count * 14 + 48)))
            let width = min(max(1, viewport.width - 36), desiredWidth)
            let sidePadding = width / 2 + 18
            let span = min(200, max(viewport.width - sidePadding * 2, 0))
            let pattern = CGFloat((index * 71 + 43) % 100) / 100
            let desiredX = index == 0 ? viewport.width / 2 : viewport.width / 2 + span * (pattern - 0.5)
            let x = min(previousX + Self.maximumCentreStep, max(previousX - Self.maximumCentreStep, desiredX))
            let boundedX = min(viewport.width - sidePadding, max(sidePadding, x))
            let y = max(156, viewport.height * 0.22) + CGFloat(index) * Self.platformRise
            generated.append(WordPlatform(index: index, word: word,
                frame: CGRect(x: boundedX - width / 2, y: y - 26, width: width, height: 52)))
            previousX = boundedX
        }
        platforms = generated
        furthestPlatformIndex = min(checkpointIndex, generated.count - 1)
        resetToCheckpoint()
    }

    mutating func resetToCheckpoint() {
        guard !platforms.isEmpty else { return }
        let platform = platforms[max(0, furthestPlatformIndex)]
        position = CGPoint(x: platform.frame.midX, y: platform.frame.maxY + Self.footOffset)
        verticalVelocity = 0
        isWaitingForLaunch = true
    }

    /// Spawn is supported and stationary until the player explicitly begins.
    mutating func launch() -> Int? {
        guard isWaitingForLaunch, !platforms.isEmpty,
              furthestPlatformIndex < platforms.count - 1 else { return nil }
        isWaitingForLaunch = false
        verticalVelocity = Self.jumpSpeed
        if furthestPlatformIndex == -1 {
            furthestPlatformIndex = 0
            if platforms.count == 1 {
                verticalVelocity = 0
                isWaitingForLaunch = true
            }
            return 0
        }
        return nil
    }

    mutating func advance(delta: TimeInterval, steeringTargetX: CGFloat?) -> Int? {
        guard !isWaitingForLaunch, delta > 0 else { return nil }
        let dt = CGFloat(min(delta, 1.0 / 30.0))
        let previous = position
        let horizontalVelocity = steeringTargetX.map {
            min(Self.maximumHorizontalSpeed, max(-Self.maximumHorizontalSpeed, ($0 - position.x) * 7))
        } ?? 0
        position.x = min(max(position.x + horizontalVelocity * dt, 38), viewport.width - 38)
        position.y += verticalVelocity * dt - 0.5 * Self.gravity * dt * dt
        verticalVelocity -= Self.gravity * dt
        guard verticalVelocity < 0 else { return nil }

        for platform in platforms.reversed() where platform.index <= furthestPlatformIndex + 1 {
            let top = platform.frame.maxY
            let previousFoot = previous.y - Self.footOffset
            let currentFoot = position.y - Self.footOffset
            guard previousFoot >= top, currentFoot <= top else { continue }
            let fraction = (previousFoot - top) / max(previousFoot - currentFoot, .ulpOfOne)
            let crossingX = previous.x + (position.x - previous.x) * fraction
            // Top-edge contact is inclusive. CGRect.contains excludes maxY.
            guard crossingX >= platform.frame.minX - 14,
                  crossingX <= platform.frame.maxX + 14 else { continue }
            position.y = top + Self.footOffset
            verticalVelocity = Self.jumpSpeed
            if platform.index > furthestPlatformIndex {
                furthestPlatformIndex = platform.index
                if platform.index == platforms.count - 1 {
                    verticalVelocity = 0
                    isWaitingForLaunch = true
                }
                return platform.index
            }
            return nil
        }
        return nil
    }
}
