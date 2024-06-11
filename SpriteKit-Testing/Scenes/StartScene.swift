import SpriteKit
import GameplayKit

class StartScene: SKScene, StartSceneProtocol {
    var sceneCamera: SKCameraNode = SKCameraNode()
    
    var floorCoordinates: [CGPoint] = [CGPoint]()
    
    var wallCoordinates: [CGPoint] = [CGPoint]()
    
    var player: Player = Player()
    var labelPlayerSpell: SKLabelNode = SKLabelNode()
    var labelPlayerHealth: SKLabelNode = SKLabelNode()
    
    var spawnCoordinate: CGPoint = CGPoint()
    var nextSceneCoordinate: CGPoint = CGPoint()
    
    override func didMove(to view: SKView) {
        sceneCamera = childNode(withName: "sceneCamera") as! SKCameraNode
        
        for node in self.children {
            if let someTileMap = node as? SKTileMapNode {
                if someTileMap.name == "background" {
                    setUpWallsAndFloors(map: someTileMap)
                } else if someTileMap.name == "point" {
                    setUpPoints(map: someTileMap)
                }
            }
        }
        
        setUpPlayer()
    }
    
    func setUpPlayer() {
        player.spriteNode = childNode(withName: "player") as! SKSpriteNode
        player.spriteNode.position = spawnCoordinate
        
        labelPlayerSpell = player.spriteNode.childNode(withName: "labelPlayerSpell") as! SKLabelNode
        labelPlayerHealth = player.spriteNode.childNode(withName: "labelPlayerHealth") as! SKLabelNode
        labelPlayerHealth.text = "\(player.currentHealth)"
    }
    
    func setUpPoints(map: SKTileMapNode) {
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
                    
                    if let isSpawnPoint = tileDefinition.userData?["isSpawnPoint"] as? Bool {
                        if isSpawnPoint {
                            spawnCoordinate = tileCoordinate
                        }
                    } else if let isNextScenePoint = tileDefinition.userData?["isNextScenePoint"] as? Bool {
                        if isNextScenePoint {
                            nextSceneCoordinate = tileCoordinate
                        }
                    }
                }
            }
        }
    }
    
    func setUpWallsAndFloors(map: SKTileMapNode) {
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
                    
                    // Check if tile is solid
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
    
    func goToNextScene() {
        if player.spriteNode.position == nextSceneCoordinate {
            if let scene = GKScene(fileNamed: "GameScene") {
                if let sceneNode = scene.rootNode as! GameScene? {
                    sceneNode.scaleMode = .aspectFit
                    sceneNode.player = self.player
                    
                    
                    if let view = self.view {
                        let transition = SKTransition.fade(withDuration: 1.0)
                        view.presentScene(sceneNode, transition: transition)
                    }
                }
            }
        }
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123:
            player.move(direction: .left, wallCoordinates: wallCoordinates, floorCoordinates: floorCoordinates, completion: goToNextScene)
            
        case 124:
            player.move(direction: .right, wallCoordinates: wallCoordinates, floorCoordinates: floorCoordinates, completion: goToNextScene)
            
        case 126:
            player.move(direction: .up, wallCoordinates: wallCoordinates, floorCoordinates: floorCoordinates, completion: goToNextScene)
            
        case 125:
            player.move(direction: .down, wallCoordinates: wallCoordinates, floorCoordinates: floorCoordinates, completion: goToNextScene)
            
        case 36:
            player.inputSpell = ""
            labelPlayerSpell.text = player.inputSpell
            
        default:
            player.inputSpell.append(event.characters!)
            labelPlayerSpell.text = player.inputSpell
            break
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        sceneCamera.position = player.spriteNode.position
        labelPlayerHealth.text = "\(player.currentHealth)"
    }
}

