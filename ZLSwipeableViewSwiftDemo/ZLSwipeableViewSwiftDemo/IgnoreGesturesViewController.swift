//
//  IgnoreGesturesViewController.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by couture on 2018-05-01.
//  Copyright © 2018 Zhixuan Lai. All rights reserved.
//

import UIKit

class IgnoreGensturesViewController: ZLSwipeableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        swipeableView.ignoreGestures = true
    }

}
