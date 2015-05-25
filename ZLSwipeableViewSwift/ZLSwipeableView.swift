//
//  ZLSwipeableView.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 4/27/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

public func ==(lhs: ZLSwipeableViewDirection, rhs: ZLSwipeableViewDirection) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

public struct ZLSwipeableViewDirection : RawOptionSetType, Printable {
    public var rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    // MARK: NilLiteralConvertible
    public init(nilLiteral: ()) {
        self.rawValue = 0
    }

    // MARK: BitwiseOperationsType
    public static var allZeros: ZLSwipeableViewDirection {
        return self(rawValue: 0)
    }

    static var None: ZLSwipeableViewDirection       { return self(rawValue: 0b0000) }
    static var Left: ZLSwipeableViewDirection       { return self(rawValue: 0b0001) }
    static var Right: ZLSwipeableViewDirection      { return self(rawValue: 0b0010) }
    static var Up: ZLSwipeableViewDirection         { return self(rawValue: 0b0100) }
    static var Down: ZLSwipeableViewDirection       { return self(rawValue: 0b1000) }
    static var Horizontal: ZLSwipeableViewDirection { return Left | Right }
    static var Vertical: ZLSwipeableViewDirection   { return Up | Down }
    static var All: ZLSwipeableViewDirection        { return Horizontal | Vertical }
    
    static func fromPoint(point: CGPoint) -> ZLSwipeableViewDirection {
        switch (point.x, point.y) {
        case let (x, y) where abs(x)>=abs(y) && x>=0:
            return .Right
        case let (x, y) where abs(x)>=abs(y) && x<0:
            return .Left
        case let (x, y) where abs(x)<abs(y) && y<=0:
            return .Up
        case let (x, y) where abs(x)<abs(y) && y>0:
            return .Down
        case let (x, y):
            return .None
        }
    }
    
    public var description: String {
        switch self {
        case ZLSwipeableViewDirection.None:
            return "None"
        case ZLSwipeableViewDirection.Left:
            return "Left"
        case ZLSwipeableViewDirection.Right:
            return "Right"
        case ZLSwipeableViewDirection.Up:
            return "Up"
        case ZLSwipeableViewDirection.Down:
            return "Down"
        case ZLSwipeableViewDirection.Horizontal:
            return "Horizontal"
        case ZLSwipeableViewDirection.Vertical:
            return "Vertical"
        case ZLSwipeableViewDirection.All:
            return "All"
        default:
            return "Unknown"
        }
    }
}

public class ZLSwipeableView: UIView {
    // MARK: - Public
    // MARK: Data Source
    public var numPrefetchedViews = 3
    public var nextView: (() -> UIView?)?
    // MARK: Animation
    public var animateView: (view: UIView, index: Int, views: [UIView], swipeableView: ZLSwipeableView) -> () = {
        func toRadian(degree: CGFloat) -> CGFloat {
            return degree * CGFloat(M_PI/100)
        }
        func rotateView(view: UIView, forDegree degree: CGFloat, #duration: NSTimeInterval, offsetFromCenter offset: CGPoint, swipeableView: ZLSwipeableView) {
            UIView.animateWithDuration(duration, delay: 0, options: .AllowUserInteraction, animations: {
                view.center = swipeableView.convertPoint(swipeableView.center, fromView: swipeableView.superview)
                var transform = CGAffineTransformMakeTranslation(offset.x, offset.y)
                transform = CGAffineTransformRotate(transform, toRadian(degree))
                transform = CGAffineTransformTranslate(transform, -offset.x, -offset.y)
                view.transform = transform
                }, completion: nil)
        }
        return {(view: UIView, index: Int, views: [UIView], swipeableView: ZLSwipeableView) in
            let degree = CGFloat(1), offset = CGPoint(x: 0, y: CGRectGetHeight(swipeableView.bounds)*0.3)
            switch index {
            case 0:
                break
            case 1:
                rotateView(view, forDegree: degree, duration: 0.4, offsetFromCenter: offset, swipeableView)
            case 2:
                rotateView(view, forDegree: -degree, duration: 0.4, offsetFromCenter: offset, swipeableView)
            default:
                break
            }
        }
    }()
    
    // MARK: Delegate
    public var didStart: ((view: UIView, atLocation: CGPoint) -> ())?
    public var swiping: ((view: UIView, atLocation: CGPoint, translation: CGPoint) -> ())?
    public var didEnd: ((view: UIView, atLocation: CGPoint) -> ())?
    public var didSwipe: ((view: UIView, inDirection: ZLSwipeableViewDirection) -> ())?
    public var didCancel: ((view: UIView) -> ())?

    // MARK: Swipe Control
    /// in percent
    public var translationThreshold = CGFloat(0.25)
    public var velocityThreshold = CGFloat(750)
    public var direction = ZLSwipeableViewDirection.Horizontal

    public var swipeTopView: (topView: UIView, direction: ZLSwipeableViewDirection, views: [UIView], swipeableView: ZLSwipeableView) -> (CGPoint, CGVector) = {(topView: UIView, direction: ZLSwipeableViewDirection, views: [UIView], swipeableView: ZLSwipeableView) in
        let programmaticSwipeVelocity = CGFloat(1000)
        let location = CGPoint(x: topView.center.x, y: topView.center.y*0.7)
        var directionVector: CGVector?
        switch direction {
        case ZLSwipeableViewDirection.Left:
            directionVector = CGVector(dx: -programmaticSwipeVelocity, dy: 0)
        case ZLSwipeableViewDirection.Right:
            directionVector = CGVector(dx: programmaticSwipeVelocity, dy: 0)
        case ZLSwipeableViewDirection.Up:
            directionVector = CGVector(dx: 0, dy: -programmaticSwipeVelocity)
        case ZLSwipeableViewDirection.Down:
            directionVector = CGVector(dx: 0, dy: programmaticSwipeVelocity)
        default:
            directionVector = CGVector(dx: 0, dy: 0)
        }
        return (location, directionVector!)
    }
    public func swipeTopView(inDirection direction: ZLSwipeableViewDirection) {
        if let topView = topView() {
            let (location, direction) = swipeTopView(topView: topView, direction: direction, views: views, swipeableView: self)
            swipeTopView(fromPoint: location, inDirection: direction)
        }
    }
    public func swipeTopView(fromPoint location: CGPoint, inDirection direction: CGVector) {
        if let topView = topView() {
            unsnapView()
            pushView(topView, fromPoint: location, inDirection: direction)
            removeTopView()
            loadViews()
        }
    }
    
    // MARK: View Management
    public var views = [UIView]()
    
    public func topView() -> UIView? {
        return views.first
    }
    public func removeTopView() {
        if let topView = topView() {
            topView.userInteractionEnabled = false
            views.removeAtIndex(0)
        }
    }
    
    public func loadViews() {
        for i in (views.count..<numPrefetchedViews) {
            if let nextView = nextView?() {
                nextView.addGestureRecognizer(ZLPanGestureRecognizer(target: self, action: Selector("handlePan:")))
                views.append(nextView)
                containerView.addSubview(nextView)
                containerView.sendSubviewToBack(nextView)
            }
        }
        if let topView = topView() {
            snapView(topView, toPoint: convertPoint(center, fromView: superview))
        }
        animateViews()
    }
    
    private func animateViews() {
        if let topView = topView() {
            for gestureRecognizer in topView.gestureRecognizers as! [UIGestureRecognizer] {
                if gestureRecognizer.state != .Possible {
                    return
                }
            }
        }
        
        for i in (0..<views.count) {
            var view = views[i]
            view.userInteractionEnabled = i == 0
            animateView(view: view, index: i, views: views, swipeableView: self)
        }
    }
    
    public func discardViews() {
        unsnapView()
        detachView()
        animator.removeAllBehaviors()
        for aView in views {
            removeFromContainerView(aView)
        }
        views.removeAll(keepCapacity: false)
    }

    private func removeFromContainerView(aView: UIView) {
        for gestureRecognizer in aView.gestureRecognizers as! [UIGestureRecognizer] {
            if gestureRecognizer.isKindOfClass(ZLPanGestureRecognizer.classForCoder()) {
                aView.removeGestureRecognizer(gestureRecognizer)
            }
        }
        aView.removeFromSuperview()
    }
    
    // MARK: Debug
    var debug = false {
        didSet {
            anchorView.hidden = !debug
        }
    }
    
    // MARK: - Private properties
    private var containerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        animator = UIDynamicAnimator(referenceView: self)
        pushAnimator = UIDynamicAnimator(referenceView: self)
        
        addSubview(containerView)
        addSubview(anchorContainerView)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = bounds
    }
    
    // MARK: Animator
    private var animator: UIDynamicAnimator!
    static private let anchorViewWidth = CGFloat(1000)
    private var anchorView = UIView(frame: CGRect(x: 0, y: 0, width: anchorViewWidth, height: anchorViewWidth))
    private var anchorContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self)
        let location = recognizer.locationInView(self)
        let aView = recognizer.view!
        
        switch recognizer.state {
        case .Began:
            unsnapView()
            attachView(aView, toPoint: location)
            didStart?(view: aView, atLocation: location)
        case .Changed:
            unsnapView()
            attachView(aView, toPoint: location)
            swiping?(view: aView, atLocation: location, translation: translation)
        case .Ended, .Cancelled:
            detachView()
            let velocity = recognizer.velocityInView(self)
            let velocityMag = velocity.magnitude
            
            let directionChecked = ZLSwipeableViewDirection.fromPoint(translation) & direction != .None
            let signChecked = CGPoint.areInSameTheDirection(translation, p2: velocity)
            let translationChecked = abs(translation.x) > translationThreshold * bounds.width ||
                                     abs(translation.y) > translationThreshold * bounds.height
            let velocityChecked = velocityMag > velocityThreshold
            if directionChecked && signChecked && (translationChecked || velocityChecked){
                let normalizedTrans = translation.normalized
                let throwVelocity = max(velocityMag, velocityThreshold)
                let directionVector = CGVector(dx: normalizedTrans.x*throwVelocity, dy: normalizedTrans.y*throwVelocity)

                pushView(aView, fromPoint: location, inDirection: directionVector)
                removeTopView()
                didSwipe?(view: aView, inDirection: ZLSwipeableViewDirection.fromPoint(translation))
                loadViews()
            } else {
                snapView(aView, toPoint: convertPoint(center, fromView: superview))
                didCancel?(view: aView)
            }
            didEnd?(view: aView, atLocation: location)
        default:
            break
        }
    }
    
    private var snapBehavior: UISnapBehavior!
    private func snapView(aView: UIView, toPoint point: CGPoint) {
        unsnapView()
        snapBehavior = UISnapBehavior(item: aView, snapToPoint: point)
        snapBehavior!.damping = 0.75
        animator.addBehavior(snapBehavior)
    }
    private func unsnapView() {
        animator.removeBehavior(snapBehavior)
        snapBehavior = nil
    }
    
    private var attachmentViewToAnchorView: UIAttachmentBehavior?
    private var attachmentAnchorViewToPoint: UIAttachmentBehavior?
    private func attachView(aView: UIView, toPoint point: CGPoint) {
        if var attachmentViewToAnchorView = attachmentViewToAnchorView, attachmentAnchorViewToPoint = attachmentAnchorViewToPoint {
            attachmentAnchorViewToPoint.anchorPoint = point
        } else {
            anchorView.center = point
            anchorView.backgroundColor = UIColor.blueColor()
            anchorView.hidden = !debug
            anchorContainerView.addSubview(anchorView)
            
            // attach aView to anchorView
            let p = aView.center
            attachmentViewToAnchorView = UIAttachmentBehavior(item: aView, offsetFromCenter: UIOffset(horizontal: -(p.x - point.x), vertical: -(p.y - point.y)), attachedToItem: anchorView, offsetFromCenter: UIOffsetZero)
            attachmentViewToAnchorView!.length = 0
            
            // attach anchorView to point
            attachmentAnchorViewToPoint = UIAttachmentBehavior(item: anchorView, offsetFromCenter: UIOffsetZero, attachedToAnchor: point)
            attachmentAnchorViewToPoint!.damping = 100
            attachmentAnchorViewToPoint!.length = 0
            
            animator.addBehavior(attachmentViewToAnchorView)
            animator.addBehavior(attachmentAnchorViewToPoint)
        }
    }
    private func detachView() {
        animator.removeBehavior(attachmentViewToAnchorView)
        animator.removeBehavior(attachmentAnchorViewToPoint)
        attachmentViewToAnchorView = nil
        attachmentAnchorViewToPoint = nil
    }
    
    // MARK: pushAnimator
    private var pushAnimator: UIDynamicAnimator!
    private var timer: NSTimer?
    private var pushBehaviors = [(UIView, UIView, UIAttachmentBehavior, UIPushBehavior)]()
    func cleanUp(timer: NSTimer) {
        var indexes = [Int]()
        for i in 0..<pushBehaviors.count {
            let (anchorView, aView, attachment, push) = self.pushBehaviors[i]
            if !CGRectIntersectsRect(convertRect(aView.frame, toView: nil), UIScreen.mainScreen().bounds) {
                anchorView.removeFromSuperview()
                aView.removeFromSuperview()
                pushAnimator.removeBehavior(attachment)
                pushAnimator.removeBehavior(push)
                indexes.append(i)
            }
        }
        
        for index in indexes.reverse() {
            pushBehaviors.removeAtIndex(index)
        }
        
        if pushBehaviors.count == 0 {
            timer.invalidate()
            self.timer = nil
        }
    }

    private func pushView(aView: UIView, fromPoint point: CGPoint, inDirection direction: CGVector) {
        var anchorView = UIView(frame: CGRect(x: 0, y: 0, width: ZLSwipeableView.anchorViewWidth, height: ZLSwipeableView.anchorViewWidth))
        anchorView.center = point
        anchorView.backgroundColor = UIColor.greenColor()
        anchorView.hidden = !debug
        anchorContainerView.addSubview(anchorView)

        var point = point
        let p = aView.convertPoint(aView.center, fromView: aView.superview)
        point = aView.convertPoint(point, fromView: aView.superview)
        var attachmentViewToAnchorView = UIAttachmentBehavior(item: aView, offsetFromCenter: UIOffset(horizontal: -(p.x - point.x), vertical: -(p.y - point.y)), attachedToItem: anchorView, offsetFromCenter: UIOffsetZero)
        attachmentViewToAnchorView!.length = 0

        var pushBehavior = UIPushBehavior(items: [anchorView], mode: .Instantaneous)
        pushBehavior.pushDirection = direction
        
        pushAnimator.addBehavior(attachmentViewToAnchorView)
        pushAnimator.addBehavior(pushBehavior)
        
        pushBehaviors.append((anchorView, aView, attachmentViewToAnchorView, pushBehavior))

        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "cleanUp:", userInfo: nil, repeats: true)
        }
    }

    // MARK: - ()
}

extension CGPoint {
    var normalized: CGPoint {
        return CGPoint(x: x/magnitude, y: y/magnitude)
    }
    var magnitude: CGFloat {
        return CGFloat(sqrtf(powf(Float(x), 2) + powf(Float(y), 2)))
    }
    static func areInSameTheDirection(p1: CGPoint, p2: CGPoint) -> Bool {
        func signNum(n: CGFloat) -> Int {
            return (n < 0.0) ? -1 : (n > 0.0) ? +1 : 0
        }
        return signNum(p1.x) == signNum(p2.x) && signNum(p1.y) == signNum(p2.y)
    }
}
