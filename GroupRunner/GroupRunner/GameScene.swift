//
//  GameScene.swift
//  GroupRunner
//
//  Created by Jonathan  Fotland on 6/21/17.
//  Copyright © 2017 Jonathan Fotland. All rights reserved.
//

import SpriteKit
import GameplayKit

enum gameState {
    case active,
    dead
}

let startingSpeed: CGFloat = 200

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var hero: SKSpriteNode!
    var obstacleSource: SKSpriteNode!
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    var scrollSpeed: CGFloat = startingSpeed
    var scrollLayer: SKNode!
    var obstacleLayer: SKNode!
    var touchingGround: Bool = true
    var spawnTimer: CFTimeInterval = 0
    var state: gameState = .active
    var score = 0
    var scoreLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        hero = self.childNode(withName: "hero") as! SKSpriteNode
        obstacleSource = childNode(withName: "tallObstacle") as! SKSpriteNode
        
        scrollLayer = childNode(withName: "scrollLayer")
        obstacleLayer = childNode(withName: "obstacleLayer")
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        
        //view.showsPhysics = true
    
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        /* Get references to bodies involved in collision */
        let physicsBodyA = contact.bodyA
        let physicsBodyB = contact.bodyB
        
        /* Get references to the physics body parent nodes */
        //let nodeA = contactA.node!
        //let nodeB = contactB.node!
        
        /* Did our hero hit the ground? */
        if physicsBodyA.categoryBitMask == 2 || physicsBodyB.categoryBitMask == 2 {
            
            //Yay! We hit the ground and can jump
            touchingGround = true
            
        }
        // Did our hero hit the obstacles?
        if physicsBodyA.categoryBitMask == 4 || physicsBodyB.categoryBitMask == 4 {
            
            //We hit an obstacle! That's bad.
            hero.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 0.50))
            
            state = .dead
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if state == .dead {
            return
        }
        
        if (touchingGround) {
            /* Apply vertical impulse */
            hero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100))
            touchingGround = false
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        scrollWorld()
        updateObstacles()
        
        spawnTimer += fixedDelta
        
        scrollSpeed = startingSpeed + CGFloat(score) * 0.01
        
        if state == .active {
            score += 1
            scoreLabel.text = String(score)
        }
    }
    
    func updateObstacles() {
        /* Update Obstacles */
        
        obstacleLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through obstacle layer nodes */
        for obstacle in obstacleLayer.children as! [SKSpriteNode] {
            
            /* Get obstacle node position, convert node position to scene space */
            let obstaclePosition = obstacleLayer.convert(obstacle.position, to: self)
            
            /* Check if obstacle has left the scene */
            if obstaclePosition.x <= 0 {
                
                /* Remove obstacle node from obstacle layer */
                obstacle.removeFromParent()
            }
            
        }
        
        /* Time to add a new obstacle? */
        if spawnTimer >= 4 {
            
            /* Create a new obstacle by copying the source obstacle */
            let newObstacle = obstacleSource.copy() as! SKNode
            obstacleLayer.addChild(newObstacle)
            
            /* Generate new obstacle position, start just outside screen and with a random y value */
            let randomScale = CGFloat.random(min: 0.3, max: 1.3)
            let spawnPosition = CGPoint(x: 600, y: obstacleSource.position.y)
            
            /* Convert new node position back to obstacle layer space */
            newObstacle.yScale = randomScale
            newObstacle.position = self.convert(spawnPosition, to: obstacleLayer)
            
            // Reset spawn timer
            spawnTimer = 0
        }
        
    }
    
    func scrollWorld() {
        /* Scroll World */
        scrollLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through scroll layer nodes */
        for ground in scrollLayer.children as! [SKSpriteNode] {
            
            /* Get ground node position, convert node position to scene space */
            let groundPosition = scrollLayer.convert(ground.position, to: self)
            
            /* Check if ground sprite has left the scene */
            if groundPosition.x <= -ground.size.width / 2 {
                
                /* Reposition ground sprite to the second starting position */
                let newPosition = CGPoint(x: (self.size.width / 2) + ground.size.width, y: groundPosition.y)
                
                /* Convert new node position back to scroll layer space */
                ground.position = self.convert(newPosition, to: scrollLayer)
            }
        }
    }
}
