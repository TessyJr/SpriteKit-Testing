import SpriteKit
import GameplayKit

class GameScene: SKScene, ExplorationSceneProtocol {    
    var sceneCamera: SKCameraNode = SKCameraNode()
    
    var floorCoordinates: [CGPoint] = [CGPoint]()
    
    var wallCoordinates: [CGPoint] = [CGPoint]()
    
    var enemyCount: Int = 0
    var enemyCoordinates: [CGPoint] = [CGPoint]()
    var defeatedEnemyCoordinates: [CGPoint] = [CGPoint]()
    
    var npc: NPC?
    var npcCoordinate: CGPoint = CGPoint()
    
    var isSpellBookOpen: Bool = false
    var spellBookNode: SKSpriteNode = SKSpriteNode()
    
    var player: Player = Player()
    var labelPlayerSpell: SKLabelNode = SKLabelNode()
    var labelPlayerHealth: SKLabelNode = SKLabelNode()
    
    var spawnCoordinate: CGPoint = CGPoint()
    var nextSceneCoordinate: CGPoint = CGPoint()
    var lastPlayerCoordinates: CGPoint?
    
    override func didMove(to view: SKView) {
        sceneCamera = childNode(withName: "sceneCamera") as! SKCameraNode
        
        spellBookNode = SKSpriteNode(imageNamed: "spellBook")
        spellBookNode.zPosition = 20
        
        for node in self.children {
            if let someTileMap = node as? SKTileMapNode {
                if someTileMap.name == "background" {
                    setUpWallsAndFloors(map: someTileMap)
                } else if someTileMap.name == "enemy" {
                    setUpEnemies(map: someTileMap)
                } else if someTileMap.name == "point" {
                    setUpPoint(map: someTileMap)
                }
            }
        }
        
        setUpPlayer()
    }
    
    func setUpPlayer() {
        player.spriteNode = childNode(withName: "player") as! SKSpriteNode
        player.animateSprite()
        
        if lastPlayerCoordinates == nil {
            player.spriteNode.position = spawnCoordinate
        } else {
            player.spriteNode.position = lastPlayerCoordinates!
        }
        
        labelPlayerSpell = player.spriteNode.childNode(withName: "labelPlayerSpell") as! SKLabelNode
        labelPlayerHealth = player.spriteNode.childNode(withName: "labelPlayerHealth") as! SKLabelNode
        labelPlayerHealth.text = "\(player.currentHealth)"
    }
    
    func setUpPoint(map: SKTileMapNode) {
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
                    sceneNode.previousScene = self
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
            player.move(direction: .left, wallCoordinates: wallCoordinates, floorCoordinates: floorCoordinates, npcCoordinate: npcCoordinate, completion: goToBattleScene)
            
        case 124:
            player.move(direction: .right, wallCoordinates: wallCoordinates, floorCoordinates: floorCoordinates, npcCoordinate: npcCoordinate,completion: goToBattleScene)
            
        case 126:
            player.move(direction: .up, wallCoordinates: wallCoordinates, floorCoordinates: floorCoordinates, npcCoordinate: npcCoordinate,completion: goToBattleScene)
            
        case 125:
            player.move(direction: .down, wallCoordinates: wallCoordinates, floorCoordinates: floorCoordinates, npcCoordinate: npcCoordinate,completion: goToBattleScene)
            
        case 36:
            player.inputSpell = ""
            labelPlayerSpell.text = player.inputSpell
            
//        case 48:
//            if isSpellBookOpen {
//                isSpellBookOpen = false
//                spellBookNode.removeFromParent()
//            } else {
//                isSpellBookOpen = true
//                sceneCamera.addChild(spellBookNode)
//            }
            
        case 49:
            if player.inputSpell == "" {
                player.interact(scene: self)
            } else {
                player.inputSpell.append(event.characters!)
                labelPlayerSpell.text = player.inputSpell
            }
            
        default:
//            player.inputSpell.append(event.characters!)
//            labelPlayerSpell.text = player.inputSpell
            break
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        sceneCamera.position = player.spriteNode.position
        labelPlayerHealth.text = "\(player.currentHealth)"
    }
}
