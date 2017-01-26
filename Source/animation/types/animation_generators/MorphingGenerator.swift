//
//  MorphingGenerator.swift
//  Pods
//
//  Created by Victor Sukochev on 24/01/2017.
//
//

func addMorphingAnimation(_ animation: BasicAnimation, sceneLayer: CALayer, animationCache: AnimationCache, completion: @escaping (() -> ())) {
    guard let morphingAnimation = animation as? MorphingAnimation else {
        return
    }
    
    guard let shape = animation.node as? Shape else {
        return
    }
    
    
    let fromLocus = morphingAnimation.getVFunc()(0.0)
    let toLocus = morphingAnimation.getVFunc()(1.0)
    
    // Creating proper animation
    let generatedAnim = pathAnimation(from:fromLocus, to:toLocus, duration: animation.getDuration())
    
    generatedAnim.repeatCount = Float(animation.repeatCount)
    generatedAnim.timingFunction = caTimingFunction(animation.easing)
    
    generatedAnim.completion = { finished in
        
        if !animation.manualStop {
            animation.progress = 1.0
            shape.form = morphingAnimation.getVFunc()(1.0)
        } else {
            shape.form = morphingAnimation.getVFunc()(animation.progress)
        }
        
        animationCache.freeLayer(shape)
        animation.completion?()
        
        if !finished {
            animationRestorer.addRestoreClosure(completion)
            return
        }
        
        completion()
    }
    
    generatedAnim.progress = { progress in
        
        let t = Double(progress)
        shape.form = morphingAnimation.getVFunc()(t)
        
        animation.progress = t
        animation.onProgressUpdate?(t)
    }
    
    let layer = animationCache.layerForNode(shape, animation: animation, shouldRenderContent: false)
    layer.path = RenderUtils.toCGPath(fromLocus)
    layer.strokeColor = UIColor.black.cgColor
    layer.lineWidth = 2.0
    layer.fillColor = UIColor.clear.cgColor
    
    layer.add(generatedAnim, forKey: animation.ID)
    animation.removeFunc = {
        layer.removeAnimation(forKey: animation.ID)
    }
}

fileprivate func pathAnimation(from:Locus, to: Locus, duration: Double) -> CAAnimation {
    
    let fromPath = RenderUtils.toCGPath(from)
    let toPath = RenderUtils.toCGPath(to)
    
    let animation = CABasicAnimation(keyPath: "path")
    animation.fromValue = fromPath
    animation.toValue = toPath
    animation.duration = duration
    
    return animation
}