//
//  UIGestureRecognizer.swift
//  ReactiveControl
//
//  Created by Zhixuan Lai on 1/8/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

public extension UIGestureRecognizer {
    
    convenience init(action: UIGestureRecognizer -> ()) {
        self.init()
        addAction(action)
    }
    
    func addAction(action: UIGestureRecognizer -> ()) {
        removeAction()
        
        proxyTarget = RUIGestureRecognizerProxyTarget(action: action)
        addTarget(proxyTarget, action: RUIGestureRecognizerProxyTarget.actionSelector())
    }
    
    func removeAction() {
        self.removeTarget(proxyTarget, action: RUIGestureRecognizerProxyTarget.actionSelector())
    }
    
}

internal extension UIGestureRecognizer {
    
    typealias RUIGestureRecognizerProxyTargets = [String: RUIGestureRecognizerProxyTarget]
    
    class RUIGestureRecognizerProxyTarget : RUIProxyTarget {
        var action: UIGestureRecognizer -> ()
        
        init(action: UIGestureRecognizer -> ()) {
            self.action = action
        }
        
        func performAction(control: UIGestureRecognizer) {
            action(control)
        }
    }
    
    var proxyTarget: RUIGestureRecognizerProxyTarget {
        get {
            if let targets = objc_getAssociatedObject(self, &RUIProxyTargetsKey) as? RUIGestureRecognizerProxyTarget {
                return targets
            } else {
                return setProxyTargets(RUIGestureRecognizerProxyTarget(action: {_ in}))
            }
        }
        set {
            setProxyTargets(newValue)
        }
    }
    
    private func setProxyTargets(newValue: RUIGestureRecognizerProxyTarget) -> RUIGestureRecognizerProxyTarget {
        objc_setAssociatedObject(self, &RUIProxyTargetsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return newValue
    }
    
}