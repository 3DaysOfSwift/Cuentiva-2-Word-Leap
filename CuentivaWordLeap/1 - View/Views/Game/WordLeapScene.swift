import SpriteKit
import UIKit

final class WordLeapScene: SKScene {
    private let levelPlan: LevelPlan
    private let reportLanding: @MainActor (_ wordIndex: Int, _ word: String) -> Void
    private let player = SKSpriteNode(imageNamed: "WordLeapHero")
    private let cameraNode = SKCameraNode()
    private let sky = SKSpriteNode(imageNamed: "WordLeapSky")
    private let platformLayer = SKNode()
    private let jumpSpeed: CGFloat = 720
    private let playerFootOffset: CGFloat = 32
    private var steeringTargetX: CGFloat?
    private var playerVelocity = CGVector(dx: 0, dy: 0)
    private var platforms: [(index: Int, word: String, frame: CGRect)] = []
    private var lastUpdateTime: TimeInterval = 0
    private var lastLandedPlatform = -1

    init(
        size: CGSize,
        levelPlan: LevelPlan,
        reportLanding: @escaping @MainActor (_ wordIndex: Int, _ word: String) -> Void
    ) {
        self.levelPlan = levelPlan
        self.reportLanding = reportLanding
        super.init(size: size)
        scaleMode = .resizeFill
    }

    required init?(coder: NSCoder) { nil }

    override func didMove(to view: SKView) {
        guard cameraNode.parent == nil else { return }
        backgroundColor = SKColor(red: 0.03, green: 0.10, blue: 0.26, alpha: 1)
        addChild(cameraNode)
        camera = cameraNode
        sky.zPosition = -100
        cameraNode.addChild(sky)
        addChild(platformLayer)
        addPlayer()
        layoutWorld()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard cameraNode.parent != nil, size.width > 0, size.height > 0 else { return }
        layoutWorld()
    }

    private func layoutWorld() {
        // With a camera, (0, 0) is the centre of the viewport, not its lower-left.
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        let textureSize = sky.texture?.size() ?? CGSize(width: 1, height: 1)
        let scale = max(size.width / textureSize.width, size.height / textureSize.height)
        sky.size = CGSize(width: textureSize.width * scale, height: textureSize.height * scale)
        platformLayer.removeAllChildren()
        platforms.removeAll()
        makePlatforms()
        returnToCheckpoint()
        lastUpdateTime = 0
    }

    private func addPlayer() {
        player.size = CGSize(width: 72, height: 72)
        player.zPosition = 20
        addChild(player)
    }

    private func makePlatforms() {
        for (index, word) in levelPlan.words.enumerated() {
            let width = min(size.width - 36, max(112, min(194, CGFloat(word.count * 14 + 48))))
            let x = platformX(for: index, width: width)
            let y = max(156, size.height * 0.22) + CGFloat(index * 112)
            let frame = CGRect(x: x - width / 2, y: y - 26, width: width, height: 52)
            let platform = makePlatform(word: word, index: index, frame: frame)
            platformLayer.addChild(platform)
            platforms.append((index, word, frame))
        }
    }

    private func makePlatform(word: String, index: Int, frame: CGRect) -> SKNode {
        let container = SKNode()
        let shadow = SKShapeNode(rect: frame.offsetBy(dx: 0, dy: -8), cornerRadius: 24)
        shadow.fillColor = SKColor.black.withAlphaComponent(0.28)
        shadow.strokeColor = .clear
        container.addChild(shadow)

        let island = SKShapeNode(rect: frame, cornerRadius: 24)
        island.fillColor = index.isMultiple(of: 2)
            ? SKColor(red: 0.04, green: 0.66, blue: 0.67, alpha: 1)
            : SKColor(red: 0.95, green: 0.31, blue: 0.17, alpha: 1)
        island.strokeColor = SKColor.white.withAlphaComponent(0.62)
        island.lineWidth = 2
        container.addChild(island)

        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = word
        label.fontSize = min(30, max(18, 280 / CGFloat(max(word.count, 1))))
        if label.frame.width > frame.width - 24 {
            label.fontSize *= (frame.width - 24) / label.frame.width
        }
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: frame.midX, y: frame.midY - 1)
        label.fontColor = .white
        label.zPosition = 1
        container.addChild(label)
        return container
    }

    private func platformX(for index: Int, width: CGFloat) -> CGFloat {
        if index == 0 { return size.width / 2 }
        let sidePadding = width / 2 + 18
        // Keep neighbouring jumps reachable on iPad and in landscape too.
        let availableWidth = min(200, max(size.width - sidePadding * 2, 1))
        let pattern = CGFloat((index * 71 + 43) % 100) / 100
        return size.width / 2 + availableWidth * (pattern - 0.5)
    }

    override func update(_ currentTime: TimeInterval) {
        guard !platforms.isEmpty else { return }
        guard lastUpdateTime > 0 else {
            lastUpdateTime = currentTime
            return
        }

        let delta = min(currentTime - lastUpdateTime, 1.0 / 30.0)
        lastUpdateTime = currentTime
        if let steeringTargetX {
            playerVelocity.dx = min(340, max(-340, (steeringTargetX - player.position.x) * 7))
        } else {
            playerVelocity.dx = 0
        }
        playerVelocity.dy -= 1_520 * delta
        player.position.x = min(max(player.position.x + playerVelocity.dx * delta, 38), size.width - 38)
        let previousY = player.position.y
        player.position.y += playerVelocity.dy * delta
        landOnPlatform(from: previousY)
        cameraNode.position.x = size.width / 2
        cameraNode.position.y = max(cameraNode.position.y, player.position.y + size.height * 0.08)

        if player.position.y < cameraNode.position.y - size.height / 2 - player.size.height {
            returnToCheckpoint()
        }
    }

    private func returnToCheckpoint() {
        guard !platforms.isEmpty else { return }
        let checkpoint = platforms[max(0, lastLandedPlatform)]
        player.position = CGPoint(x: checkpoint.frame.midX, y: checkpoint.frame.maxY + playerFootOffset + 2)
        // Drop gently onto the opening word before the first automatic jump.
        playerVelocity = .zero
        steeringTargetX = nil
        cameraNode.position = CGPoint(
            x: size.width / 2,
            y: max(size.height / 2, player.position.y + size.height * 0.08)
        )
    }

    private func landOnPlatform(from previousY: CGFloat) {
        guard playerVelocity.dy < 0 else { return }

        for platform in platforms.reversed() where previousY - playerFootOffset >= platform.frame.maxY
            && player.position.y - playerFootOffset <= platform.frame.maxY
            && platform.frame.insetBy(dx: -14, dy: 0).contains(CGPoint(x: player.position.x, y: platform.frame.maxY)) {
            player.position.y = platform.frame.maxY + playerFootOffset
            playerVelocity.dy = jumpSpeed
            player.zRotation = 0

            if platform.index > lastLandedPlatform {
                lastLandedPlatform = platform.index
                playLandingPulse(at: platform.frame)
                Task { @MainActor in reportLanding(platform.index, platform.word) }
            }
            return
        }
    }

    private func playLandingPulse(at frame: CGRect) {
        let glow = SKShapeNode(ellipseIn: frame.insetBy(dx: -12, dy: -12))
        glow.fillColor = SKColor.white.withAlphaComponent(0.24)
        glow.strokeColor = .clear
        glow.zPosition = -1
        addChild(glow)
        glow.run(.sequence([.scale(to: 1.25, duration: 0.18), .fadeOut(withDuration: 0.20), .removeFromParent()]))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        steeringTargetX = touch.location(in: self).x
        player.xScale = touch.location(in: self).x < player.position.x ? -1 : 1
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        steeringTargetX = nil
        playerVelocity.dx = 0
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
}
