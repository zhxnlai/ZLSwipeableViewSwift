//
//  AlwaysSwipeViewController.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 10/23/15.
//  Copyright © 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

class AlwaysSwipeDemoViewController: ZLSwipeableViewController {

    var shouldSwipe = true
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Always Swipe"
        swipeableView.shouldSwipeView = { _, _, _ in true }
    }

}
