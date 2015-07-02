//
//  CustomDirectionDemoViewController.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 5/25/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import ZLSwipeableViewSwift

class CustomDirectionDemoViewController: ZLSwipeableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var segmentControl = UISegmentedControl(items: [" ", "←", "↑", "→", "↓", "↔︎", "↕︎", "☩"])
        segmentControl.selectedSegmentIndex = 5
        navigationItem.titleView = segmentControl
        
        let directions: [ZLSwipeableViewDirection] = [.None, .Left, .Up, .Right, .Down, .Horizontal, .Vertical, .All]
        segmentControl.forControlEvents(.ValueChanged) { control in
            if let control = control as? UISegmentedControl {
                self.swipeableView.direction = directions[control.selectedSegmentIndex]
            }
        }
    }

}
