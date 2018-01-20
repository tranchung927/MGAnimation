//
//  AnimationService.swift
//  MGAnimation
//
//  Created by Chung-Sama on 2018/01/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import AVFoundation
import CoreGraphics

class AnimationService: NSObject {
    func animationLayerFromImages(images: [UIImage], texts: [String], frameSize: CGSize, startTime: Double = CACurrentMediaTime()) -> CALayer {
        let parentLayer = CALayer()
        
        let animationTime: Double = 3
        
        let fadeTime: Double = 1
        let backgroundOpacity: Float = 0.5
        
        for (index, image) in images.enumerated() {
            let bgLayer = CALayer()
            bgLayer.contents = image.cgImage
            bgLayer.frame = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
            bgLayer.contentsGravity = kCAGravityResizeAspectFill
            bgLayer.opacity = backgroundOpacity
            
            let contentLayer = CALayer()
            contentLayer.contents = image.cgImage
            contentLayer.frame = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
            contentLayer.contentsGravity = kCAGravityTop
            
            let animation = animationWithDuration(duration: animationTime, autoReverse: false, fromValue: nil, toValue: contentLayer.position.x + 150 as AnyObject, beginTime: (Double(index) * animationTime) + startTime, keyPath: "position.x", repeatCount: 0, fillMode: nil)
            
            if index > 0 {
                bgLayer.opacity = 0
                contentLayer.opacity = 0
                let fadeInAnimation = animationWithDuration(duration: fadeTime, autoReverse: false, fromValue: 0 as AnyObject, toValue: 1 as AnyObject, beginTime: (Double(index) * animationTime) + startTime - fadeTime, keyPath: "opacity", repeatCount: 0, fillMode: kCAFillModeForwards)
                
                let bgFadeInAnimation = animationWithDuration(duration: fadeTime, autoReverse: false, fromValue: 0 as AnyObject, toValue: backgroundOpacity as AnyObject, beginTime: (Double(index) * animationTime) + startTime - fadeTime, keyPath: "opacity", repeatCount: 0, fillMode: kCAFillModeForwards)
                
                bgLayer.add(bgFadeInAnimation, forKey: "bgFadeIn")
                contentLayer.add(fadeInAnimation, forKey: "fadeIn")
            }
            
            let fadeOutAnimation = animationWithDuration(duration: fadeTime, autoReverse: false, fromValue: 1 as AnyObject, toValue: 0 as AnyObject, beginTime: animationTime + (Double(index) * animationTime) + startTime - fadeTime, keyPath: "opacity", repeatCount: 0, fillMode: kCAFillModeForwards)
            
            let bgFadeOutAnimation = animationWithDuration(duration: fadeTime, autoReverse: false, fromValue: backgroundOpacity as AnyObject, toValue: 0 as AnyObject, beginTime: animationTime + (Double(index) * animationTime) + startTime - fadeTime, keyPath: "opacity", repeatCount: 0, fillMode: kCAFillModeForwards)
            
            
            contentLayer.add(fadeOutAnimation, forKey: "fadeOut")
            contentLayer.add(animation, forKey: "animate")
            
            bgLayer.add(bgFadeOutAnimation, forKey: "bgFadeOut")
            
            
            
            parentLayer.addSublayer(bgLayer)
            parentLayer.addSublayer(contentLayer)
        }
        
        return parentLayer
    }
    
    private func animationWithDuration(duration: Double, autoReverse: Bool, fromValue: AnyObject?, toValue: AnyObject?, beginTime: Double, keyPath: String, repeatCount: Float, fillMode: String?) -> CAAnimation {
        let animation = CABasicAnimation()
        animation.keyPath = keyPath
        if let fromValue = fromValue {
            animation.fromValue = fromValue
        }
        animation.toValue = toValue
        
        if let fillMode = fillMode{
            animation.fillMode = fillMode
        }
        animation.beginTime = beginTime
        animation.autoreverses = autoReverse
        animation.duration = duration
        animation.repeatCount = repeatCount
        animation.isRemovedOnCompletion = false
        
        return animation
    }
}
