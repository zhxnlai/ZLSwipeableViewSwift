//
//  Scheduler.swift
//  ZLSwipeableViewSwift
//
//  Created by Andrew Breckenridge on 5/17/16.
//  Copyright © 2016 Andrew Breckenridge. All rights reserved.
//

import UIKit

class Scheduler : NSObject {
    
    typealias Action = () -> Void
    typealias EndCondition = () -> Bool
    
    var timer: NSTimer?
    var action: Action?
    var endCondition: EndCondition?
    
    func scheduleRepeatedly(action: Action, interval: NSTimeInterval, endCondition: EndCondition)  {
        guard timer == nil && interval > 0 else { return }
        self.action = action
        self.endCondition = endCondition
        timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: #selector(Scheduler.doAction(_:)), userInfo: nil, repeats: true)
    }
    
    func doAction(timer: NSTimer) {
        guard let action = action, let endCondition = endCondition where !endCondition() else {
            timer.invalidate()
            self.timer = nil
            self.action = nil
            self.endCondition = nil
            return
        }
        action()
    }
    
}