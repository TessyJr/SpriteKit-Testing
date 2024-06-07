import SpriteKit

enum Direction {
    case left, right, up, down
}

class Player {
    var spriteNode: SKSpriteNode = SKSpriteNode()
    
    var moveAmount: CGFloat = 16.0
    
    var currentHealth: Int = 100
    var maxHealth: Int = 100
    
    var inputSpell: String = ""
    
    func setupSpriteNode() {
        spriteNode.physicsBody?.categoryBitMask = bitMask.player.rawValue
        spriteNode.physicsBody?.contactTestBitMask = bitMask.floor.rawValue | bitMask.trapdoor.rawValue
        spriteNode.physicsBody?.collisionBitMask = bitMask.wall.rawValue
    }
    
    func move(direction: Direction) {
        let texture: SKTexture
        let moveAction: SKAction
        
        switch direction {
        case .left:
            texture = SKTexture(imageNamed: "character-left")
            moveAction = SKAction.moveBy(x: -moveAmount, y: 0, duration: 0.1)
            
        case .right:
            texture = SKTexture(imageNamed: "character-right")
            moveAction = SKAction.moveBy(x: moveAmount, y: 0, duration: 0.1)
            
        case .up:
            texture = SKTexture(imageNamed: "character-up")
            moveAction = SKAction.moveBy(x: 0, y: moveAmount, duration: 0.1)
            
        case .down:
            texture = SKTexture(imageNamed: "character-down")
            moveAction = SKAction.moveBy(x: 0, y: -moveAmount, duration: 0.1)
        }
        
        //        spriteNode.texture = texture
        spriteNode.run(moveAction)
    }
}
