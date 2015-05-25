//
//  UIReactiveControl.swift
//  ReactiveControl
//
//  Created by Zhixuan Lai on 1/8/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

internal var RUIProxyTargetsKey = "s"

internal class RUIProxyTarget : NSObject {
    class func actionSelector() -> Selector {
        return Selector("performAction:")
    }
}