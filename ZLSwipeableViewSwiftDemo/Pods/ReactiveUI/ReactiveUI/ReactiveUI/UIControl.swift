//
//  UIControl.swift
//  ReactiveControl
//
//  Created by Zhixuan Lai on 1/8/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

public extension UIControl {
    
    convenience init(action: UIControl -> (), forControlEvents events: UIControlEvents) {
        self.init()
        addAction(action, forControlEvents: events)
    }

    convenience init(forControlEvents events: UIControlEvents, action: UIControl -> ()) {
        self.init()
        addAction(action, forControlEvents: events)
    }
    
    func addAction(action: UIControl -> (), forControlEvents events: UIControlEvents) {
        removeAction(forControlEvents: events)

        let proxyTarget = RUIControlProxyTarget(action: action)
        proxyTargets[keyForEvents(events)] = proxyTarget
        addTarget(proxyTarget, action: RUIControlProxyTarget.actionSelector(), forControlEvents: events)
    }
    
    func forControlEvents(events: UIControlEvents, addAction action: UIControl -> ()) {
        addAction(action, forControlEvents: events)
    }

    func removeAction(forControlEvents events: UIControlEvents) {
        if let proxyTarget = proxyTargets[keyForEvents(events)] {
            removeTarget(proxyTarget, action: RUIControlProxyTarget.actionSelector(), forControlEvents: events)
            proxyTargets.removeValueForKey(keyForEvents(events))
        }
    }
    
    func actionForControlEvent(events: UIControlEvents) -> (UIControl -> ())? {
        return proxyTargets[keyForEvents(events)]?.action
    }
    
    var actions: [UIControl -> ()] {
        return [RUIControlProxyTarget](proxyTargets.values).map({$0.action})
    }
    
}

internal extension UIControl {

    typealias RUIControlProxyTargets = [String: RUIControlProxyTarget]
    
    class RUIControlProxyTarget : RUIProxyTarget {
        var action: UIControl -> ()
        
        init(action: UIControl -> ()) {
            self.action = action
        }
        
        func performAction(control: UIControl) {
            action(control)
        }
    }
    
    func keyForEvents(events: UIControlEvents) -> String {
        return "UIControlEvents: \(events.rawValue)"
    }
    
    var proxyTargets: RUIControlProxyTargets {
        get {
            if let targets = objc_getAssociatedObject(self, &RUIProxyTargetsKey) as? RUIControlProxyTargets {
                return targets
            } else {
                return setProxyTargets(RUIControlProxyTargets())
            }
        }
        set {
            setProxyTargets(newValue)
        }
    }
    
    private func setProxyTargets(newValue: RUIControlProxyTargets) -> RUIControlProxyTargets {
        objc_setAssociatedObject(self, &RUIProxyTargetsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return newValue
    }
    
}
