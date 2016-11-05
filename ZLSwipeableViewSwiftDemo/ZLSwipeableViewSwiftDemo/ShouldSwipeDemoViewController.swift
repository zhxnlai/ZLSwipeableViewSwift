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
        
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)

        let defaultHandler = swipeableView.shouldSwipeView
        swipeableView.shouldSwipeView = {(view: UIView, movement: Movement, swipeableView: ZLSwipeableView) in
            self.shouldSwipe && defaultHandler(view, movement, swipeableView)
        }
    }
    
    // MARK: - Actions
    
    func handleTimer() {
        self.shouldSwipe = !self.shouldSwipe
        self.title = "Should Swipe " + (self.shouldSwipe ? "👍" : "👎")
    }

}
