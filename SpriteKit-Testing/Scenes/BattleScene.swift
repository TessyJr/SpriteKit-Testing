import SpriteKit
import GameplayKit

class BattleScene: SKScene, BattleSceneProtocol {
    var sceneCamera: SKCameraNode = SKCameraNode()
    
    var floorCoordinates: [CGPoint] = [CGPoint]()
    
    var wallCoordinates: [CGPoint] = [CGPoint]()
    
    var preDamageFloorNodes = [SKSpriteNode]()
    var damageFloorCoordinates = [CGPoint]()
    var damageFloorNodes = [SKSpriteNode]()
    
    var player: Player = Player()
    var labelPlayerSpell: SKLabelNode = SKLabelNode()
    var labelPlayerHealth: SKLabelNode = SKLabelNode()
    
    var enemy: Enemy = Enemy()
    var labelEnemyHealth: SKLabelNode = SKLabelNode()
    
    var spawnCoordinate: CGPoint = CGPoint()
    
    var previousScene: SKScene & ExplorationSceneProtocol = GameScene()
    
    override func didMove(to view: SKView) {
        sceneCamera = childNode(withName: "sceneCamera") as! SKCameraNode
        
        for node in self.children {
            if let someTileMap = node as? SKTileMapNode {
                if someTileMap.name == "background" {
                    setUpWallsAndFloors(map: someTileMap)
                } else if someTileMap.name == "enemyFloor" {
                    setUpEnemyFloor(map: someTileMap)
                } else if someTileMap.name == "point" {
                    setUpPoint(map: someTileMap)
                }
            }
        }
        
        setUpPlayer()
        setUpEnemy()
        
        enemy.animateSprite()
        enemy.startAttacking(scene: self, player: self.player)
    }
    
    func setUpPlayer() {
        player.spriteNode = childNode(withName: "player") as! SKSpriteNode
        player.spriteNode.position = spawnCoordinate
        
        labelPlayerSpell = player.spriteNode.childNode(withName: "labelPlayerSpell") as! SKLabelNode
        player.inputSpell = ""
        labelPlayerSpell.text = player.inputSpell
        
        labelPlayerHealth = player.spriteNode.childNode(withName: "labelPlayerHealth") as! SKLabelNode
        labelPlayerHealth.text = "\(player.currentHealth)"
    }
    
    func setUpEnemy() {
        enemy.spriteNode = childNode(withName: "enemy") as! SKSpriteNode
        labelEnemyHealth = enemy.spriteNode.childNode(withName: "labelEnemyHealth") as! SKLabelNode
        labelEnemyHealth.text = "\(enemy.currentHealth)"
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
    
    func setUpEnemyFloor(map: SKTileMapNode) {
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
                    
                    if let isEnemyFloor = tileDefinition.userData?["isEnemyFloor"] as? Bool {
                        if isEnemyFloor {
                            floorCoordinates.removeAll(where: {$0 == tileCoordinate})
                        }
                    }
                }
            }
        }
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
    
    override func keyDown(with event: NSEvent) {
        
        if player.isStunned {
            return
        }
        
        switch event.keyCode {
        case 123:
            player.move(direction: .left, wallCoordinates: wallCoordinates, floorCoordinates: floorCoordinates, damageFloorCoordinates: damageFloorCoordinates, completion: {})
            
        case 124:
            player.move(direction: .right, wallCoordinates: wallCoordinates, floorCoordinates: floorCoordinates, damageFloorCoordinates: damageFloorCoordinates, completion: {})
            
        case 126:
            player.move(direction: .up, wallCoordinates: wallCoordinates, floorCoordinates: floorCoordinates, damageFloorCoordinates: damageFloorCoordinates, completion: {})
            
        case 125:
            player.move(direction: .down, wallCoordinates: wallCoordinates, floorCoordinates: floorCoordinates, damageFloorCoordinates: damageFloorCoordinates, completion: {})
            
        case 36:
            player.castSpell(scene: self, spell: player.inputSpell, enemy: enemy)
            player.inputSpell = ""
            labelPlayerSpell.text = player.inputSpell
            
            if enemy.currentHealth <= 0 {
                self.removeAllActions()
                damageFloorNodes.forEach { damageFloorNode in
                    damageFloorNode.removeFromParent()
                }
                preDamageFloorNodes.forEach { preDamageFloorNode in
                    preDamageFloorNode.removeFromParent()
                }
                damageFloorCoordinates.removeAll()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.previousScene.defeatedEnemyCoordinates.append(self.previousScene.lastPlayerCoordinates!)
                    
                    if let view = self.view {
                        let transition = SKTransition.fade(withDuration: 1.0)
                        view.presentScene(self.previousScene, transition: transition)
                    }
                }
            }
            
        default:
            // if space bar
            if event.keyCode == 49 {
                if player.inputSpell == "" {
                    player.castSpell(scene: self, spell: "rock", enemy: enemy)
                    break
                }
            }
            
            player.inputSpell.append(event.characters!)
            labelPlayerSpell.text = player.inputSpell
            break
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        sceneCamera.position = player.spriteNode.position
        labelPlayerHealth.text = "\(player.currentHealth)"
        labelEnemyHealth.text = "\(enemy.currentHealth)"
        
        if player.currentHealth <= 0 {
            self.removeAllActions()
            damageFloorNodes.forEach { damageFloorNode in
                damageFloorNode.removeFromParent()
            }
            preDamageFloorNodes.forEach { preDamageFloorNode in
                preDamageFloorNode.removeFromParent()
            }
            damageFloorCoordinates.removeAll()
            
            if let scene = GKScene(fileNamed: "StartScene") {
                // Get the SKScene from the loaded GKScene
                if let sceneNode = scene.rootNode as! StartScene? {
                    sceneNode.scaleMode = .aspectFit
                    
                    if let view = self.view {
                        let transition = SKTransition.fade(withDuration: 1.0)
                        view.presentScene(sceneNode, transition: transition)
                    }
                }
            }
        }
    }
}
