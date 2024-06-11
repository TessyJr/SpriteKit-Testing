import SpriteKit

class Enemy {
    var spriteNode: SKSpriteNode = SKSpriteNode()
    
    var name: String
    
    var status: Status = .idle
    var currentHealth: Int
    var maxHealth: Int
    
    var attackInterval: CGFloat
    
    init(name: String = "enemy", currentHealth: Int = 500, maxHealth: Int = 500, attackInterval: CGFloat = 3.0) {
        self.name = name
        self.currentHealth = currentHealth
        self.maxHealth = maxHealth
        self.attackInterval = attackInterval
    }
    
    // Factory method to create enemy based on type with customization
    static func create(enemyType: String) -> Enemy? {
        switch enemyType.lowercased() {
        case "devil":
            return Devil()
        default:
            return nil
        }
    }
    
    func startAttacking(scene: BattleScene, player: Player) {}
    
    func animateSprite() {
        spriteNode.removeAllActions()
        
        var textures: [SKTexture] = []
        
        switch status {
        case .idle:
            for i in 1...2 {
                let textureName = "\(name)-idle-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let idleAnimation = SKAction.animate(with: textures, timePerFrame: 0.25)
            let repeatIdleAnimation = SKAction.repeatForever(idleAnimation)
            
            spriteNode.run(repeatIdleAnimation)
        case .hurt:
            for i in 1...2 {
                let textureName = "\(name)-hurt-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let hurtAnimation = SKAction.animate(with: textures, timePerFrame: 0.25)
            
            spriteNode.run(hurtAnimation)
        case .die:
            for i in 1...4 {
                let textureName = "\(name)-die-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let dieAnimation = SKAction.animate(with: textures, timePerFrame: 0.25)
            
            spriteNode.run(dieAnimation)
        default:
            break
        }
    }
    
    func getHurt(damage: Int) {
        currentHealth -= damage
        
        if currentHealth <= 0 {
            spriteNode.removeAllActions()
            status = .die
            animateSprite()
        } else {
            status = .hurt
            animateSprite()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                self.status = .idle
                self.animateSprite()
            }
        }
    }
}

// Subclass for Goblin enemy
class Devil: Enemy {
    init() {
        super.init(name: "devil", currentHealth: 100, maxHealth: 100, attackInterval: 0)
    }
    
    // Random Tile Attack
    private func attack1Action(scene: BattleScene, player: Player) -> SKAction {
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
                scene.preDamageFloorNodes.append(trapdoorNode)
            }
        }
        
        // Step 3: Wait for 2 seconds
        let waitAction1 = SKAction.wait(forDuration: 1.0)
        
        // Step 4: Remove pre-attack nodes
        let removePreAttackAction = SKAction.run {
            for preDamageFloorNode in scene.preDamageFloorNodes {
                preDamageFloorNode.removeFromParent()
            }
            scene.preDamageFloorNodes.removeAll()
        }
        
        // Step 5: Attack logic
        let attackAction = SKAction.run {
            scene.damageFloorCoordinates = attackCoordinates
            
            for coordinate in attackCoordinates {
                let trapdoorTexture = SKTexture(imageNamed: "trapdoor")
                let trapdoorNode = SKSpriteNode(texture: trapdoorTexture)
                trapdoorNode.position = coordinate
                trapdoorNode.size = CGSize(width: 16, height: 16)
                
                scene.addChild(trapdoorNode)
                
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
    
    override func startAttacking(scene: BattleScene, player: Player) {
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
