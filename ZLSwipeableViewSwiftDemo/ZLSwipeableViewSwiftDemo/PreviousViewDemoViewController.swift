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
        let rightBarButtonItem = UIBarButtonItem(title: rightBarButtonItemTitle, style: .plain, target: self, action: #selector(rightBarButtonClicked))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    func applyRandomTansform(_ view: UIView) {
        let width = swipeableView.bounds.width
        let height = swipeableView.bounds.height
        let distance = max(width, height)

        func randomRadian() -> CGFloat {
            return CGFloat(arc4random() % 360)  * CGFloat(M_PI / 180)
        }

        var transform = CGAffineTransform(rotationAngle: randomRadian())
        transform = transform.translatedBy(x: distance, y: 0)
        transform = transform.rotated(by: randomRadian())
        view.transform = transform
    }
    
    // MARK: - Actions
    
    func rightBarButtonClicked() {
        self.swipeableView.rewind()
    }

}
