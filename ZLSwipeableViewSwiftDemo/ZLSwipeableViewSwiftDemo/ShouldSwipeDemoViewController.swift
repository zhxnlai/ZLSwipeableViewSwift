//
//  ShouldSwipeDemoViewController.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 6/17/15.
//  Copyright © 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

class ShouldSwipeDemoViewController: ZLSwipeableViewController {

    var shouldSwipe = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Should Swipe 👍"
        NSTimer.scheduledTimerWithTimeInterval(3, action: {_ in
            self.shouldSwipe = !self.shouldSwipe
            self.title = "Should Swipe " + (self.shouldSwipe ? "👍" : "👎")
        }, repeats: true)

        let defaultHandler = swipeableView.shouldSwipeView
        swipeableView.shouldSwipeView = {(view: UIView, movement: Movement, swipeableView: ZLSwipeableView) in
            self.shouldSwipe && defaultHandler(view: view, movement: movement, swipeableView: swipeableView)
        }
    }

}
