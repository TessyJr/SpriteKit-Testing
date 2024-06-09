import SpriteKit
import GameplayKit

class GameScene: SKScene, ExplorationSceneProtocol {
    var sceneCamera: SKCameraNode = SKCameraNode()
    
    var floorCoordinates: [CGPoint] = [CGPoint]()
    
    var wallCoordinates: [CGPoint] = [CGPoint]()
    
    var enemyCoordinates: [CGPoint] = [CGPoint]()
    var defeatedEnemyCoordinates: [CGPoint] = [CGPoint]()
    
    var player: Player = Player()
    var labelSpell: SKLabelNode = SKLabelNode()
    var labelHealth: SKLabelNode = SKLabelNode()
    
    var lastPlayerCoordinates: CGPoint?
    
    override func didMove(to view: SKView) {
        sceneCamera = childNode(withName: "sceneCamera") as! SKCameraNode
        
        player.spriteNode = childNode(withName: "player") as! SKSpriteNode
        labelSpell = player.spriteNode.childNode(withName: "labelSpell") as! SKLabelNode
        labelHealth = player.spriteNode.childNode(withName: "labelHealth") as! SKLabelNode
        labelHealth.text = "\(player.currentHealth)"
        
        for node in self.children {
            if let someTileMap = node as? SKTileMapNode {
                if someTileMap.name == "background" {
                    setUpWallsAndFloors(map: someTileMap)
                } else if someTileMap.name == "enemy" {
                    setUpEnemies(map: someTileMap)
                } else if someTileMap.name == "spawnpoint" {
                    setUpPlayerSpawnpoint(map: someTileMap)
                }
            }
        }
    }
    
    func setUpPlayerSpawnpoint(map: SKTileMapNode) {
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
                    
                    if lastPlayerCoordinates == nil {
                        if let isSpawnpoint = tileDefinition.userData?["isSpawnpoint"] as? Bool {
                            if isSpawnpoint {
                                player.spriteNode.position = tileCoordinate
                            }
                        }
                    } else {
                        if let playerCoordinates = lastPlayerCoordinates {
                            player.spriteNode.position = playerCoordinates
                        }
                    }
                }
            }
        }
    }
    
    func setUpEnemies(map: SKTileMapNode) {
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
                    
                    if let isEnemy = tileDefinition.userData?["isEnemy"] as? Bool {
                        if isEnemy {
                            enemyCoordinates.append(tileCoordinate)
                        }
                        
                        if defeatedEnemyCoordinates.contains(tileCoordinate) {
                            enemyCoordinates.removeAll { $0 == tileCoordinate }
                            tileMap.setTileGroup(nil, forColumn: col, row: row)
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
                    
                    // Check if tile is an enemy
                    if let isEnemy = tileDefinition.userData?["isEnemy"] as? Bool {
                        if isEnemy {
                            enemyCoordinates.append(tileCoordinate)
                        }
                    }
                }
            }
        }
    }
    
    func getEnemyType() -> String {
        if let enemyTileMap = childNode(withName: "enemy") as? SKTileMapNode {
            // Find row and col in tile map node from player position
            let tileMap = enemyTileMap
            let tileSize = tileMap.tileSize
            let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * tileSize.width
            let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * tileSize.height
            
            let x = round(player.spriteNode.position.x)
            let y = round(player.spriteNode.position.y)
            
            let col = Int((x + halfWidth - (tileSize.width / 2)) / tileSize.width)
            let row = Int((y + halfHeight - (tileSize.height / 2)) / tileSize.height)
            
            if let tileDefinition = enemyTileMap.tileDefinition(atColumn: col, row: row) {
                if let enemyType = tileDefinition.userData?["enemyType"] as? String {
                    return enemyType
                }
            }
        }
        
        return ""
    }
    
    func goToBattleScene() {
        if enemyCoordinates.contains(player.spriteNode.position) {
            lastPlayerCoordinates = player.spriteNode.position
            
            let enemyType = getEnemyType()
            
            if let scene = GKScene(fileNamed: "BattleScene") {
                if let sceneNode = scene.rootNode as! BattleScene? {
                    sceneNode.scaleMode = .aspectFit
                    sceneNode.exploreScene = self
                    sceneNode.player = self.player
                    sceneNode.enemy = Enemy.create(enemyType: enemyType)!
                    
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
            player.move(direction: .left, wallCoordinates: wallCoordinates, completion: goToBattleScene)
            
        case 124:
            player.move(direction: .right, wallCoordinates: wallCoordinates, completion: goToBattleScene)
            
        case 126:
            player.move(direction: .up, wallCoordinates: wallCoordinates, completion: goToBattleScene)
            
        case 125:
            player.move(direction: .down, wallCoordinates: wallCoordinates, completion: goToBattleScene)
            
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
