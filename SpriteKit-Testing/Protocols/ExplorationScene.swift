import Foundation
import SpriteKit

protocol ExplorationSceneProtocol {
    var sceneCamera: SKCameraNode { get set }
    
    var floorCoordinates: [CGPoint] { get set }
    
    var wallCoordinates: [CGPoint] { get set }
    
    var enemyCoordinates: [CGPoint] { get set }
    var defeatedEnemyCoordinates: [CGPoint] { get set }
    
    var player: Player { get set }
    var labelSpell: SKLabelNode { get set }
    var labelHealth: SKLabelNode { get set }
    
    var lastPlayerCoordinates: CGPoint? { get set }
}
