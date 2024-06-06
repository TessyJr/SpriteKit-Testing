import SpriteKit

enum bitMask: UInt32 {
    case person = 0x1
    case sand = 0x5
    case highlight = 0x3
    case wall = 0x2
    case raycast = 0x4
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bitmaskA = contact.bodyA.categoryBitMask
        let bitmaskB = contact.bodyB.categoryBitMask
        
        if (bitmaskA == bitMask.raycast.rawValue && bitmaskB == bitMask.sand.rawValue && !isTouchEnded) {
            highlight.position = contact.bodyB.node!.position
            isTouchEnded = false
            
        } else if (bitmaskA == bitMask.sand.rawValue && bitmaskB == bitMask.raycast.rawValue && !isTouchEnded) {
            highlight.position = contact.bodyA.node!.position
            isTouchEnded = false
        }
    }
}
