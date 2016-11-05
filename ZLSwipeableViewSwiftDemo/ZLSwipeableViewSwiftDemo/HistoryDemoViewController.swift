//
//  UndoDemoViewController.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 5/25/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

class HistoryDemoViewController: ZLSwipeableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        swipeableView.numberOfHistoryItem = UInt.max
        swipeableView.allowedDirection = Direction.All

        let rightBarButtonItemTitle = "Rewind"

        func updateRightBarButtonItem() {
            let historyLength = self.swipeableView.history.count
            let enabled = historyLength != 0
            self.navigationItem.rightBarButtonItem?.isEnabled = enabled
            if !enabled {
                self.navigationItem.rightBarButtonItem?.title = rightBarButtonItemTitle
                return
            }
            let suffix = " (\(historyLength))"
            self.navigationItem.rightBarButtonItem?.title = "\(rightBarButtonItemTitle)\(suffix)"
        }

        swipeableView.didSwipe = {view, direction, vector in
            print("Did swipe view in direction: \(direction)")
            updateRightBarButtonItem()
        }

        // ↺
        let rightButton = UIBarButtonItem(title: rightBarButtonItemTitle, style: .plain, target: self, action: #selector(rightButtonClicked))
        navigationItem.rightBarButtonItem = rightButton

        updateRightBarButtonItem()
    }
    
    // MARK: - Actions
    
    func rightButtonClicked() {
        self.swipeableView.rewind()
        // updateRightBarButtonItem()
    }

}
