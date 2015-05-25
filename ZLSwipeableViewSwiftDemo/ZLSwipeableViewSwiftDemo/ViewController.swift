//
//  ViewController.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 4/27/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import performSelector_swift
import UIColor_FlatColors
import Cartography

class ViewController: UIViewController {

    @IBOutlet weak var swipeableView: ZLSwipeableView!

    @IBAction func reload(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: "Load Cards:", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let ProgrammaticallyAction = UIAlertAction(title: "Programmatically", style: .Default) { (action) in
            self.loadCardsFromXib = false
            self.colorIndex = 0
            self.swipeableView.discardViews()
            self.swipeableView.loadViews()
        }
        alertController.addAction(ProgrammaticallyAction)

        let XibAction = UIAlertAction(title: "From Xib", style: .Default) { (action) in
            self.loadCardsFromXib = true
            self.colorIndex = 0
            self.swipeableView.discardViews()
            self.swipeableView.loadViews()
        }
        alertController.addAction(XibAction)

        self.presentViewController(alertController, animated: true, completion: nil)
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
    
    var colors = ["Turquoise", "Green Sea", "Emerald", "Nephritis", "Peter River", "Belize Hole", "Amethyst", "Wisteria", "Wet Asphalt", "Midnight Blue", "Sun Flower", "Orange", "Carrot", "Pumpkin", "Alizarin", "Pomegranate", "Clouds", "Silver", "Concrete", "Asbestos"]
    var colorIndex = 0
    var loadCardsFromXib = false
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        swipeableView.loadViews()
    }
    
    // TODO: customize animation, direction
    override func viewDidLoad() {
        super.viewDidLoad()

        swipeableView.didStart = {view, location in
            println("Did start swiping view at location: \(location)")
        }
        swipeableView.swiping = {view, location, translation in
            println("Swiping at view location: \(location) translation: \(translation)")
        }
        swipeableView.didEnd = {view, location in
            println("Did end swiping view at location: \(location)")
        }
        swipeableView.didSwipe = {view, direction in
            println("Did swipe view in direction: \(direction)")
        }
        swipeableView.didCancel = {view in
            println("Did cancel swiping view")
        }

        swipeableView.nextView = {
            if self.colorIndex < self.colors.count {
                var cardView = CardView(frame: self.swipeableView.bounds)
                cardView.backgroundColor = self.colorForName(self.colors[self.colorIndex])
                self.colorIndex++
                
                if self.loadCardsFromXib {
                    var contentView = NSBundle.mainBundle().loadNibNamed("CardContentView", owner: self, options: nil).first! as! UIView
                    contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
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
                    layout(contentView, cardView) { view1, view2 in
                        view1.left == view2.left
                        view1.top == view2.top
                        view1.width == cardView.bounds.width
                        view1.height == cardView.bounds.height
                    }
                } else {
                    var textView = UITextView(frame: cardView.bounds)
                    textView.text = "This UITextView was created programmatically."
                    textView.backgroundColor = UIColor.clearColor()
                    textView.font = UIFont.systemFontOfSize(24)
                    textView.editable = false
                    textView.selectable = false
                    cardView.addSubview(textView)
                }
                return cardView
            }
            return nil
        }
    }
    
    // MARK: ()
    func colorForName(name: String) -> UIColor {
        let sanitizedName = name.stringByReplacingOccurrencesOfString(" ", withString: "")
        let selector = "flat\(sanitizedName)Color"
        return UIColor.swift_performSelector(Selector(selector), withObject: nil) as! UIColor
    }
}

