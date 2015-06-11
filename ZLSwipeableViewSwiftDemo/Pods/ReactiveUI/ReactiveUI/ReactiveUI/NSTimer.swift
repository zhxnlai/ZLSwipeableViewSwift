//
//  NSTimer.swift
//  ReactiveUI
//
//  Created by Zhixuan Lai on 2/2/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

public extension NSTimer {
    
    // Big thanks to https://github.com/ashfurrow/Haste
    class func scheduledTimerWithTimeInterval(seconds: NSTimeInterval, action: NSTimer -> (), repeats: Bool) -> NSTimer {
        return scheduledTimerWithTimeInterval(seconds, target: self, selector: "_timerDidFire:", userInfo: RUITimerProxyTarget(action: action), repeats: repeats)
    }
    
}

internal extension NSTimer {
    
    class func _timerDidFire(timer: NSTimer) {
        if let proxyTarget = timer.userInfo as? RUITimerProxyTarget {
            proxyTarget.performAction(timer)
        }
    }
    
    typealias RUITimerProxyTargets = [String: RUITimerProxyTarget]
    
    class RUITimerProxyTarget : RUIProxyTarget {
        var action: NSTimer -> ()
        
        init(action: NSTimer -> ()) {
            self.action = action
        }
        
        func performAction(control: NSTimer) {
            action(control)
        }
    }
    
    var proxyTarget: RUITimerProxyTarget {
        get {
            if let targets = objc_getAssociatedObject(self, &RUIProxyTargetsKey) as? RUITimerProxyTarget {
                return targets
            } else {
                return setProxyTargets(RUITimerProxyTarget(action: {_ in}))
            }
        }
        set {
            setProxyTargets(newValue)
        }
    }
    
    private func setProxyTargets(newValue: RUITimerProxyTarget) -> RUITimerProxyTarget {
        objc_setAssociatedObject(self, &RUIProxyTargetsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return newValue
    }
    
}