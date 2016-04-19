import UIKit

public class AnimationProducer {
	public func addAnimation(animation: Animatable) {
		switch animation.type {
		case .Unknown:
			return
		case .AffineTransformation:
			addTransformAnimation(animation)
		}
	}

	private func addTransformAnimation(animation: Animatable) {
		guard let transformAnimation = animation as? TransformAnimation else {
			return
		}

		let cgTransformStart = transfomToCG(transformAnimation.start)
		let cgTransformFinal = transfomToCG(transformAnimation.final)

		// Small workaround
		let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
		let startRect = CGRectApplyAffineTransform(rect, cgTransformStart)
		let finalRect = CGRectApplyAffineTransform(rect, cgTransformFinal)

		let startX = startRect.origin.x
		let startY = startRect.origin.y
		let finalX = finalRect.origin.x
		let finalY = finalRect.origin.y
		let startScaleX = startRect.width
		let startScaleY = startRect.height
		let finalScaleX = finalRect.width
		let finalScaleY = finalRect.height

		// layer.setAffineTransform(cgTransformStart)

		let scaleX = CABasicAnimation(keyPath: "scale.x")
		scaleX.fromValue = startScaleX
		scaleX.toValue = finalScaleX
		scaleX.duration = animation.getDuration()

		let scaleY = CABasicAnimation(keyPath: "scale.y")
		scaleY.fromValue = startScaleY
		scaleY.toValue = finalScaleY
		scaleY.duration = animation.getDuration()

		let translationX = CABasicAnimation(keyPath: "translation.x")
		translationX.fromValue = startX
		translationX.toValue = finalX
		translationX.duration = animation.getDuration()

		let translationY = CABasicAnimation(keyPath: "translation.y")
		translationY.fromValue = startY
		translationY.toValue = finalY
		translationY.duration = animation.getDuration()

		let group = CAAnimationGroup()
		group.animations = [translationX, translationY, scaleX, scaleY]

		animation.layer?.addAnimation(group, forKey: .None)
	}
}

func transfomToCG(transform: Transform) -> CGAffineTransform {
	return CGAffineTransformMake(
		CGFloat(transform.m11),
		CGFloat(transform.m12),
		CGFloat(transform.m21),
		CGFloat(transform.m22),
		CGFloat(transform.dx),
		CGFloat(transform.dy))
}