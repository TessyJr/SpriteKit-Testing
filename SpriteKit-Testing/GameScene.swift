import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var label: SKLabelNode = SKLabelNode()
    var sceneCamera: SKCameraNode = SKCameraNode()
    
    var inputs: String = ""
    let moveAmount: CGFloat = 16.0
    
    var character: SKSpriteNode = SKSpriteNode()
    var availableSpots = [CGPoint]()
    
    var highlight = SKSpriteNode()
    var isTouchEnded: Bool = false
    
    override func didMove(to view: SKView) {
        self.sceneCamera = childNode(withName: "sceneCamera") as! SKCameraNode
        self.label = sceneCamera.childNode(withName: "label") as! SKLabelNode
        
        for node in self.children {
            if let someTileMap: SKTileMapNode = node as? SKTileMapNode {
                giveTileMapPhysicsBody(map: someTileMap)
                
                someTileMap.removeFromParent()
            }
        }
        
        if (self.childNode(withName: "player") != nil) {
            character = self.childNode(withName: "player") as! SKSpriteNode
            character.physicsBody?.categoryBitMask = bitMask.person.rawValue
            character.physicsBody?.contactTestBitMask = bitMask.sand.rawValue
            character.physicsBody?.collisionBitMask = bitMask.wall.rawValue
            character.physicsBody?.allowsRotation = false
            character.physicsBody?.affectedByGravity = false
        }
    }
    
    func giveTileMapPhysicsBody(map: SKTileMapNode) {
        let tileMap = map
        let startLocation: CGPoint = tileMap.position
        let tileSize = tileMap.tileSize
        let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * tileSize.width
        let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * tileSize.height
        
        for col in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                
                if let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row) {
                    
                    let tileArray = tileDefinition.textures
                    let tileTextures = tileArray[0]
                    let x = CGFloat(col) * tileSize.width - halfWidth + ( tileSize.width / 2 )
                    let y = CGFloat(row) * tileSize.height - halfHeight + ( tileSize.height / 2 )
                    
                    let tileNode = SKSpriteNode(texture: tileTextures)
                    tileNode.position = CGPoint(x: x, y: y)
                    tileNode.size = CGSize(width: 16, height: 16)
                    tileNode.physicsBody = SKPhysicsBody(texture: tileTextures, size: CGSize(width: 16, height: 16))
                    
                    if tileMap.name == "wall" {
                        tileNode.physicsBody?.categoryBitMask = bitMask.wall.rawValue
                        tileNode.physicsBody?.contactTestBitMask = 0
                        tileNode.physicsBody?.collisionBitMask = bitMask.person.rawValue
                    }
                    else if tileMap.name == "floor" {
                        tileNode.physicsBody?.categoryBitMask = bitMask.sand.rawValue
                        tileNode.physicsBody?.contactTestBitMask = bitMask.raycast.rawValue
                        tileNode.physicsBody?.collisionBitMask = 0
                    }
                    
                    tileNode.physicsBody?.affectedByGravity = false
                    tileNode.physicsBody?.isDynamic = false
                    tileNode.physicsBody?.friction = 1
                    tileNode.zPosition = 1
                    
                    tileNode.position = CGPoint(x: tileNode.position.x + startLocation.x, y: tileNode.position.y + startLocation.y)
                    self.addChild(tileNode)
                }
            }
        }
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123:
            // Move character left
            character.texture = SKTexture(imageNamed: "character-left")
            let moveLeftAction = SKAction.moveBy(x: -moveAmount, y: 0, duration: 0.2)
            character.run(moveLeftAction)
            
        case 124:
            // Move character right
            character.texture = SKTexture(imageNamed: "character-right")
            let moveRightAction = SKAction.moveBy(x: moveAmount, y: 0, duration: 0.2)
            character.run(moveRightAction)
            
        case 126:
            // Move character up
            character.texture = SKTexture(imageNamed: "character-up")
            let moveUpAction = SKAction.moveBy(x: 0, y: moveAmount, duration: 0.2)
            character.run(moveUpAction)
            
        case 125:
            // Move character down
            character.texture = SKTexture(imageNamed: "character-down")
            let moveDownAction = SKAction.moveBy(x: 0, y: -moveAmount, duration: 0.2)
            character.run(moveDownAction)
            
        case 36:
            // Print label on ENTER
            print(label.text ?? "")
            inputs = ""
            label.text = inputs
            
        default:
            inputs.append(event.characters!)
            label.text = inputs
            break
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        sceneCamera.position = character.position
    }
}
