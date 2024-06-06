import SpriteKit

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
        spriteNode.physicsBody?.allowsRotation = false
        spriteNode.physicsBody?.affectedByGravity = false
    }
}
