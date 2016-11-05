//
//  ViewManager.swift
//  ZLSwipeableViewSwift
//
//  Created by Andrew Breckenridge on 5/17/16.
//  Copyright © 2016 Andrew Breckenridge. All rights reserved.
//

import UIKit

class ViewManager : NSObject {
    
    // Snapping -> [Moving]+ -> Snapping
    // Snapping -> [Moving]+ -> Swiping -> Snapping
    enum State {
        case Snapping(CGPoint), Moving(CGPoint), Swiping(CGPoint, CGVector)
    }
    
    var state: State {
        didSet {
            if case .Snapping(_) = oldValue,  case let .Moving(point) = state {
                unsnapView()
                attachView(toPoint: point)
            } else if case .Snapping(_) = oldValue,  case let .Swiping(origin, direction) = state {
                unsnapView()
                attachView(toPoint: origin)
                pushView(fromPoint: origin, inDirection: direction)
            } else if case .Moving(_) = oldValue, case let .Moving(point) = state {
                moveView(toPoint: point)
            } else if case .Moving(_) = oldValue, case let .Snapping(point) = state {
                detachView()
                snapView(point)
            } else if case .Moving(_) = oldValue, case let .Swiping(origin, direction) = state {
                pushView(fromPoint: origin, inDirection: direction)
            } else if case .Swiping(_, _) = oldValue, case let .Snapping(point) = state {
                unpushView()
                detachView()
                snapView(point)
            }
        }
    }
    
    /// To be added to view and removed
    private class ZLPanGestureRecognizer: UIPanGestureRecognizer { }
    private class ZLTapGestureRecognizer: UITapGestureRecognizer { }
    
    static private let anchorViewWidth = CGFloat(1000)
    private var anchorView = UIView(frame: CGRect(x: 0, y: 0, width: anchorViewWidth, height: anchorViewWidth))
    
    private var snapBehavior: UISnapBehavior!
    private var viewToAnchorViewAttachmentBehavior: UIAttachmentBehavior!
    private var anchorViewToPointAttachmentBehavior: UIAttachmentBehavior!
    private var pushBehavior: UIPushBehavior!
    
    private let view: UIView
    private let containerView: UIView
    private let miscContainerView: UIView
    private let animator: UIDynamicAnimator
    private weak var swipeableView: ZLSwipeableView?
    
    init(view: UIView, containerView: UIView, index: Int, miscContainerView: UIView, animator: UIDynamicAnimator, swipeableView: ZLSwipeableView) {
        self.view = view
        self.containerView = containerView
        self.miscContainerView = miscContainerView
        self.animator = animator
        self.swipeableView = swipeableView
        self.state = ViewManager.defaultSnappingState(view)
        
        super.init()
        
        view.addGestureRecognizer(ZLPanGestureRecognizer(target: self, action: #selector(ViewManager.handlePan(_:))))
        view.addGestureRecognizer(ZLTapGestureRecognizer(target: self, action: #selector(ViewManager.handleTap(_:))))
        miscContainerView.addSubview(anchorView)
        containerView.insertSubview(view, atIndex: index)
    }
    
    static func defaultSnappingState(view: UIView) -> State {
        return .Snapping(view.convertPoint(view.center, fromView: view.superview))
    }
    
    func snappingStateAtContainerCenter() -> State {
        guard let swipeableView = swipeableView else { return ViewManager.defaultSnappingState(view) }
        return .Snapping(containerView.convertPoint(swipeableView.center, fromView: swipeableView.superview))
    }
    
    deinit {
        if let snapBehavior = snapBehavior {
            removeBehavior(snapBehavior)
        }
        if let viewToAnchorViewAttachmentBehavior = viewToAnchorViewAttachmentBehavior {
            removeBehavior(viewToAnchorViewAttachmentBehavior)
        }
        if let anchorViewToPointAttachmentBehavior = anchorViewToPointAttachmentBehavior {
            removeBehavior(anchorViewToPointAttachmentBehavior)
        }
        if let pushBehavior = pushBehavior {
            removeBehavior(pushBehavior)
        }
        
        for gestureRecognizer in view.gestureRecognizers! {
            if gestureRecognizer.isKindOfClass(ZLPanGestureRecognizer.classForCoder()) {
                view.removeGestureRecognizer(gestureRecognizer)
            }
        }
        
        anchorView.removeFromSuperview()
        view.removeFromSuperview()
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        guard let swipeableView = swipeableView else { return }
        
        let translation = recognizer.translationInView(containerView)
        let location = recognizer.locationInView(containerView)
        let velocity = recognizer.velocityInView(containerView)
        let movement = Movement(location: location, translation: translation, velocity: velocity)
        
        switch recognizer.state {
        case .Began:
            guard case .Snapping(_) = state else { return }
            state = .Moving(location)
            swipeableView.didStart?(view: view, atLocation: location)
        case .Changed:
            guard case .Moving(_) = state else { return }
            state = .Moving(location)
            swipeableView.swiping?(view: view, atLocation: location, translation: translation)
        case .Ended, .Cancelled:
            guard case .Moving(_) = state else { return }
            if swipeableView.shouldSwipeView(view: view, movement: movement, swipeableView: swipeableView) {
                let directionVector = CGVector(point: translation.normalized * max(velocity.magnitude, swipeableView.minVelocityInPointPerSecond))
                state = .Swiping(location, directionVector)
                swipeableView.swipeView(view, location: location, directionVector: directionVector)
            } else {
                state = snappingStateAtContainerCenter()
                swipeableView.didCancel?(view: view)
            }
            swipeableView.didEnd?(view: view, atLocation: location)
        default:
            break
        }
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        guard let swipeableView = swipeableView, topView = swipeableView.topView()  else { return }
        
        let location = recognizer.locationInView(containerView)
        swipeableView.didTap?(view: topView, atLocation: location)
    }
    
    private func snapView(point: CGPoint) {
        snapBehavior = UISnapBehavior(item: view, snapToPoint: point)
        snapBehavior!.damping = 0.75
        addBehavior(snapBehavior)
    }
    
    private func unsnapView() {
        guard let snapBehavior = snapBehavior else { return }
        removeBehavior(snapBehavior)
    }
    
    private func attachView(toPoint point: CGPoint) {
        anchorView.center = point
        anchorView.backgroundColor = UIColor.blueColor()
        anchorView.hidden = true
        
        // attach aView to anchorView
        let p = view.center
        viewToAnchorViewAttachmentBehavior = UIAttachmentBehavior(item: view, offsetFromCenter: UIOffset(horizontal: -(p.x - point.x), vertical: -(p.y - point.y)), attachedToItem: anchorView, offsetFromCenter: UIOffsetZero)
        viewToAnchorViewAttachmentBehavior!.length = 0
        
        // attach anchorView to point
        anchorViewToPointAttachmentBehavior = UIAttachmentBehavior(item: anchorView, offsetFromCenter: UIOffsetZero, attachedToAnchor: point)
        anchorViewToPointAttachmentBehavior!.damping = 100
        anchorViewToPointAttachmentBehavior!.length = 0
        
        addBehavior(viewToAnchorViewAttachmentBehavior!)
        addBehavior(anchorViewToPointAttachmentBehavior!)
    }
    
    private func moveView(toPoint point: CGPoint) {
        guard let _ = viewToAnchorViewAttachmentBehavior, let toPoint = anchorViewToPointAttachmentBehavior else { return }
        toPoint.anchorPoint = point
    }
    
    private func detachView() {
        guard let viewToAnchorViewAttachmentBehavior = viewToAnchorViewAttachmentBehavior, let anchorViewToPointAttachmentBehavior = anchorViewToPointAttachmentBehavior else { return }
        removeBehavior(viewToAnchorViewAttachmentBehavior)
        removeBehavior(anchorViewToPointAttachmentBehavior)
    }
    
    private func pushView(fromPoint point: CGPoint, inDirection direction: CGVector) {
        guard let _ = viewToAnchorViewAttachmentBehavior, let anchorViewToPointAttachmentBehavior = anchorViewToPointAttachmentBehavior  else { return }
        
        removeBehavior(anchorViewToPointAttachmentBehavior)
        
        pushBehavior = UIPushBehavior(items: [anchorView], mode: .Instantaneous)
        pushBehavior.pushDirection = direction
        addBehavior(pushBehavior)
    }
    
    private func unpushView() {
        guard let pushBehavior = pushBehavior else { return }
        removeBehavior(pushBehavior)
    }
    
    private func addBehavior(behavior: UIDynamicBehavior) {
        animator.addBehavior(behavior)
    }
    
    private func removeBehavior(behavior: UIDynamicBehavior) {
        animator.removeBehavior(behavior)
    }
    
}