//
//  CustomAnimationDemoViewController.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 5/25/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import ZLSwipeableViewSwift

class CustomAnimationDemoViewController: ZLSwipeableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        func toRadian(degree: CGFloat) -> CGFloat {
            return degree * CGFloat(M_PI/100)
        }
        func rotateAndTranslateView(view: UIView, forDegree degree: CGFloat, forPoint point: CGPoint, #duration: NSTimeInterval, offsetFromCenter offset: CGPoint, swipeableView: ZLSwipeableView) {
            UIView.animateWithDuration(duration, delay: 0, options: .AllowUserInteraction, animations: {
                view.center = swipeableView.convertPoint(swipeableView.center, fromView: swipeableView.superview)
                var transform = CGAffineTransformMakeTranslation(offset.x, offset.y)
                transform = CGAffineTransformRotate(transform, toRadian(degree))
                transform = CGAffineTransformTranslate(transform, -offset.x, -offset.y)
                transform = CGAffineTransformTranslate(transform, point.x, point.y)
                view.transform = transform
                }, completion: nil)
        }
        swipeableView.numPrefetchedViews = 10
        swipeableView.animateView = {(view: UIView, index: Int, views: [UIView], swipeableView: ZLSwipeableView) in
            let degree = CGFloat(sin(0.5*Double(index))),
                offset = CGPoint(x: 0, y: CGRectGetHeight(swipeableView.bounds)*0.3)
            let point = CGPoint(x: degree*10, y: CGFloat(-index*5))
            rotateAndTranslateView(view, forDegree: degree, forPoint: point, duration: 0.4, offsetFromCenter: offset, swipeableView)
        }
    }
    
}
