//
//  UndoDemoViewController.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 5/25/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import ReactiveUI
import ZLSwipeableViewSwift

class UndoDemoViewController: ZLSwipeableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        var lastSwipedView: (UIView, ZLSwipeableViewDirection)?
        swipeableView.didSwipe = {view, direction, vector in
            println("Did swipe view in direction: \(direction)")
            lastSwipedView = (view, direction)
        }
        // ↺
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Undo", style: .Plain) { item in
            if let (view, direction) = lastSwipedView {
                let width = self.swipeableView.bounds.width
                let height = self.swipeableView.bounds.height
                var point: CGPoint?
                switch direction {
                case ZLSwipeableViewDirection.Left:
                    point = CGPoint(x: -width, y: height/2)
                case ZLSwipeableViewDirection.Right:
                    point = CGPoint(x: width*2, y: height/2)
                case ZLSwipeableViewDirection.Up:
                    point = CGPoint(x: width/2, y: -height)
                case ZLSwipeableViewDirection.Down:
                    point = CGPoint(x: width/2, y: height*2)
                default:
                    point = CGPointZero
                }
                self.swipeableView.insertTopView(view, fromPoint: point!)
            }
        }
    }

}
