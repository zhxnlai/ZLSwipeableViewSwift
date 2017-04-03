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
        case snapping(CGPoint), moving(CGPoint), swiping(CGPoint, CGVector)
    }
    
    var state: State {
        didSet {
            if case .snapping(_) = oldValue,  case let .moving(point) = state {
                unsnapView()
                attachView(toPoint: point)
            } else if case .snapping(_) = oldValue,  case let .swiping(origin, direction) = state {
                unsnapView()
                attachView(toPoint: origin)
                pushView(fromPoint: origin, inDirection: direction)
            } else if case .moving(_) = oldValue, case let .moving(point) = state {
                moveView(toPoint: point)
            } else if case .moving(_) = oldValue, case let .snapping(point) = state {
                detachView()
                snapView(point)
            } else if case .moving(_) = oldValue, case let .swiping(origin, direction) = state {
                pushView(fromPoint: origin, inDirection: direction)
            } else if case .swiping(_, _) = oldValue, case let .snapping(point) = state {
                unpushView()
                detachView()
                snapView(point)
            }
        }
    }
    
    /// To be added to view and removed
    fileprivate class ZLPanGestureRecognizer: UIPanGestureRecognizer { }
    fileprivate class ZLTapGestureRecognizer: UITapGestureRecognizer { }
    
    static fileprivate let anchorViewWidth = CGFloat(1000)
    fileprivate var anchorView = UIView(frame: CGRect(x: 0, y: 0, width: anchorViewWidth, height: anchorViewWidth))
    
    fileprivate var snapBehavior: UISnapBehavior!
    fileprivate var viewToAnchorViewAttachmentBehavior: UIAttachmentBehavior!
    fileprivate var anchorViewToPointAttachmentBehavior: UIAttachmentBehavior!
    fileprivate var pushBehavior: UIPushBehavior!
    
    fileprivate let view: UIView
    fileprivate let containerView: UIView
    fileprivate let miscContainerView: UIView
    fileprivate let animator: UIDynamicAnimator
    fileprivate weak var swipeableView: ZLSwipeableView?
    
    init(view: UIView, containerView: UIView, index: Int, miscContainerView: UIView, animator: UIDynamicAnimator, swipeableView: ZLSwipeableView) {
        self.view = view
        self.containerView = containerView
        self.miscContainerView = miscContainerView
        self.animator = animator
        self.swipeableView = swipeableView
        self.state = ViewManager.defaultSnappingState(view)
        
        super.init()
        
        view.addGestureRecognizer(ZLPanGestureRecognizer(target: self, action: #selector(ViewManager.handlePan(_:))))
        if swipeableView.didTap != nil {
            self.addTapRecognizer()
        }
        miscContainerView.addSubview(anchorView)
        containerView.insertSubview(view, at: index)
    }
    
    static func defaultSnappingState(_ view: UIView) -> State {
        return .snapping(view.convert(view.center, from: view.superview))
    }
    
    func snappingStateAtContainerCenter() -> State {
        guard let swipeableView = swipeableView else { return ViewManager.defaultSnappingState(view) }
        return .snapping(containerView.convert(swipeableView.center, from: swipeableView.superview))
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
            if gestureRecognizer.isKind(of: ZLPanGestureRecognizer.classForCoder()) {
                view.removeGestureRecognizer(gestureRecognizer)
            }
        }
        
        anchorView.removeFromSuperview()
        view.removeFromSuperview()
    }
    
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard let swipeableView = swipeableView else { return }
        
        let translation = recognizer.translation(in: containerView)
        let location = recognizer.location(in: containerView)
        let velocity = recognizer.velocity(in: containerView)
        let movement = Movement(location: location, translation: translation, velocity: velocity)
        
        switch recognizer.state {
        case .began:
            guard case .snapping(_) = state else { return }
            state = .moving(location)
            swipeableView.didStart?(view, location)
        case .changed:
            guard case .moving(_) = state else { return }
            state = .moving(location)
            swipeableView.swiping?(view, location, translation)
        case .ended, .cancelled:
            guard case .moving(_) = state else { return }
            if swipeableView.shouldSwipeView(view, movement, swipeableView) {
                let directionVector = CGVector(point: translation.normalized * max(velocity.magnitude, swipeableView.minVelocityInPointPerSecond))
                state = .swiping(location, directionVector)
                swipeableView.swipeView(view, location: location, directionVector: directionVector)
            } else {
                state = snappingStateAtContainerCenter()
                swipeableView.didCancel?(view)
            }
            swipeableView.didEnd?(view, location)
        default:
            break
        }
    }
    
    func addTapRecognizer() {
        guard !(view.gestureRecognizers ?? []).contains(where: { $0 is ZLTapGestureRecognizer }) else { return }

        view.addGestureRecognizer(ZLTapGestureRecognizer(target: self, action: #selector(ViewManager.handleTap(_:))))
    }
    
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let swipeableView = swipeableView, let topView = swipeableView.topView()  else { return }
        
        let location = recognizer.location(in: containerView)
        swipeableView.didTap?(topView, location)
    }
    
    fileprivate func snapView(_ point: CGPoint) {
        snapBehavior = UISnapBehavior(item: view, snapTo: point)
        snapBehavior!.damping = 0.75
        addBehavior(snapBehavior)
    }
    
    fileprivate func unsnapView() {
        guard let snapBehavior = snapBehavior else { return }
        removeBehavior(snapBehavior)
    }
    
    fileprivate func attachView(toPoint point: CGPoint) {
        anchorView.center = point
        anchorView.backgroundColor = UIColor.blue
        anchorView.isHidden = true
        
        // attach aView to anchorView
        let p = view.center
        viewToAnchorViewAttachmentBehavior = UIAttachmentBehavior(item: view, offsetFromCenter: UIOffset(horizontal: -(p.x - point.x), vertical: -(p.y - point.y)), attachedTo: anchorView, offsetFromCenter: UIOffset.zero)
        viewToAnchorViewAttachmentBehavior!.length = 0
        
        // attach anchorView to point
        anchorViewToPointAttachmentBehavior = UIAttachmentBehavior(item: anchorView, offsetFromCenter: UIOffset.zero, attachedToAnchor: point)
        anchorViewToPointAttachmentBehavior!.damping = 100
        anchorViewToPointAttachmentBehavior!.length = 0
        
        addBehavior(viewToAnchorViewAttachmentBehavior!)
        addBehavior(anchorViewToPointAttachmentBehavior!)
    }
    
    fileprivate func moveView(toPoint point: CGPoint) {
        guard let _ = viewToAnchorViewAttachmentBehavior, let toPoint = anchorViewToPointAttachmentBehavior else { return }
        toPoint.anchorPoint = point
    }
    
    fileprivate func detachView() {
        guard let viewToAnchorViewAttachmentBehavior = viewToAnchorViewAttachmentBehavior, let anchorViewToPointAttachmentBehavior = anchorViewToPointAttachmentBehavior else { return }
        removeBehavior(viewToAnchorViewAttachmentBehavior)
        removeBehavior(anchorViewToPointAttachmentBehavior)
    }
    
    fileprivate func pushView(fromPoint point: CGPoint, inDirection direction: CGVector) {
        guard let _ = viewToAnchorViewAttachmentBehavior, let anchorViewToPointAttachmentBehavior = anchorViewToPointAttachmentBehavior  else { return }
        
        removeBehavior(anchorViewToPointAttachmentBehavior)
        
        pushBehavior = UIPushBehavior(items: [anchorView], mode: .instantaneous)
        pushBehavior.pushDirection = direction
        addBehavior(pushBehavior)
    }
    
    fileprivate func unpushView() {
        guard let pushBehavior = pushBehavior else { return }
        removeBehavior(pushBehavior)
    }
    
    fileprivate func addBehavior(_ behavior: UIDynamicBehavior) {
        animator.addBehavior(behavior)
    }
    
    fileprivate func removeBehavior(_ behavior: UIDynamicBehavior) {
        animator.removeBehavior(behavior)
    }
    
}
