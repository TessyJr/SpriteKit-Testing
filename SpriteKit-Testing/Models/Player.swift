import SpriteKit

enum Direction {
    case left, right, up, down
}

class Player {
    var spriteNode: SKSpriteNode = SKSpriteNode()
    
    var isMoving: Bool = false
    
    let moveAmount: CGFloat = 16.0
    let moveSpeed: CGFloat = 0.2
    
    var currentHealth: Int = 100
    var maxHealth: Int = 100
    
    var inputSpell: String = ""
    
    func move(direction: Direction) {
        if isMoving {
            return
        }
        
        isMoving = true
        
        let texture: SKTexture
        let moveAction: SKAction
        
        switch direction {
        case .left:
            texture = SKTexture(imageNamed: "character-left")
            moveAction = SKAction.moveBy(x: -moveAmount, y: 0, duration: moveSpeed)
            
        case .right:
            texture = SKTexture(imageNamed: "character-right")
            moveAction = SKAction.moveBy(x: moveAmount, y: 0, duration: moveSpeed)
            
        case .up:
            texture = SKTexture(imageNamed: "character-up")
            moveAction = SKAction.moveBy(x: 0, y: moveAmount, duration: moveSpeed)
            
        case .down:
            texture = SKTexture(imageNamed: "character-down")
            moveAction = SKAction.moveBy(x: 0, y: -moveAmount, duration: moveSpeed)
        }
        
        // Define the completion action to round the position
        let roundPositionAction = SKAction.run {
            self.spriteNode.position.x = round(self.spriteNode.position.x)
            self.spriteNode.position.y = round(self.spriteNode.position.y)
            
            print("Current coordinates: \(self.spriteNode.position)")
            
            self.isMoving = false
        }
        
        // Create a sequence of the move action followed by the round position action
        spriteNode.texture = texture
        let sequence = SKAction.sequence([moveAction, roundPositionAction])
        
        // Run the sequence on the sprite node
        spriteNode.run(sequence)
    }
}
