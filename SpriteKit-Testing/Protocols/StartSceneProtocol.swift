import Foundation
import SpriteKit

protocol StartSceneProtocol {
    var sceneCamera: SKCameraNode { get set }
    
    var floorCoordinates: [CGPoint] { get set }
    
    var wallCoordinates: [CGPoint] { get set }
    
    var player: Player { get set }
    var labelPlayerSpell: SKLabelNode { get set }
    var labelPlayerHealth: SKLabelNode { get set }
    
    var spawnCoordinate: CGPoint { get set }
    var nextSceneCoordinate: CGPoint { get set }
}
