import SpriteKit
import GameplayKit

class BattleScene: SKScene {
    var sceneCamera: SKCameraNode = SKCameraNode()
    
    var floorCoordinates = [CGPoint]()
    
    var wallCoordinates = [CGPoint]()
    
    var damageFloorCoordinates = [CGPoint]()
    var damageFloorNodes = [SKSpriteNode]()
    
    var player: Player = Player()
    var labelSpell: SKLabelNode = SKLabelNode()
    var labelPlayerHealth: SKLabelNode = SKLabelNode()
    
    var enemy: Enemy = Enemy()
    var labelEnemyHealth: SKLabelNode = SKLabelNode()
    
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
        labelPlayerHealth = player.spriteNode.childNode(withName: "labelPlayerHealth") as! SKLabelNode
        labelPlayerHealth.text = "\(player.currentHealth)"
        
        enemy.spriteNode = childNode(withName: "enemy") as! SKSpriteNode
        labelEnemyHealth = enemy.spriteNode.childNode(withName: "labelEnemyHealth") as! SKLabelNode
        labelEnemyHealth.text = "\(enemy.currentHealth)"
        
        enemy.startAttacking(scene: self, player: self.player)
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
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123:
            player.move(direction: .left, wallCoordinates: wallCoordinates, damageFloorCoordinates: damageFloorCoordinates, completion: {})
            
        case 124:
            player.move(direction: .right, wallCoordinates: wallCoordinates, damageFloorCoordinates: damageFloorCoordinates, completion: {})
            
        case 126:
            player.move(direction: .up, wallCoordinates: wallCoordinates, damageFloorCoordinates: damageFloorCoordinates, completion: {})
            
        case 125:
            player.move(direction: .down, wallCoordinates: wallCoordinates, damageFloorCoordinates: damageFloorCoordinates, completion: {})
            
        case 36:
            player.castSpell(spell: player.inputSpell, enemy: enemy)
            
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
        labelPlayerHealth.text = "\(player.currentHealth)"
        labelEnemyHealth.text = "\(enemy.currentHealth)"
    }
}
