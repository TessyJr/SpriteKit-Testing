import SpriteKit

class Enemy {
    var spriteNode: SKSpriteNode = SKSpriteNode()
    
    var currentHealth: Int = 500
    var maxHealth: Int = 500
    
    var attackInterval: CGFloat = 3.0
    
    // Random Tile Attack
    private func attack1Action(scene: BattleScene, player: Player) -> SKAction {
        var preDamageFloorNodes = [SKSpriteNode]()
        var attackCoordinates = [CGPoint]()
        
        // Step 1: Get attack coordinates
        let getAttackCoordinatesAction = SKAction.run {
            scene.floorCoordinates.forEach { coordinate in
                let randomInt = Int.random(in: 1...2)
                
                if randomInt == 1 {
                    attackCoordinates.append(coordinate)
                }
            }
        }
        
        // Step 2: Pre-attack logic
        let preAttackAction = SKAction.run {
            for coordinate in attackCoordinates {
                let trapdoorTexture = SKTexture(imageNamed: "trapdoor")
                let trapdoorNode = SKSpriteNode(texture: trapdoorTexture)
                trapdoorNode.position = coordinate
                trapdoorNode.size = CGSize(width: 16, height: 16)
                trapdoorNode.alpha = 0.2
                
                scene.addChild(trapdoorNode)
                preDamageFloorNodes.append(trapdoorNode)
            }
        }
        
        // Step 3: Wait for 2 seconds
        let waitAction1 = SKAction.wait(forDuration: 2.0)
        
        // Step 4: Remove pre-attack nodes
        let removePreAttackAction = SKAction.run {
            for preDamageFloorNode in preDamageFloorNodes {
                preDamageFloorNode.removeFromParent()
            }
            preDamageFloorNodes.removeAll()
        }
        
        // Step 5: Attack logic
        let attackAction = SKAction.run {
            for coordinate in attackCoordinates {
                let trapdoorTexture = SKTexture(imageNamed: "trapdoor")
                let trapdoorNode = SKSpriteNode(texture: trapdoorTexture)
                trapdoorNode.position = coordinate
                trapdoorNode.size = CGSize(width: 16, height: 16)
                
                scene.addChild(trapdoorNode)
                
                scene.damageFloorCoordinates.append(coordinate)
                scene.damageFloorNodes.append(trapdoorNode)
            }
        }
        
        // Step 6: Check if player takes damage
        let checkIfPlayerTakesDamageAction = SKAction.run {
            player.checkIfStandingOnDamageTile(damageFloorCoordinates: scene.damageFloorCoordinates)
        }
        
        // Step 7: Wait for 1 second
        let waitAction2 = SKAction.wait(forDuration: 1.0)
        
        // Step 8: Remove attack nodes
        let removeAttackAction = SKAction.run {
            for trapdoorNode in scene.damageFloorNodes {
                trapdoorNode.removeFromParent()
            }
            
            attackCoordinates.removeAll()
            scene.damageFloorCoordinates.removeAll()
            scene.damageFloorNodes.removeAll()
        }
        
        // Combine actions into a sequence
        let sequence = SKAction.sequence([getAttackCoordinatesAction, preAttackAction, waitAction1, removePreAttackAction, attackAction, checkIfPlayerTakesDamageAction, waitAction2, removeAttackAction])
        
        return sequence
    }
    
    func startAttacking(scene: BattleScene, player: Player) {
        let waitAction = SKAction.wait(forDuration: attackInterval)
        
        // Randomly choose the first attack
        var chosenAttackAction = SKAction()
            let randomAttack = Int.random(in: 1...1)
        switch randomAttack {
        case 1:
            chosenAttackAction = self.attack1Action(scene: scene, player: player)
        default:
            return
        }
        
        let attackSequence = SKAction.sequence([waitAction, chosenAttackAction])
        
        // Repeat the combined sequence forever
        let attackSequenceAction = SKAction.repeatForever(attackSequence)
        
        // Run the repeating sequence action
        scene.run(attackSequenceAction)
    }
}

