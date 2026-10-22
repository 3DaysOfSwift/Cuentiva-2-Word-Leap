import SpriteKit
import UIKit

final class WordLeapScene: SKScene {
    private let levelPlan: LevelPlan
    private let reportLanding: @MainActor (_ wordIndex: Int, _ word: String) -> Void
    private let player = SKSpriteNode(imageNamed: "WordLeapHero")
    private let cameraNode = SKCameraNode()
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
        backgroundColor = SKColor(red: 0.03, green: 0.10, blue: 0.26, alpha: 1)
        addChild(cameraNode)
        camera = cameraNode
        addSky()
        makePlatforms()
        addPlayer()
    }

    private func addSky() {
        let sky = SKSpriteNode(imageNamed: "WordLeapSky")
        let widthScale = size.width / max(sky.size.width, 1)
        let heightScale = size.height / max(sky.size.height, 1)
        sky.setScale(max(widthScale, heightScale))
        sky.position = .zero
        sky.zPosition = -100
        cameraNode.addChild(sky)
    }

    private func addPlayer() {
        player.size = CGSize(width: 88, height: 88)
        player.position = CGPoint(x: size.width / 2, y: 132)
        player.zPosition = 20
        addChild(player)
    }

    private func makePlatforms() {
        for (index, word) in levelPlan.words.enumerated() {
            let width = max(132, min(218, CGFloat(word.count * 17 + 72)))
            let x = platformX(for: index, width: width)
            let y = CGFloat(78 + index * 130)
            let frame = CGRect(x: x - width / 2, y: y - 26, width: width, height: 52)
            let platform = makePlatform(word: word, index: index, frame: frame)
            addChild(platform)
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
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: frame.midX, y: frame.midY - 1)
        label.fontColor = .white
        label.zPosition = 1
        container.addChild(label)
        return container
    }

    private func platformX(for index: Int, width: CGFloat) -> CGFloat {
        let sidePadding = width / 2 + 18
        let availableWidth = max(size.width - sidePadding * 2, 1)
        let pattern = CGFloat((index * 71 + 43) % 100) / 100
        return sidePadding + availableWidth * pattern
    }

    override func update(_ currentTime: TimeInterval) {
        guard lastUpdateTime > 0 else {
            lastUpdateTime = currentTime
            playerVelocity.dy = 650
            return
        }

        let delta = min(currentTime - lastUpdateTime, 1.0 / 30.0)
        lastUpdateTime = currentTime
        playerVelocity.dy -= 1_520 * delta
        player.position.x = min(max(player.position.x + playerVelocity.dx * delta, 38), size.width - 38)
        let previousY = player.position.y
        player.position.y += playerVelocity.dy * delta
        landOnPlatform(from: previousY)
        cameraNode.position.y = max(0, player.position.y - size.height * 0.34)

        if player.position.y < cameraNode.position.y - size.height / 2 {
            player.position = CGPoint(x: size.width / 2, y: cameraNode.position.y + 144)
            playerVelocity = CGVector(dx: 0, dy: 650)
        }
    }

    private func landOnPlatform(from previousY: CGFloat) {
        guard playerVelocity.dy < 0 else { return }

        for platform in platforms where previousY - 38 >= platform.frame.maxY
            && player.position.y - 38 <= platform.frame.maxY
            && platform.frame.insetBy(dx: -14, dy: 0).contains(CGPoint(x: player.position.x, y: platform.frame.maxY)) {
            player.position.y = platform.frame.maxY + 38
            playerVelocity.dy = 650
            player.zRotation = 0

            if lastLandedPlatform != platform.index {
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
        playerVelocity.dx = (touch.location(in: self).x - player.position.x) * 3.5
        player.xScale = playerVelocity.dx < 0 ? -1 : 1
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerVelocity.dx *= 0.24
    }
}
