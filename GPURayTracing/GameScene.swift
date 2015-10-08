//
//  GameScene.swift
//  GPURayTracing
//
//  Created by Gabor Nagy on 9/28/15.
//  Copyright (c) 2015 Appcylon LLC. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var canvas: SKSpriteNode?
    var xOffset: Float = 0.0
    var yOffset: Float = 0.0
    var force: Float = 0.0
    var velocity: CGPoint = CGPointMake(0.0, 0.0)

    let earthCloudMap = SKTexture(imageNamed: "earthcloudmap.jpg")
    let earthCloudAlpha = SKTexture(imageNamed: "cloudalpha.jpg")
    let earthLights = SKTexture(imageNamed: "earthlights.jpg")
    
    override func didMoveToView(view: SKView) {
        size = CGSizeMake(100, 100)
        canvas = SKSpriteNode(imageNamed: "earth.jpg")
        
        if canvas != nil {
            let canvas = self.canvas!
            canvas.position = CGPoint(x: 50, y: 50)
            canvas.zPosition = 2.0
            canvas.size = CGSizeMake(100, 100)
            canvas.shader = SKShader(fileNamed: "RayTracer.fsh")
            canvas.shader?.uniforms = [
                SKUniform(name: "xOffset", float: xOffset),
                SKUniform(name: "yOffset", float: yOffset),
                SKUniform(name: "force", float: force),
                SKUniform(name: "texture_clouds", texture: earthCloudMap),
                SKUniform(name: "texture_clouds_alpha", texture: earthCloudAlpha),
                SKUniform(name: "texture_lights", texture: earthLights),
                
            ];
            addChild(canvas)
        }
        
        let panGestureRecognizer: UIPanGestureRecognizer? = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        if panGestureRecognizer != nil {
            view.addGestureRecognizer(panGestureRecognizer!)
        }
    }
    
    func handlePanGesture(recognizer:UIPanGestureRecognizer) {
        velocity = recognizer.velocityInView(view)
    }
    
    override func update(currentTime: CFTimeInterval) {
        xOffset = xOffset - Float(velocity.x / 30000.0)
        yOffset = yOffset + Float(velocity.y / 30000.0)
        velocity.x *= 0.95
        velocity.y *= 0.95
        
        if let shader = canvas?.shader {
            shader.removeUniformNamed("xOffset")
            shader.removeUniformNamed("yOffset")
            shader.addUniform(SKUniform(name: "xOffset", float: xOffset))
            shader.addUniform(SKUniform(name: "yOffset", float: yOffset))
        }
    }
    
}
