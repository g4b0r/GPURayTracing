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
    
    override func didMoveToView(view: SKView) {
        size = CGSizeMake(100, 100)
        canvas = SKSpriteNode(imageNamed: "tile.png")
        
        if canvas != nil {
            let canvas = self.canvas!
            canvas.position = CGPoint(x: 50, y: 50)
            canvas.zPosition = 2.0
            canvas.size = CGSizeMake(100, 100)
            canvas.shader = SKShader(fileNamed: "RayTracer.fsh")
            canvas.shader?.uniforms = [
                SKUniform(name: "xOffset", float: xOffset),
                SKUniform(name: "yOffset", float: yOffset),
            ];
            addChild(canvas)
        }
        
        let panGestureRecognizer: UIPanGestureRecognizer? = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        if panGestureRecognizer != nil {
            view.addGestureRecognizer(panGestureRecognizer!)
        }
    }
        
    func handlePanGesture(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(view)
        
        let x: Float = Float(translation.x / -50.0 * (1.0 / 8.0))
        let y: Float = Float(translation.y / -50.0 * (1.0 / 8.0))
        
        canvas?.shader?.uniforms = [
            SKUniform(name: "xOffset", float: xOffset + x),
            SKUniform(name: "yOffset", float: yOffset + y),
        ];
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            xOffset = xOffset + x
            yOffset = yOffset + y
        }
    }
    
}
