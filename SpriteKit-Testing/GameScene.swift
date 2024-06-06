import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var label: SKLabelNode = SKLabelNode()
    var sceneCamera: SKCameraNode = SKCameraNode()
    
    var inputs: String = ""
    let moveAmount: CGFloat = 16.0
    
    var player: SKSpriteNode = SKSpriteNode()
    var floorCoordinates = [CGPoint]()
    var trapdoorNode: SKSpriteNode?
    
    override func didMove(to view: SKView) {
        self.sceneCamera = childNode(withName: "sceneCamera") as! SKCameraNode
        self.physicsWorld.contactDelegate = self
        
        for node in self.children {
            if let someTileMap: SKTileMapNode = node as? SKTileMapNode {
                giveTileMapPhysicsBody(map: someTileMap)
                someTileMap.removeFromParent()
            }
        }
        
        if (self.childNode(withName: "player") != nil) {
            player = self.childNode(withName: "player") as! SKSpriteNode
            player.physicsBody?.categoryBitMask = bitMask.player.rawValue
            player.physicsBody?.contactTestBitMask = bitMask.floor.rawValue | bitMask.trapdoor.rawValue
            player.physicsBody?.collisionBitMask = bitMask.wall.rawValue
            player.physicsBody?.allowsRotation = false
            player.physicsBody?.affectedByGravity = false
        }
        
        self.label = self.player.childNode(withName: "label") as! SKLabelNode
        
        // Generate a random trapdoor in the floor coordinates by changing the texture into "trapdoor"
        changeRandomFloorTileToTrapdoor()
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
                    let x = CGFloat(col) * tileSize.width - halfWidth + (tileSize.width / 2)
                    let y = CGFloat(row) * tileSize.height - halfHeight + (tileSize.height / 2)
                    
                    let tileNode = SKSpriteNode(texture: tileTextures)
                    tileNode.position = CGPoint(x: x, y: y)
                    tileNode.size = CGSize(width: 16, height: 16)
                    tileNode.physicsBody = SKPhysicsBody(texture: tileTextures, size: CGSize(width: 16, height: 16))
                    
                    if tileMap.name == "wall" {
                        tileNode.physicsBody?.categoryBitMask = bitMask.wall.rawValue
                        tileNode.physicsBody?.contactTestBitMask = 0
                        tileNode.physicsBody?.collisionBitMask = bitMask.player.rawValue
                    } else if tileMap.name == "floor" {
                        tileNode.physicsBody?.categoryBitMask = bitMask.floor.rawValue
                        tileNode.physicsBody?.collisionBitMask = 0
                        
                        let newPoint = CGPoint(x: x, y: y)
                        let newPointConverted = self.convert(newPoint, from: tileMap)
                        
                        floorCoordinates.append(newPointConverted)
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
    
    func changeRandomFloorTileToTrapdoor() {
        if let randomFloorCoordinate = floorCoordinates.randomElement() {
            let trapdoorTexture = SKTexture(imageNamed: "trapdoor")
            let trapdoorNode = SKSpriteNode(texture: trapdoorTexture)
            trapdoorNode.position = randomFloorCoordinate
            trapdoorNode.size = CGSize(width: 16, height: 16)
            trapdoorNode.physicsBody = SKPhysicsBody(texture: trapdoorTexture, size: trapdoorNode.size)
            trapdoorNode.physicsBody?.categoryBitMask = bitMask.trapdoor.rawValue
            trapdoorNode.physicsBody?.collisionBitMask = 0
            trapdoorNode.physicsBody?.contactTestBitMask = bitMask.player.rawValue
            trapdoorNode.physicsBody?.affectedByGravity = false
            trapdoorNode.physicsBody?.isDynamic = false
            trapdoorNode.physicsBody?.friction = 1
            trapdoorNode.zPosition = 1
            
            self.addChild(trapdoorNode)
            self.trapdoorNode = trapdoorNode
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if (firstBody.categoryBitMask == bitMask.player.rawValue && secondBody.categoryBitMask == bitMask.trapdoor.rawValue) || (secondBody.categoryBitMask == bitMask.player.rawValue && firstBody.categoryBitMask == bitMask.trapdoor.rawValue) {
            print("Player is on the trapdoor!")
        }
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123:
            // Move character left
            player.texture = SKTexture(imageNamed: "character-left")
            let moveLeftAction = SKAction.moveBy(x: -moveAmount, y: 0, duration: 0.2)
            player.run(moveLeftAction)
            
        case 124:
            // Move character right
            player.texture = SKTexture(imageNamed: "character-right")
            let moveRightAction = SKAction.moveBy(x: moveAmount, y: 0, duration: 0.2)
            player.run(moveRightAction)
            
        case 126:
            // Move character up
            player.texture = SKTexture(imageNamed: "character-up")
            let moveUpAction = SKAction.moveBy(x: 0, y: moveAmount, duration: 0.2)
            player.run(moveUpAction)
            
        case 125:
            // Move character down
            player.texture = SKTexture(imageNamed: "character-down")
            let moveDownAction = SKAction.moveBy(x: 0, y: -moveAmount, duration: 0.2)
            player.run(moveDownAction)
            
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
        sceneCamera.position = player.position
    }
}
