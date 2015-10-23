//
//  UndoDemoViewController.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 5/25/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import ReactiveUI

public func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

class UndoDemoViewController: ZLSwipeableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        swipeableView.allowedDirection = Direction.All

        let rightBarButtonItemTitle = "Undo"
        var swipedViews = [(UIView, CGPoint)]()

        func updateRightBarButtonItem() {
            let enabled = swipedViews.count != 0
            self.navigationItem.rightBarButtonItem?.enabled = enabled
            if !enabled {
                self.navigationItem.rightBarButtonItem?.title = rightBarButtonItemTitle
                return
            }
            let suffix = " (\(swipedViews.count))"
            self.navigationItem.rightBarButtonItem?.title = "\(rightBarButtonItemTitle)\(suffix)"
        }

        swipeableView.didSwipe = {view, direction, vector in
            print("Did swipe view in direction: \(direction)")

            let width = self.swipeableView.bounds.width
            let height = self.swipeableView.bounds.height
            let distance = max(width, height)
            let point = self.view.convertPoint(self.swipeableView.center, toView: self.swipeableView) + CGPoint(vector: vector).normalized * distance
            swipedViews.append((view, point))
            updateRightBarButtonItem()
        }

        // ↺
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: rightBarButtonItemTitle, style: .Plain) { item in
            guard let (view, point) = swipedViews.popLast() else { return }
            self.swipeableView.insertTopView(view, fromPoint: point)
            updateRightBarButtonItem()
        }

        updateRightBarButtonItem()
    }

}
