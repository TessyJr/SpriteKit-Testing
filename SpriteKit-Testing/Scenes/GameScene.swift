import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var sceneCamera: SKCameraNode = SKCameraNode()
    
    var floorCoordinates = [CGPoint]()
    var trapdoorNode: SKSpriteNode?
    
    var player: Player = Player()
    
    var labelSpell: SKLabelNode = SKLabelNode()
    var labelHealth: SKLabelNode = SKLabelNode()
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        sceneCamera = childNode(withName: "sceneCamera") as! SKCameraNode
        
        for node in self.children {
            if let someTileMap: SKTileMapNode = node as? SKTileMapNode {
                giveTileMapPhysicsBody(map: someTileMap)
            }
        }
        
        player.spriteNode = childNode(withName: "background")!.childNode(withName: "player") as! SKSpriteNode
        player.setupSpriteNode()
        player.spriteNode.position = floorCoordinates.randomElement()!
        
        labelSpell = player.spriteNode.childNode(withName: "labelSpell") as! SKLabelNode
        
        labelHealth = player.spriteNode.childNode(withName: "labelHealth") as! SKLabelNode
        labelHealth.text = "\(player.currentHealth)"
        
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
                    
                    if let isSolid = tileDefinition.userData?["isSolid"] as? Bool {
                        if isSolid {
                            tileNode.physicsBody?.categoryBitMask = bitMask.wall.rawValue
                            tileNode.physicsBody?.contactTestBitMask = 0
                            tileNode.physicsBody?.collisionBitMask = bitMask.player.rawValue
                        } else {
                            tileNode.physicsBody?.categoryBitMask = bitMask.floor.rawValue
                            tileNode.physicsBody?.collisionBitMask = 0
                            
                            let newPoint = CGPoint(x: x, y: y)
                            let newPointConverted = self.convert(newPoint, from: tileMap)
                            
                            floorCoordinates.append(newPointConverted)
                        }
                    }
                    
                    tileNode.physicsBody?.affectedByGravity = false
                    tileNode.physicsBody?.isDynamic = false
                    tileNode.physicsBody?.friction = 1
                    tileNode.zPosition = 0
                    
                    tileNode.position = CGPoint(x: tileNode.position.x + startLocation.x, y: tileNode.position.y + startLocation.y)
                    self.addChild(tileNode)
                }
            }
        }
        
        print(floorCoordinates)
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
            trapdoorNode.zPosition = 0
            
            self.addChild(trapdoorNode)
            self.trapdoorNode = trapdoorNode
            
            print(trapdoorNode.position)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if (firstBody.categoryBitMask == bitMask.player.rawValue && secondBody.categoryBitMask == bitMask.trapdoor.rawValue) || (secondBody.categoryBitMask == bitMask.player.rawValue && firstBody.categoryBitMask == bitMask.trapdoor.rawValue) {
            print("Player is on the trapdoor!")
            player.currentHealth -= 10
            
            // Change scene after health is reduced
            
            if let scene = GKScene(fileNamed: "GameScene2") {
                if let sceneNode = scene.rootNode as! GameScene2? {
                    sceneNode.scaleMode = .aspectFit
                    sceneNode.player = self.player
                    
                    if let view = self.view {
                        let transition = SKTransition.fade(withDuration: 1.0)
                        view.presentScene(sceneNode, transition: transition)
                        view.showsFPS = true
                        view.showsNodeCount = true
                    }
                }
            }
        }
        
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123:
            // Move character left
            player.move(direction: .left)
            
        case 124:
            // Move character right
            player.move(direction: .right)
            
        case 126:
            // Move character up
            player.move(direction: .up)
            
        case 125:
            // Move character down
            player.move(direction: .down)
            
        case 36:
            // Print label on ENTER
            player.inputSpell = ""
            labelSpell.text = player.inputSpell
            
        default:
            player.inputSpell.append(event.characters!)
            labelSpell.text = player.inputSpell
            break
        }
        
        print(player.spriteNode.position)
    }
    
    override func update(_ currentTime: TimeInterval) {
        sceneCamera.position = player.spriteNode.position
        labelHealth.text = "\(player.currentHealth)"
    }
}
