//
//  ViewController.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 4/27/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import UIColor_FlatColors
import Cartography

class ZLSwipeableViewController: UIViewController {

    var swipeableView: ZLSwipeableView!
    
    var colors = ["Turquoise", "Green Sea", "Emerald", "Nephritis", "Peter River", "Belize Hole", "Amethyst", "Wisteria", "Wet Asphalt", "Midnight Blue", "Sun Flower", "Orange", "Carrot", "Pumpkin", "Alizarin", "Pomegranate", "Clouds", "Silver", "Concrete", "Asbestos"]
    var colorIndex = 0
    var loadCardsFromXib = false
    
    var reloadBarButtonItem: UIBarButtonItem!
    // var reloadBarButtonItem = UIBarButtonItem(barButtonSystemItem: "Reload", target: .Plain) { item in }
    var leftBarButtonItem: UIBarButtonItem!
    // var leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: "←", target: .Plain) { item in }
    var upBarButtonItem: UIBarButtonItem!
    // var upBarButtonItem = UIBarButtonItem(barButtonSystemItem: "↑", target: .Plain) { item in }
    var rightBarButtonItem: UIBarButtonItem!
    // var rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: "→", target: .Plain) { item in }
    var downBarButtonItem:UIBarButtonItem!
    // var downBarButtonItem = UIBarButtonItem(barButtonSystemItem: "↓", target: .Plain) { item in }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        swipeableView.nextView = {
            return self.nextCardView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setToolbarHidden(false, animated: false)
        view.backgroundColor = UIColor.white
        view.clipsToBounds = true
        
        reloadBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(reloadButtonAction))
        leftBarButtonItem = UIBarButtonItem(title: "←", style: .plain, target: self, action: #selector(leftButtonAction))
        upBarButtonItem = UIBarButtonItem(title: "↑", style: .plain, target: self, action: #selector(upButtonAction))
        rightBarButtonItem = UIBarButtonItem(title: "→", style: .plain, target: self, action: #selector(rightButtonAction))
        downBarButtonItem = UIBarButtonItem(title: "↓", style: .plain, target: self, action: #selector(downButtonAction))
        
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let items = [fixedSpace, reloadBarButtonItem!, flexibleSpace, leftBarButtonItem!, flexibleSpace, upBarButtonItem!, flexibleSpace, rightBarButtonItem!, flexibleSpace, downBarButtonItem!, fixedSpace]
        toolbarItems = items

        swipeableView = ZLSwipeableView()
        view.addSubview(swipeableView)
        swipeableView.didStart = {view, location in
            print("Did start swiping view at location: \(location)")
        }
        swipeableView.swiping = {view, location, translation in
            print("Swiping at view location: \(location) translation: \(translation)")
        }
        swipeableView.didEnd = {view, location in
            print("Did end swiping view at location: \(location)")
        }
        swipeableView.didSwipe = {view, direction, vector in
            print("Did swipe view in direction: \(direction), vector: \(vector)")
        }
        swipeableView.didCancel = {view in
            print("Did cancel swiping view")
        }
        swipeableView.didTap = {view, location in
            print("Did tap at location \(location)")
        }
        swipeableView.didDisappear = { view in
            print("Did disappear swiping view")
        }

        constrain(swipeableView, view) { view1, view2 in
            view1.left == view2.left+50
            view1.right == view2.right-50
            view1.top == view2.top + 120
            view1.bottom == view2.bottom - 100
        }
    }
    
    // MARK: - Actions
    
    func reloadButtonAction() {
        let alertController = UIAlertController(title: nil, message: "Load Cards:", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let ProgrammaticallyAction = UIAlertAction(title: "Programmatically", style: .default) { (action) in
            self.loadCardsFromXib = false
            self.colorIndex = 0
            self.swipeableView.discardViews()
            self.swipeableView.loadViews()
        }
        alertController.addAction(ProgrammaticallyAction)
        
        let XibAction = UIAlertAction(title: "From Xib", style: .default) { (action) in
            self.loadCardsFromXib = true
            self.colorIndex = 0
            self.swipeableView.discardViews()
            self.swipeableView.loadViews()
        }
        alertController.addAction(XibAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func leftButtonAction() {
        self.swipeableView.swipeTopView(inDirection: .Left)
    }
    
    func upButtonAction() {
        self.swipeableView.swipeTopView(inDirection: .Up)
    }
    
    func rightButtonAction() {
        self.swipeableView.swipeTopView(inDirection: .Right)
    }
    
    func downButtonAction() {
        self.swipeableView.swipeTopView(inDirection: .Down)
    }
    
    // MARK: ()
    func nextCardView() -> UIView? {
        if colorIndex >= colors.count {
            colorIndex = 0
        }

        let cardView = CardView(frame: swipeableView.bounds)
        cardView.backgroundColor = colorForName(colors[colorIndex])
        colorIndex += 1

        if loadCardsFromXib {
            let contentView = Bundle.main.loadNibNamed("CardContentView", owner: self, options: nil)?.first! as! UIView
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.backgroundColor = cardView.backgroundColor
            cardView.addSubview(contentView)

            // This is important:
            // https://github.com/zhxnlai/ZLSwipeableView/issues/9
            /*// Alternative:
            let metrics = ["width":cardView.bounds.width, "height": cardView.bounds.height]
            let views = ["contentView": contentView, "cardView": cardView]
            cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView(width)]", options: .AlignAllLeft, metrics: metrics, views: views))
            cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView(height)]", options: .AlignAllLeft, metrics: metrics, views: views))
            */
            constrain(contentView, cardView) { view1, view2 in
                view1.left == view2.left
                view1.top == view2.top
                view1.width == cardView.bounds.width
                view1.height == cardView.bounds.height
            }
        }
        return cardView
    }

    func colorForName(_ name: String) -> UIColor {
        let sanitizedName = name.replacingOccurrences(of: " ", with: "")
        let selector = "flat\(sanitizedName)Color"
        return UIColor.perform(Selector(selector)).takeUnretainedValue() as! UIColor
    }
}

