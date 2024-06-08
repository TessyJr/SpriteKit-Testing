import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var sceneCamera: SKCameraNode = SKCameraNode()
    
    var floorCoordinates = [CGPoint]()
    
    var wallCoordinates = [CGPoint]()
    
    var damageFloorCoordinates = [CGPoint]()
    var damageFloorNodes = [SKSpriteNode]()
    
    var trapdoorNode: SKSpriteNode?
    
    var player: Player = Player()
    var labelSpell: SKLabelNode = SKLabelNode()
    var labelHealth: SKLabelNode = SKLabelNode()
    
    override func didMove(to view: SKView) {
        sceneCamera = childNode(withName: "sceneCamera") as! SKCameraNode
        
        for node in self.children {
            if let someTileMap: SKTileMapNode = node as? SKTileMapNode {
                giveTileMapPhysicsBody(map: someTileMap)
            }
        }
        
        player.spriteNode = childNode(withName: "player") as! SKSpriteNode
        player.spriteNode.position = floorCoordinates.randomElement()!
        
        labelSpell = player.spriteNode.childNode(withName: "labelSpell") as! SKLabelNode
        
        labelHealth = player.spriteNode.childNode(withName: "labelHealth") as! SKLabelNode
        labelHealth.text = "\(player.currentHealth)"
        
        // Generate a random trapdoor in the floor coordinates by changing the texture into "trapdoor"
        changeRandomFloorTileToTrapdoor()
    }
    
    func giveTileMapPhysicsBody(map: SKTileMapNode) {
        let tileMap = map
        let tileSize = tileMap.tileSize
        let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * tileSize.width
        let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * tileSize.height
        
        for col in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                if let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row) {
                    let x = CGFloat(col) * tileSize.width - halfWidth + (tileSize.width / 2)
                    let y = CGFloat(row) * tileSize.height - halfHeight + (tileSize.height / 2)
                    
                    let tileCoordinate = CGPoint(x: x, y: y)
                    
                    if let isSolid = tileDefinition.userData?["isSolid"] as? Bool {
                        if isSolid {
                            wallCoordinates.append(tileCoordinate)
                        } else {
                            floorCoordinates.append(tileCoordinate)
                        }
                    }
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
            
            self.addChild(trapdoorNode)
            self.trapdoorNode = trapdoorNode
        }
    }
    
    func goToBattleScene() {
        if player.spriteNode.position == trapdoorNode?.position {
            if let scene = GKScene(fileNamed: "BattleScene") {
                if let sceneNode = scene.rootNode as! BattleScene? {
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
            player.move(direction: .left, wallCoordinates: wallCoordinates, damageFloorCoordinates: damageFloorCoordinates, completion: goToBattleScene)
            
        case 124:
            player.move(direction: .right, wallCoordinates: wallCoordinates, damageFloorCoordinates: damageFloorCoordinates, completion: goToBattleScene)
            
        case 126:
            player.move(direction: .up, wallCoordinates: wallCoordinates, damageFloorCoordinates: damageFloorCoordinates, completion: goToBattleScene)
            
        case 125:
            player.move(direction: .down, wallCoordinates: wallCoordinates, damageFloorCoordinates: damageFloorCoordinates, completion: goToBattleScene)
            
        case 36:
            player.inputSpell = ""
            labelSpell.text = player.inputSpell
            
        default:
            player.inputSpell.append(event.characters!)
            labelSpell.text = player.inputSpell
            break
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        sceneCamera.position = player.spriteNode.position
        labelHealth.text = "\(player.currentHealth)"
    }
}
