import SpriteKit

class Player {
    var spriteNode: SKSpriteNode = SKSpriteNode()
    
    var isSpellBookOpen: Bool = false
    var spellBookNode: SKSpriteNode = SKSpriteNode()
    
    var status: Status = .idle
    var direction: Direction = .down
    
    var isInvincible: Bool = false
    var invincibleTimer: Timer?
    
    var isStun = false
    var stunTimer: Timer?
    
    var isInteracting: Bool = false
    
    let moveAmount: CGFloat = 16.0
    var moveSpeed: CGFloat = 0.2
    
    var currentHealth: Int = 50
    var maxHealth: Int = 50
    
    var inputSpell: String = ""
    
    var isRockSpellOnCooldown: Bool = false
    
    func summonFireball(scene: BattleScene, enemy: Enemy, completion: @escaping () -> Void) {
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
        fireball.run(sequence) {
            completion()
        }
    }
    
    func summonRock(scene: BattleScene, enemy: Enemy, completion: @escaping () -> Void) {
        if isRockSpellOnCooldown {
            completion()
            return
        }
        
        isRockSpellOnCooldown = true
        
        let rock = SKSpriteNode(texture: SKTexture(imageNamed: "rock"))
        rock.position = spriteNode.position
        rock.size = CGSize(width: 16, height: 16)
        
        scene.addChild(rock)
        
        let moveAction = SKAction.move(to: enemy.spriteNode.position, duration: 0.5)
        rock.run(moveAction) {
            rock.removeFromParent()
            enemy.getHurt(damage: 1)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.isRockSpellOnCooldown = false
            }
            completion()
        }
    }
    
    func castSpell(scene: BattleScene, spell: String, enemy: Enemy) {
        // Completion handler to run checkIfEnemyDiedAction after the spell is cast
        let completion: () -> Void = {
            if enemy.currentHealth <= 0 {
                scene.stopBattle()
            }
        }
        
        // Cast Spell Action
        switch spell {
        case "rock":
            summonRock(scene: scene, enemy: enemy, completion: completion)
        case "fireball":
            summonFireball(scene: scene, enemy: enemy, completion: completion)
        case "ice blast":
            enemy.getHurt(damage: 15)
            completion()
        case "avada kedavra":
            enemy.getHurt(damage: enemy.currentHealth)
            completion()
        default:
            if !isStun {
                isStun = true
                
                // Start the timer to toggle alpha when invincible
                stunTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    self.spriteNode.alpha = self.spriteNode.alpha == 1.0 ? 0.5 : 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.isStun = false
                    self.spriteNode.alpha = 1.0
                    // Invalidate the timer when no longer invincible
                    self.stunTimer?.invalidate()
                    self.stunTimer = nil
                }
            }
        }
    }
    
    func animateSprite() {
//        spriteNode.removeAllActions()
        
        var textures: [SKTexture] = []
        
        switch status {
        case .moving:
                for i in 1...2 {
                    let textureName = "player-move-\(direction)-\(i)"
                    let texture = SKTexture(imageNamed: textureName)
                    textures.append(texture)
                }
                
                let moveAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
                spriteNode.run(moveAnimation)
        case .idle:
            for i in 1...2 {
                let textureName = "player-idle-\(direction)-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
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
            
            // Start the timer to toggle alpha when invincible
            invincibleTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.spriteNode.alpha = self.spriteNode.alpha == 1.0 ? 0.5 : 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isInvincible = false
                self.spriteNode.alpha = 1.0
                // Invalidate the timer when no longer invincible
                self.invincibleTimer?.invalidate()
                self.invincibleTimer = nil
            }
        }
    }
    
    func checkIfStandingOnDamageTile(damageFloorCoordinates: [CGPoint]) {
        let currentCoordinates = CGPoint(x: round(spriteNode.position.x), y: round(spriteNode.position.y))
        
        if damageFloorCoordinates.contains(currentCoordinates) {
            self.getDamage()
        }
    }
    
    func interact(scene: ExplorationSceneProtocol) {
        let interactWithCoordinate: CGPoint
        
        switch self.direction {
        case .left:
            interactWithCoordinate = CGPoint(x: round(spriteNode.position.x - moveAmount), y: round(spriteNode.position.y))
            
        case .right:
            interactWithCoordinate = CGPoint(x: round(spriteNode.position.x + moveAmount), y: round(spriteNode.position.y))
            
        case .up:
            interactWithCoordinate = CGPoint(x: round(spriteNode.position.x), y: round(spriteNode.position.y + moveAmount))
            
        case .down:
            interactWithCoordinate = CGPoint(x: round(spriteNode.position.x), y: round(spriteNode.position.y - moveAmount))
        }
        
        if interactWithCoordinate == scene.npcCoordinate {
            isInteracting = true
            scene.npc!.interactWith(scene: scene)
        }
    }
    
    func move(direction: Direction, wallCoordinates: [CGPoint], floorCoordinates: [CGPoint], damageFloorCoordinates: [CGPoint] = [], npcCoordinate: CGPoint = CGPoint(), doorCoordinate: CGPoint = CGPoint(), completion: @escaping () -> Void) {
        if status == .moving || isInteracting {
            return
        }
        
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
        
        if wallCoordinates.contains(moveToCoordinate) || !floorCoordinates.contains(moveToCoordinate) || moveToCoordinate == npcCoordinate || moveToCoordinate == doorCoordinate {
            return
        } else {
            status = .moving
            self.direction = direction
            animateSprite()
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
