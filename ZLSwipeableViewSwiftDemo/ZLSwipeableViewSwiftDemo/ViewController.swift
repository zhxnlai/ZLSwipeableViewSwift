//
//  ViewController.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 4/27/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var swipeableView: ZLSwipeableView!

    @IBAction func reload(sender: UIBarButtonItem) {
        swipeableView.discardViews()
        swipeableView.loadViews()
    }
    
    @IBAction func pushLeft(sender: UIBarButtonItem) {
        swipeableView.swipeTopView(inDirection: .Left)
    }
    
    @IBAction func pushUp(sender: UIBarButtonItem) {
        swipeableView.swipeTopView(inDirection: .Up)
    }
    
    @IBAction func pushRight(sender: UIBarButtonItem) {
        swipeableView.swipeTopView(inDirection: .Right)
    }
    
    @IBAction func pushDown(sender: UIBarButtonItem) {
        swipeableView.swipeTopView(inDirection: .Down)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        swipeableView.layoutIfNeeded()
        swipeableView.loadViews()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var count = 0
        swipeableView.nextView = {
            var cardView = UIView(frame: self.swipeableView.bounds)
            
            var label = UILabel(frame: cardView.frame)
            label.text = "# \(count)"
            label.textColor = UIColor.blackColor()
            label.numberOfLines = 0
            cardView.addSubview(label)
            
            cardView.backgroundColor = UIColor.lightGrayColor()
            cardView.layer.masksToBounds = false
            cardView.layer.cornerRadius = 8
            cardView.layer.shadowOffset = CGSizeMake(-5, 5)
            cardView.layer.shadowRadius = 5
            cardView.layer.shadowOpacity = 0.5
            cardView.layer.shouldRasterize = true
            
            count++
            return cardView
        }
        //        swipeableView.didStart
    }
}

