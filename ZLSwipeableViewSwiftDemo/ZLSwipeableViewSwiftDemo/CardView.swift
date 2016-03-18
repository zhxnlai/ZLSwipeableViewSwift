//
//  CardView.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 5/24/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

class CardView: UIView {

    override func layoutSublayersOfLayer(layer: CALayer) {
        
        // Shadow
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 1.5)
        layer.shadowRadius = 4.0
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        
        // Corner Radius
        layer.cornerRadius = 10.0
    }
}
