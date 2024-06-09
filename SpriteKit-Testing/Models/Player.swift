import SpriteKit

enum Direction {
    case left, right, up, down
}

class Player {
    var spriteNode: SKSpriteNode = SKSpriteNode()
    
    var isMoving: Bool = false
    var isInvincible: Bool = false
    
    let moveAmount: CGFloat = 16.0
    var moveSpeed: CGFloat = 0.1
    
    var currentHealth: Int = 50
    var maxHealth: Int = 50
    
    var inputSpell: String = ""
    
    func castSpell(spell: String, enemy: Enemy) {
        switch spell {
        case "fireball":
            enemy.currentHealth -= 10
            
        case "avada kedavra":
            enemy.currentHealth -= enemy.currentHealth
            
        default:
            break;
        }
    }
    
    func getDamage() {
        if !isInvincible {
            currentHealth -= 10
            isInvincible = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.isInvincible = false
            }
        }
    }
    
    func checkIfStandingOnDamageTile(damageFloorCoordinates: [CGPoint]) {
        let currentCoordinates = CGPoint(x: round(spriteNode.position.x), y: round(spriteNode.position.y))
        
        if damageFloorCoordinates.contains(currentCoordinates) {
            self.getDamage()
        }
    }
    
    func changeDirection(direction: Direction) {
        let texture: SKTexture
        
        switch direction {
        case .left:
            texture = SKTexture(imageNamed: "character-left")
            
        case .right:
            texture = SKTexture(imageNamed: "character-right")
            
        case .up:
            texture = SKTexture(imageNamed: "character-up")
            
        case .down:
            texture = SKTexture(imageNamed: "character-down")
        }
        
        spriteNode.texture = texture
    }
    
    func move(direction: Direction, wallCoordinates: [CGPoint], damageFloorCoordinates: [CGPoint] = [], completion: @escaping () -> Void) {
        if isMoving {
            return
        }
    
        isMoving = true
        
        changeDirection(direction: direction)
        
        let moveAction: SKAction
        let moveToCoordinate: CGPoint
        
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
        
        // If move to coordinate is a wall DONT move
        if wallCoordinates.contains(moveToCoordinate) {
            self.isMoving = false
            return
        }
        
        // Define the completion action to round the position
        let roundPositionAction = SKAction.run {
            self.spriteNode.position = moveToCoordinate
            
            self.checkIfStandingOnDamageTile(damageFloorCoordinates: damageFloorCoordinates)
            
            self.isMoving = false
            
            completion()
        }
        
        // Create a sequence of the move action followed by the round position action
        let sequence = SKAction.sequence([moveAction, roundPositionAction])
        
        // Run the sequence on the sprite node
        spriteNode.run(sequence)
    }
}
