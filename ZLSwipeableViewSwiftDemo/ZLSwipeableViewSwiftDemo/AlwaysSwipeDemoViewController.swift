//
//  AlwaysSwipeViewController.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 10/23/15.
//  Copyright © 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

class AlwaysSwipeDemoViewController: ZLSwipeableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        swipeableView.shouldSwipeView = { _, _, _ in true }
    }

}
