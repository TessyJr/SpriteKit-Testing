import SpriteKit

class Player {
    var spriteNode: SKSpriteNode = SKSpriteNode()
    
    var status: Status = .idle
    var direction: Direction = .down
    
    var isInvincible: Bool = false
    
    let moveAmount: CGFloat = 16.0
    var moveSpeed: CGFloat = 0.2
    
    var currentHealth: Int = 50
    var maxHealth: Int = 50
    
    var inputSpell: String = ""
    
    var isRockSpellOnCooldown: Bool = false
    
    var isStunned = false
    
    func summonFireball(scene: BattleScene, enemy: Enemy) {
        let fireball = SKSpriteNode(texture: SKTexture(imageNamed: "fireball"))
        fireball.position = scene.player.spriteNode.position // Assuming there's a player property with spriteNode
        
        // Set up fireball animation textures
        var textures: [SKTexture] = []
        for i in 1...4 {
            let textureName = "fireball-\(i)"
            let texture = SKTexture(imageNamed: textureName)
            textures.append(texture)
        }
        
        let moveAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
        let repeatAnimation = SKAction.repeatForever(moveAnimation)
        fireball.run(repeatAnimation)
        
        // Add the fireball to the scene
        scene.addChild(fireball)
        
        // Calculate the angle to rotate the fireball
        let dx = enemy.spriteNode.position.x - fireball.position.x
        let dy = enemy.spriteNode.position.y - fireball.position.y
        let angle = atan2(dy, dx)
        fireball.zRotation = angle

        // Move the fireball towards the enemy
        let moveAction = SKAction.move(to: enemy.spriteNode.position, duration: 1.0)
        let removeAction = SKAction.removeFromParent()
        let damageAction = SKAction.run {
            enemy.getHurt(damage: 10)
        }
        
        let sequence = SKAction.sequence([moveAction, damageAction, removeAction])
        fireball.run(sequence)
    }

    
    func summonRock(scene: BattleScene, enemy: Enemy) {
        if isRockSpellOnCooldown {
            return
        }
        
        isRockSpellOnCooldown = true
        
        let rock = SKSpriteNode(texture: SKTexture(imageNamed: "rock"))
        rock.position = spriteNode.position
        rock.size = CGSize(width: 16, height: 16)
        
        scene.addChild(rock)
        
        var moveAction: SKAction
        moveAction = SKAction.move(to: enemy.spriteNode.position, duration: 0.5)
        
        rock.run(moveAction) {
            rock.removeFromParent()
            enemy.getHurt(damage: 1)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.isRockSpellOnCooldown = false
            }
        }
        
    }
    
    func castSpell(scene: BattleScene, spell: String, enemy: Enemy) {
        switch spell {
        case "rock":
            summonRock(scene: scene, enemy: enemy)
        case "fireball":
            summonFireball(scene: scene, enemy: enemy)
            
        case "ice blast":
            enemy.getHurt(damage: 15)
            
        case "avada kedavra":
            enemy.getHurt(damage: enemy.currentHealth)
            
        default:
            isStunned = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.isStunned = false
            }
        }
    }
    
    func animateSprite() {
        spriteNode.removeAllActions()
        
        var textures: [SKTexture] = []
        
        switch status {
        case .moving:
            if direction == .up || direction == .down {
                for i in 1...2 {
                    let textureName = "player-walk-\(direction)-\(i)"
                    let texture = SKTexture(imageNamed: textureName)
                    textures.append(texture)
                }
                
                let moveAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
                spriteNode.run(moveAnimation)
            } else if direction == .left || direction == .right {
                let textureName = "player-walk-\(direction)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
                
                let moveAnimation = SKAction.animate(with: textures, timePerFrame: 0.2)
                spriteNode.run(moveAnimation)
            }
        case .idle:
            let textureName = "player-\(direction)"
            let texture = SKTexture(imageNamed: textureName)
            textures.append(texture)
            
            let idleAnimation = SKAction.animate(with: textures, timePerFrame: 0.2)
            let repeatIdleAnimation = SKAction.repeatForever(idleAnimation)
            
            spriteNode.run(repeatIdleAnimation)
        default:
            break
        }
    }
    
    func getDamage() {
        if !isInvincible {
            currentHealth -= 10
            isInvincible = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isInvincible = false
            }
        }
    }
    
    func checkIfStandingOnDamageTile(damageFloorCoordinates: [CGPoint]) {
        let currentCoordinates = CGPoint(x: round(spriteNode.position.x), y: round(spriteNode.position.y))
        
        if damageFloorCoordinates.contains(currentCoordinates) {
            self.getDamage()
        }
    }
    
    func move(direction: Direction, wallCoordinates: [CGPoint], floorCoordinates: [CGPoint], damageFloorCoordinates: [CGPoint] = [], completion: @escaping () -> Void) {
        if status == .moving {
            return
        }
        
        status = .moving
        self.direction = direction
        animateSprite()
        
        let moveToCoordinate: CGPoint
        let moveAction: SKAction
        
        switch direction {
        case .left:
            moveToCoordinate = CGPoint(x: round(spriteNode.position.x - moveAmount), y: round(spriteNode.position.y))
            moveAction = SKAction.moveBy(x: -moveAmount, y: 0, duration: moveSpeed)
            
        case .right:
            moveToCoordinate = CGPoint(x: round(spriteNode.position.x + moveAmount), y: round(spriteNode.position.y))
            moveAction = SKAction.moveBy(x: moveAmount, y: 0, duration: moveSpeed)
            
        case .up:
            moveToCoordinate = CGPoint(x: round(spriteNode.position.x), y: round(spriteNode.position.y + moveAmount))
            moveAction = SKAction.moveBy(x: 0, y: moveAmount, duration: moveSpeed)
            
        case .down:
            moveToCoordinate = CGPoint(x: round(spriteNode.position.x), y: round(spriteNode.position.y - moveAmount))
            moveAction = SKAction.moveBy(x: 0, y: -moveAmount, duration: moveSpeed)
        }
        
        if wallCoordinates.contains(moveToCoordinate) || !floorCoordinates.contains(moveToCoordinate) {
            self.status = .idle
            animateSprite()
            return
        } else {
            // Define the completion action to round the position
            let roundPositionAction = SKAction.run {
                self.spriteNode.position = moveToCoordinate
                
                self.checkIfStandingOnDamageTile(damageFloorCoordinates: damageFloorCoordinates)
                
                self.status = .idle
                self.animateSprite()
                
                completion()
            }
            
            // Create a sequence of the move action followed by the round position action
            let sequence = SKAction.sequence([moveAction, roundPositionAction])
            
            // Run the sequence on the sprite node
            spriteNode.run(sequence)
        }
    }
}
