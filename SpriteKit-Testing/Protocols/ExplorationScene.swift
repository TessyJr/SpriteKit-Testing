import SpriteKit

protocol ExplorationSceneProtocol {
    var sceneCamera: SKCameraNode { get set }
    
    var floorCoordinates: [CGPoint] { get set }
    
    var wallCoordinates: [CGPoint] { get set }
    
    var enemyCoordinates: [CGPoint] { get set }
    var defeatedEnemyCoordinates: [CGPoint] { get set }
    
    var player: Player { get set }
    var labelPlayerSpell: SKLabelNode { get set }
    var labelPlayerHealth: SKLabelNode { get set }
    
    var spawnCoordinate: CGPoint { get set }
//    var nextSceneCoordinate: CGPoint { get set }
    var lastPlayerCoordinates: CGPoint? { get set }
}
