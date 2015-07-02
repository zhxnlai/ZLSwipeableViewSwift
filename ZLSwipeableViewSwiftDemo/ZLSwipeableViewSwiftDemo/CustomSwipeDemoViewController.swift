//
//  CustomSwipeDemoViewController.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 5/25/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import ZLSwipeableViewSwift

class CustomSwipeDemoViewController: ZLSwipeableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        leftBarButtonItem.addAction() { item in
            // custom push location and direction
            self.swipeableView.swipeTopView(fromPoint: CGPoint(x: 10, y: 300), inDirection: CGVector(dx: -700, dy: -300))
        }
        upBarButtonItem.addAction() { item in
            self.swipeableView.swipeTopView(fromPoint: CGPoint(x: 100, y: 30), inDirection: CGVector(dx: 100, dy: -800))
        }
        
        // change how ZLSwipeableViewDirection gets interpreted to location and direction
        swipeableView.interpretDirection = {(topView: UIView, direction: ZLSwipeableViewDirection, views: [UIView], swipeableView: ZLSwipeableView) in
            let programmaticSwipeVelocity = CGFloat(500)
            let location = CGPoint(x: topView.center.x-30, y: topView.center.y*0.1)
            var directionVector: CGVector?
            switch direction {
            case ZLSwipeableViewDirection.Left:
                directionVector = CGVector(dx: -programmaticSwipeVelocity, dy: 0)
            case ZLSwipeableViewDirection.Right:
                directionVector = CGVector(dx: programmaticSwipeVelocity, dy: 0)
            case ZLSwipeableViewDirection.Up:
                directionVector = CGVector(dx: 0, dy: -programmaticSwipeVelocity)
            case ZLSwipeableViewDirection.Down:
                directionVector = CGVector(dx: 0, dy: programmaticSwipeVelocity)
            default:
                directionVector = CGVector(dx: 0, dy: 0)
            }
            return (location, directionVector!)
        }

    }

}
