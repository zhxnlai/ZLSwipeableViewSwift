//
//  PreviousViewDemoViewController.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 10/23/15.
//  Copyright © 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

public func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

class PreviousViewDemoViewController: ZLSwipeableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        swipeableView.numberOfHistoryItem = UInt.max
        swipeableView.allowedDirection = Direction.All

        let rightBarButtonItemTitle = "Load Previous"

        swipeableView.previousView = {
            if let view = self.nextCardView() {
                self.applyRandomTansform(view)
                return view
            }
            return nil
        }
        
        // ↺
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: rightBarButtonItemTitle, style: .Plain) { item in
            self.swipeableView.rewind()
        }
    }

    func applyRandomTansform(view: UIView) {
        let width = swipeableView.bounds.width
        let height = swipeableView.bounds.height
        let distance = max(width, height)

        func randomRadian() -> CGFloat {
            return CGFloat(random() % 360)  * CGFloat(M_PI / 180)
        }

        var transform = CGAffineTransformMakeRotation(randomRadian())
        transform = CGAffineTransformTranslate(transform, distance, 0)
        transform = CGAffineTransformRotate(transform, randomRadian())
        view.transform = transform
    }

}
