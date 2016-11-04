//
//  CustomDirectionDemoViewController.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 5/25/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

class CustomDirectionDemoViewController: ZLSwipeableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let segmentControl = UISegmentedControl(items: [" ", "←", "↑", "→", "↓", "↔︎", "↕︎", "☩"])
        segmentControl.selectedSegmentIndex = 5
        navigationItem.titleView = segmentControl
        
        segmentControl.addTarget(self, action: #selector(segmentedControlFired), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    func segmentedControlFired(control: AnyObject?) {
        if let control = control as? UISegmentedControl {
            let directions: [ZLSwipeableViewDirection] = [.None, .Left, .Up, .Right, .Down, .Horizontal, .Vertical, .All]
            self.swipeableView.allowedDirection = directions[control.selectedSegmentIndex]
        }
    }

}
