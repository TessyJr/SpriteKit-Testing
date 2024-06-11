import SpriteKit

protocol BattleSceneProtocol {
    var sceneCamera: SKCameraNode { get set }
    
    var floorCoordinates: [CGPoint] { get set }
    
    var wallCoordinates: [CGPoint] { get set }
    
    var preDamageFloorNodes: [SKSpriteNode] { get set }
    var damageFloorCoordinates: [CGPoint] { get set }
    var damageFloorNodes: [SKSpriteNode] { get set }
    
    var player: Player { get set }
    var labelPlayerSpell: SKLabelNode { get set }
    var labelPlayerHealth: SKLabelNode { get set }
    
    var enemy: Enemy { get set }
    var labelEnemyHealth: SKLabelNode { get set }
    
    var spawnCoordinate: CGPoint { get set }
    
    var previousScene: SKScene & ExplorationSceneProtocol { get set }
}
