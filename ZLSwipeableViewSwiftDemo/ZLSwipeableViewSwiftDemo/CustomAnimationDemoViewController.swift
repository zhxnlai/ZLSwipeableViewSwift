//
//  CustomAnimationDemoViewController.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 5/25/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

class CustomAnimationDemoViewController: ZLSwipeableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        func toRadian(degree: CGFloat) -> CGFloat {
            return degree * CGFloat(M_PI/180)
        }
        func rotateAndTranslateView(view: UIView, forDegree degree: CGFloat, translation: CGPoint, duration: NSTimeInterval, offsetFromCenter offset: CGPoint, swipeableView: ZLSwipeableView) {
            UIView.animateWithDuration(duration, delay: 0, options: .AllowUserInteraction, animations: {
                view.center = swipeableView.convertPoint(swipeableView.center, fromView: swipeableView.superview)
                var transform = CGAffineTransformMakeTranslation(offset.x, offset.y)
                transform = CGAffineTransformRotate(transform, toRadian(degree))
                transform = CGAffineTransformTranslate(transform, -offset.x, -offset.y)
                transform = CGAffineTransformTranslate(transform, translation.x, translation.y)
                view.transform = transform
                }, completion: nil)
        }
        swipeableView.numberOfActiveView = 10
        swipeableView.animateView = {(view: UIView, index: Int, views: [UIView], swipeableView: ZLSwipeableView) in
            let degree = CGFloat(sin(0.5*Double(index)))
            let offset = CGPoint(x: 0, y: CGRectGetHeight(swipeableView.bounds)*0.3)
            let translation = CGPoint(x: degree*10, y: CGFloat(-index*5))
            let duration = 0.4
            rotateAndTranslateView(view, forDegree: degree, translation: translation, duration: duration, offsetFromCenter: offset, swipeableView: swipeableView)
        }
    }
    
}
