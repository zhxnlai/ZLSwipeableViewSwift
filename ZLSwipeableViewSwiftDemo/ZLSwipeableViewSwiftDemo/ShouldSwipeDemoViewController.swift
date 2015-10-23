//
//  ShouldSwipeDemoViewController.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 6/17/15.
//  Copyright © 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import ReactiveUI

class ShouldSwipeDemoViewController: ZLSwipeableViewController {

    var shouldSwipe = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Should Swipe 👍"
        NSTimer.scheduledTimerWithTimeInterval(3, action: {_ in
            self.shouldSwipe = !self.shouldSwipe
            self.title = "Should Swipe " + (self.shouldSwipe ? "👍" : "👎")
        }, repeats: true)
        
        swipeableView.shouldSwipeView = {_, _, _ in self.shouldSwipe}
    }

}
