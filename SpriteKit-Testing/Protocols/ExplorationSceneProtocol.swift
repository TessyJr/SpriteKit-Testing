import SpriteKit

protocol ExplorationSceneProtocol: SKScene {
    var sceneCamera: SKCameraNode { get set }
    
    var floorCoordinates: [CGPoint] { get set }
    
    var wallCoordinates: [CGPoint] { get set }
    
    var enemyCount: Int { get set }
    var enemyCoordinates: [CGPoint] { get set }
    var defeatedEnemyCoordinates: [CGPoint] { get set }
    
    var npc: NPC? { get set }
    var npcCoordinate: CGPoint { get set }
    
    var isSpellBookOpen: Bool { get set }
    var spellBookNode: SKSpriteNode { get set }
    
    var player: Player { get set }
    var labelPlayerSpell: SKLabelNode { get set }
    var labelPlayerHealth: SKLabelNode { get set }
    
    var spawnCoordinate: CGPoint { get set }
    var nextSceneCoordinate: CGPoint { get set }
    var lastPlayerCoordinates: CGPoint? { get set }
}
