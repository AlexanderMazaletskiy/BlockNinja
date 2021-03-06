//
//  Ninja.swift
//  BlockNinjaV2
//
//  Created by Jake on 11/4/14.
//  Copyright (c) 2014 Jake. All rights reserved.
//

import Foundation
import SpriteKit

//Colliders
let groundCategory: UInt32 = 1 << 0
let ninjaCategory: UInt32 = 1 << 1
let weaponCategory: UInt32 = 1 << 2 //Ninja's weapons
let enemy1Category: UInt32 = 1 << 3
let enemy2Category: UInt32 = 1 << 4
let enemy3Category: UInt32 = 1 << 5
let enemy4Category: UInt32 = 1 << 6
let enemyWeaponCategory: UInt32 = 1 << 7 //Enemy weapons
let endOfScreenCategory: UInt32 = 1 << 8 //End of screen

let groundTexture = SKSpriteNode(imageNamed: "Ground")

class Hero {
    var isDead = false
    var health: Int
    var inventory: Int
    var ninja = SKSpriteNode(imageNamed: "idle")
    var onGround = false
    init(health: Int, inventory: Int) {
        self.health = health
        self.inventory = inventory
    }
    
    //Add physics and position to hero
    func createHero(frameWidth: CGFloat) -> SKSpriteNode {
        
        ninja.position = CGPoint(x: frameWidth / 6, y: ninja.size.height * 2.5)
        let adjustedNinjaSize = CGSize(width: ninja.size.width * 0.6, height: ninja.size.height * 0.6)
        ninja.physicsBody = SKPhysicsBody(rectangleOfSize: adjustedNinjaSize)
        ninja.physicsBody?.dynamic = true
        ninja.setScale(0.6)
        ninja.physicsBody?.restitution = 0.0
        ninja.physicsBody?.allowsRotation = false
        ninja.physicsBody?.categoryBitMask = ninjaCategory
        ninja.physicsBody?.contactTestBitMask = groundCategory | enemy1Category | enemy2Category | enemy3Category | enemy4Category
        ninja.physicsBody?.collisionBitMask = groundCategory
        return ninja
    }

    func playWalkAnimation() {
    
        let walk1 = SKTexture(imageNamed: "walk1")
        let walk2 = SKTexture(imageNamed: "walk2")
        let walk3 = SKTexture(imageNamed: "walk3")
        let walk4 = SKTexture(imageNamed: "walk4")
    
        let walkAnim = SKAction.animateWithTextures([walk1, walk2, walk3, walk4, walk3, walk2], timePerFrame: 0.1)
        let walk = SKAction.repeatActionForever(walkAnim)
        ninja.runAction(walk)
    
    }
    
    func playJumpAnimation() {
        
        let jump1 = SKTexture(imageNamed: "jump")
        let jumpAnim = SKAction.animateWithTextures([jump1], timePerFrame: 0.1)
        let jump = SKAction.repeatActionForever(jumpAnim)
        
        ninja.runAction(jump)
    }
    
    func jump() {
        ninja.physicsBody?.applyImpulse(CGVectorMake(0, 100))
        playJumpAnimation()
        onGround = false
    }
    
    func playThrowAnimation() {
        let throw = SKTexture(imageNamed: "throw")
        let playThrow = SKAction.animateWithTextures([throw], timePerFrame: 0.1)
        ninja.runAction(playThrow)
    }
    
    func playDeadAnimation() {
        isDead = true
        ninja.physicsBody?.collisionBitMask = groundCategory
        let dead = SKTexture(imageNamed: "dead")
        let deadAnim = SKAction.repeatActionForever(SKAction.animateWithTextures([dead], timePerFrame: 20.0))
        ninja.runAction(deadAnim)
        ninja.physicsBody?.applyImpulse(CGVectorMake(0, 90))
    }

}

class Enemy {
    var enemyMoveAndRemove: SKAction!
    var isDead = false
    var dying = false
    var isSpawning = false
    var willJump = false
    var canJump = false
    var health: Int
    var jumper = false
    var fakeHealth: Int
    var ninja = SKSpriteNode(imageNamed: "enemyIdle")
    var onGround = false
    init(health: Int) {
        self.health = health
        self.fakeHealth = health
    }
    
    func createEnemy(frameWidth: CGFloat)-> SKSpriteNode{
        dying = false
        if (canJump == true && willJump == false) {
            var check = arc4random_uniform(2)
            if (check < 1) {
                self.jumper = true
            } else {
                self.jumper = false
            }
        } else if (willJump == true) {
            self.jumper = true
        }
        //Random stats
        var speed = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * 0.01
        var size = CGFloat(Float(arc4random()) / Float(UINT32_MAX))

        //if size or speed are too low or fast
        if size < 0.4 || size > 0.7 {
            size = 0.55
        }
        if speed < 0.0035 || self.jumper == true {
            speed = 0.0047
            if (size < 0.42) {
                size = 0.46
            }
        }
        
        ninja.position = CGPoint(x: frameWidth + ninja.size.width, y: groundTexture.size.height)
        let adjustedNinjaSize = CGSize(width: ninja.size.width * (size / 1.5), height: ninja.size.height * size)
        ninja.physicsBody = SKPhysicsBody(rectangleOfSize: adjustedNinjaSize)
        ninja.physicsBody?.dynamic = true
        ninja.setScale(size)
        ninja.physicsBody?.restitution = 0.0
        ninja.physicsBody?.allowsRotation = false
        let enemyDistanceToMove = CGFloat(frameWidth * ninja.size.width)
        let enemyMovement = SKAction.moveByX(-enemyDistanceToMove, y: 0.0, duration: NSTimeInterval(speed * enemyDistanceToMove))
        let delaytime = NSTimeInterval(arc4random_uniform(4))
        enemyMoveAndRemove = SKAction.sequence([SKAction.waitForDuration(delaytime), enemyMovement, SKAction.runBlock({self.playDeadAnimation(frameWidth)})])
        
        ninja.physicsBody?.contactTestBitMask = ninjaCategory | groundCategory
        ninja.physicsBody?.collisionBitMask = groundCategory

        playWalkAnimation()
        ninja.runAction(enemyMoveAndRemove, withKey: "enemyMoveAndRemove")
        
        return ninja
    }
    
    func playWalkAnimation() {
        
        let walk1 = SKTexture(imageNamed: "enemyWalk1")
        let walk2 = SKTexture(imageNamed: "enemyWalk2")
        let walk3 = SKTexture(imageNamed: "enemyWalk3")
        let walk4 = SKTexture(imageNamed: "enemyWalk4")
        
        let walkAnim = SKAction.animateWithTextures([walk1, walk2, walk3, walk4, walk3, walk2], timePerFrame: 0.1)
        let walk = SKAction.repeatActionForever(walkAnim)
        ninja.runAction(walk)
        
    }
    
    func playJumpAnimation() {
        
        let jump1 = SKTexture(imageNamed: "enemyJump")
        let jumpAnim = SKAction.animateWithTextures([jump1], timePerFrame: 0.1)
        let jump = SKAction.repeatActionForever(jumpAnim)
        
        ninja.runAction(jump)
    }
    
    func jump() {
        ninja.physicsBody?.applyImpulse(CGVectorMake(0, 15))
        playJumpAnimation()
        onGround = false
    }
    
    func playThrowAnimation() {
        let throw = SKTexture(imageNamed: "enemyThrow")
        let playThrow = SKAction.animateWithTextures([throw], timePerFrame: 0.1)
        ninja.runAction(playThrow)
    }
    
    func playDeadAnimation(frameWidth: CGFloat) {
        ninja.physicsBody?.collisionBitMask = groundCategory
        let dead = SKTexture(imageNamed: "enemyDead")
        let deadAnim = SKAction.animateWithTextures([dead], timePerFrame: 0.4)
        ninja.runAction(deadAnim)
        let enemyDistanceToMove = CGFloat(frameWidth * ninja.size.width)
        let enemyMovement = SKAction.moveByX(-enemyDistanceToMove, y: 0.0, duration: NSTimeInterval(0.006 * enemyDistanceToMove))
        let died = SKAction.sequence([SKAction.waitForDuration(0.2), SKAction.runBlock({
                self.isDead = true
            })])
        ninja.runAction(died)
    }
}

class ThrowingStar {
    var isThrown = false
    var shuriken = SKSpriteNode(imageNamed: "shuriken")
    
    func createThrowingStar() {
        self.shuriken.setScale(0.8)
        var shurikenSize = CGSize(width: shuriken.size.width * 0.3, height: shuriken.size.height * 0.3)
        self.shuriken.physicsBody = SKPhysicsBody(rectangleOfSize: shurikenSize)
        self.shuriken.physicsBody?.dynamic = true
        self.shuriken.physicsBody?.affectedByGravity = false
        self.shuriken.physicsBody?.collisionBitMask = 0
        self.shuriken.physicsBody?.contactTestBitMask = enemy1Category | enemy2Category | enemy3Category | enemy4Category | endOfScreenCategory
    }

    func throwStar(positionx: CGFloat, positiony: CGFloat) {
        self.shuriken.position = CGPointMake(positionx / 1.5, positiony)
        self.shuriken.runAction(SKAction.rotateByAngle(-150, duration: 5))
        self.shuriken.physicsBody?.velocity = CGVectorMake(19, 0)
        self.shuriken.physicsBody?.applyImpulse(CGVectorMake(19, 0))
        self.isThrown = true
    }
    
}

