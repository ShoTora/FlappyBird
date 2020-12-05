//
//  GameScene.swift
//  FlappyBird
//
//  Created by Shotaro Kawaguchi on 2020/10/05.
//  Copyright © 2020 shotaro.kawaguchi. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!
    
    // object category
    let birdCategory: UInt32 = 1 << 0  // 0...00001
    let groundCategory: UInt32 = 1 << 1   // 0...00010
    let wallCategory: UInt32 = 1 << 2   // 0...00100
    let scoreCategory: UInt32 = 1 << 3   // 0...01000
    
    // score
    var score = 0
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    let userDefaults:UserDefaults = UserDefaults.standard

    // Method when scene is showed on SKView
    override func didMove(to view: SKView) {
        
        // gravity
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        physicsWorld.contactDelegate = self

        // background color
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)

        // scrollNode
        scrollNode = SKNode()
        addChild(scrollNode)
        
        // wallNode
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        // keep generating objects
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        
        setupScoreLabel()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scrollNode.speed > 0 {
            // stop a bird
            bird.physicsBody?.velocity = CGVector.zero
            
            // move up
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        } else if bird.speed == 0 {
            restart()
        }
    }
    
    func setupGround() {
        // call Ground image
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest

        // to fill ground all time
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2

        // scroll action
        // move ground to left
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width , y: 0, duration: 5)

        // reset ground
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)

        // scroll to left -> reset -> scroll left for infinit time
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))

        // placing sprite
        for i in 0..<needNumber {
            let sprite = SKSpriteNode(texture: groundTexture)

            // sprite position
            sprite.position = CGPoint(
                x: groundTexture.size().width / 2  + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2
            )

            // sprite run
            sprite.run(repeatScrollGround)
            
            // sprite physicsBody
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
            // category
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            // stop when bird collaps
            sprite.physicsBody?.isDynamic = false

            // add sprite
            scrollNode.addChild(sprite)
        }
    }
    
    func setupCloud() {
        // call cloud
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        // calculate humber of cloud to fill
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        
        // scroll action
        // to left
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20)
        
        //reset
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 20)
        
        // scroll left -> reset -> scroll left for infinite time
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        // sprite
        for i in 0..<needCloudNumber {
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100
            
            // sprite position
            sprite.position = CGPoint(x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i), y: self.size.height - cloudTexture.size().height / 2)
            
            // sprite run
            sprite.run(repeatScrollCloud)
            
            // add sprite
            scrollNode.addChild(sprite)
        }
    }
    
    func setupWall() {
            // call wall image
            let wallTexture = SKTexture(imageNamed: "wall")
            wallTexture.filteringMode = .linear

            // calculate moving distance
            let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)

            // move wall
            let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration:4)

            // remove wall
            let removeWall = SKAction.removeFromParent()

            // action to implement moveWall and removeWall one by one
            let wallAnimation = SKAction.sequence([moveWall, removeWall])

            // birdSixe
            let birdSize = SKTexture(imageNamed: "bird_a").size()

            // slit length
            let slit_length = birdSize.height * 3

            // slit range
            let random_y_range = birdSize.height * 3

            // under wall lowest y
            let groundSize = SKTexture(imageNamed: "ground").size()
            let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
            let under_wall_lowest_y = center_y - slit_length / 2 - wallTexture.size().height / 2 - random_y_range / 2

            // generate wall
            let createWallAnimation = SKAction.run({
                // generate SKNode
                let wall = SKNode()
                wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
                wall.zPosition = -50 // 雲より手前、地面より奥

                // 0〜random_y_range
                let random_y = CGFloat.random(in: 0..<random_y_range)
                
                // y axis
                let under_wall_y = under_wall_lowest_y + random_y

                // generate under wall
                let under = SKSpriteNode(texture: wallTexture)
                under.position = CGPoint(x: 0, y: under_wall_y)
                
                // add physics
                under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
                under.physicsBody?.categoryBitMask = self.wallCategory
                
                // add physics
                under.physicsBody?.isDynamic = false

                wall.addChild(under)

                // stop when collision
                let upper = SKSpriteNode(texture: wallTexture)
                upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
                
                // set physics for sprite
                upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
                under.physicsBody?.categoryBitMask = self.wallCategory
                
                // stop when collision
                upper.physicsBody?.isDynamic = false

                wall.addChild(upper)
                
                // score up node
                let scoreNode = SKNode()
                scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y:self.frame.height / 2)
                scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
                scoreNode.physicsBody?.isDynamic = false
                scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
                scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
                
                wall.addChild(scoreNode)

                wall.run(wallAnimation)

                self.wallNode.addChild(wall)
            })

            // waitAnimation
            let waitAnimation = SKAction.wait(forDuration: 2)

            // createWallAnimation -> waitAnimation-> createWallAnimation for infinite times
            let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))

            wallNode.run(repeatForeverAnimation)
        }
        
    func setupBird() {
        // call bird
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        // show two pictures alternately
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)
        
        // create sprite
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        
        // add physics
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        
        // no rotation when collision
        bird.physicsBody?.allowsRotation = false
        
        // category
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory
        
        // run
        bird.run(flap)
        
        // add sprite
        addChild(bird)
    }
    
    // SKPhysicsContactDelegate when collision
    func didBegin(_ contact: SKPhysicsContact) {
        
        if scrollNode.speed <= 0 {
            return
        }
    
    
    if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            
            print("ScoreUp")
            score += 1
        scoreLabelNode.text = "Score:\(score)"
        
        // check if player broke bestScore
        var bestScore = userDefaults.integer(forKey: "BEST")
        if score > bestScore {
            bestScore = score
            bestScoreLabelNode.text = "Best Score:\(bestScore)"
            userDefaults.set(bestScore, forKey: "BEST")
            userDefaults.synchronize()
        }
    } else {
            // collision on wall or ground
            print("GameOver")

            // stop scrolling
            scrollNode.speed = 0

            bird.physicsBody?.collisionBitMask = groundCategory

            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration:1)
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
        }
    }
    
    func restart() {
        score = 0
        scoreLabelNode.text = "Score:\(score)"
        
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0
        
        wallNode.removeAllChildren()
        
        bird.speed = 1
        scrollNode.speed = 1
    }
    
    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100  
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
    }
}
