import SpriteKit
import GameplayKit

class NPC {
    var spriteNode: SKSpriteNode = SKSpriteNode()
    var dialogLabelNode: SKLabelNode = SKLabelNode()
    
    var status: Status = .idle
    var direction: Direction = .left
    
    let moveAmount: CGFloat = 16.0
    var moveSpeed: CGFloat = 0.2
    
    let dialog: [String]
    
    init(dialog: [String] = []) {
        self.dialog = dialog
    }
    
    var currentDialog: Int = 0
    var isDialogDone: Bool = false
    
    func animateSprite() {
        spriteNode.removeAllActions()
        
        var textures: [SKTexture] = []
        
        switch status {
        case .moving:
            for i in 1...2 {
                let textureName = "player-move-\(direction)-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let moveAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
            spriteNode.run(moveAnimation)
        case .idle:
            for i in 1...2 {
                let textureName = "player-idle-\(direction)-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let idleAnimation = SKAction.animate(with: textures, timePerFrame: 0.2)
            let repeatIdleAnimation = SKAction.repeatForever(idleAnimation)
            
            spriteNode.run(repeatIdleAnimation)
        default:
            break
        }
    }
    
    func interactWith(scene: ExplorationSceneProtocol) {}
}

class NPC1: NPC {
    init() {
        super.init(dialog: [
            "Hello, young wizard!",
            "It looks like you are ready to challenge this tower.",
            "Enter this door to go to the next room.",
            "But before I open this door, let's practice first!"
        ])
    }
    
    override func interactWith(scene: ExplorationSceneProtocol) {
        if status == .moving {
            return
        }
        
        switch scene.player.direction {
        case .up:
            direction = .down
        case .down:
            direction = .up
        case .left:
            direction = .right
        case .right:
            direction = .left
        }
        animateSprite()
        
        if currentDialog == 999 {
            scene.player.isInteracting = false
            return
        }
        
        if currentDialog == dialog.count {
            dialogLabelNode.text = ""
            currentDialog = 999
            isDialogDone = true
            
            scene.lastPlayerCoordinates = scene.player.spriteNode.position
            
            if let battleScene = GKScene(fileNamed: "BattleScene") {
                if let sceneNode = battleScene.rootNode as! BattleScene? {
                    sceneNode.scaleMode = .aspectFit
                    sceneNode.previousScene = scene
                    sceneNode.player = scene.player
                    sceneNode.player.isInteracting = false
                    sceneNode.enemy = Enemy.create(enemyType: "npc")!
                    
                    if let view = scene.view {
                        let transition = SKTransition.fade(withDuration: 1.0)
                        view.presentScene(sceneNode, transition: transition)
                    }
                }
            }
            
            return
        }
        
        dialogLabelNode.text = dialog[currentDialog]
        currentDialog += 1
    }
    
    func move(direction: Direction, completion: @escaping () -> Void) {
        status = .moving
        self.direction = direction
        animateSprite()
        
        let moveToCoordinate: CGPoint
        let moveAction: SKAction
        
        switch direction {
        case .left:
            moveToCoordinate = CGPoint(x: round(spriteNode.position.x - moveAmount), y: round(spriteNode.position.y))
            moveAction = SKAction.moveBy(x: -moveAmount, y: 0, duration: moveSpeed)
            
        case .right:
            moveToCoordinate = CGPoint(x: round(spriteNode.position.x + moveAmount), y: round(spriteNode.position.y))
            moveAction = SKAction.moveBy(x: moveAmount, y: 0, duration: moveSpeed)
            
        case .up:
            moveToCoordinate = CGPoint(x: round(spriteNode.position.x), y: round(spriteNode.position.y + moveAmount))
            moveAction = SKAction.moveBy(x: 0, y: moveAmount, duration: moveSpeed)
            
        case .down:
            moveToCoordinate = CGPoint(x: round(spriteNode.position.x), y: round(spriteNode.position.y - moveAmount))
            moveAction = SKAction.moveBy(x: 0, y: -moveAmount, duration: moveSpeed)
        }
        
        // Define the completion action to round the position
        let roundPositionAction = SKAction.run {
            self.spriteNode.position = moveToCoordinate
            
            self.status = .idle
            self.animateSprite()
            
            completion()
        }
        
        // Create a sequence of the move action followed by the round position action
        let sequence = SKAction.sequence([moveAction, roundPositionAction])
        
        // Run the sequence on the sprite node
        spriteNode.run(sequence)
    }
}
