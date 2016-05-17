//
//  ZLSwipeableView.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 4/27/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

// data source
public typealias NextViewHandler = () -> UIView?
public typealias PreviousViewHandler = () -> UIView?

// customization
public typealias AnimateViewHandler = (view: UIView, index: Int, views: [UIView], swipeableView: ZLSwipeableView) -> ()
public typealias InterpretDirectionHandler = (topView: UIView, direction: Direction, views: [UIView], swipeableView: ZLSwipeableView) -> (CGPoint, CGVector)
public typealias ShouldSwipeHandler = (view: UIView, movement: Movement, swipeableView: ZLSwipeableView) -> Bool

// delegates
public typealias DidStartHandler = (view: UIView, atLocation: CGPoint) -> ()
public typealias SwipingHandler = (view: UIView, atLocation: CGPoint, translation: CGPoint) -> ()
public typealias DidEndHandler = (view: UIView, atLocation: CGPoint) -> ()
public typealias DidSwipeHandler = (view: UIView, inDirection: Direction, directionVector: CGVector) -> ()
public typealias DidCancelHandler = (view: UIView) -> ()
public typealias DidTap = (view: UIView, atLocation: CGPoint) -> ()
public typealias DidDisappear = (view: UIView) -> ()

public struct Movement {
    let location: CGPoint
    let translation: CGPoint
    let velocity: CGPoint
}

// MARK: - Main
public class ZLSwipeableView: UIView {

    // MARK: Data Source
    public var numberOfActiveView = UInt(4)
    public var nextView: NextViewHandler? {
        didSet {
            loadViews()
        }
    }
    public var previousView: PreviousViewHandler?
    // Rewinding
    public var history = [UIView]()
    public var numberOfHistoryItem = UInt(10)

    // MARK: Customizable behavior
    public var animateView = ZLSwipeableView.defaultAnimateViewHandler()
    public var interpretDirection = ZLSwipeableView.defaultInterpretDirectionHandler()
    public var shouldSwipeView = ZLSwipeableView.defaultShouldSwipeViewHandler()
    public var minTranslationInPercent = CGFloat(0.25)
    public var minVelocityInPointPerSecond = CGFloat(750)
    public var allowedDirection = Direction.Horizontal
    public var onlySwipeTopCard = false

    // MARK: Delegate
    public var didStart: DidStartHandler?
    public var swiping: SwipingHandler?
    public var didEnd: DidEndHandler?
    public var didSwipe: DidSwipeHandler?
    public var didCancel: DidCancelHandler?
    public var didTap: DidTap?
    public var didDisappear: DidDisappear?

    // MARK: Private properties
    /// Contains subviews added by the user.
    private var containerView = UIView()

    /// Contains auxiliary subviews.
    private var miscContainerView = UIView()

    private var animator: UIDynamicAnimator!

    private var viewManagers = [UIView: ViewManager]()

    private var scheduler = Scheduler()

    // MARK: Life cycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        addSubview(containerView)
        addSubview(miscContainerView)
        animator = UIDynamicAnimator(referenceView: self)
    }

    deinit {
        nextView = nil

        didStart = nil
        swiping = nil
        didEnd = nil
        didSwipe = nil
        didCancel = nil
        didDisappear = nil
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = bounds
    }

    // MARK: Public APIs
    public func topView() -> UIView? {
        return activeViews().first
    }

    // top view first
    public func activeViews() -> [UIView] {
        return allViews().filter() {
            view in
            guard let viewManager = viewManagers[view] else { return false }
            if case .Swiping(_) = viewManager.state {
                return false
            }
            return true
        }.reverse()
    }

    public func loadViews() {
        for _ in UInt(activeViews().count) ..< numberOfActiveView {
            if let nextView = nextView?() {
                insert(nextView, atIndex: 0)
            }
        }
        updateViews()
    }

    public func rewind() {
        var viewToBeRewinded: UIView?
        if let lastSwipedView = history.popLast() {
            viewToBeRewinded = lastSwipedView
        } else if let view = previousView?() {
            viewToBeRewinded = view
        }

        guard let view = viewToBeRewinded else { return }

        insert(view, atIndex: allViews().count)
        updateViews()
    }

    public func discardViews() {
        for view in allViews() {
            remove(view)
        }
    }

    public func swipeTopView(inDirection direction: Direction) {
        guard let topView = topView() else { return }
        let (location, directionVector) = interpretDirection(topView: topView, direction: direction, views: activeViews(), swipeableView: self)
        swipeTopView(fromPoint: location, inDirection: directionVector)
    }

    public func swipeTopView(fromPoint location: CGPoint, inDirection directionVector: CGVector) {
        guard let topView = topView(), topViewManager = viewManagers[topView] else { return }
        topViewManager.state = .Swiping(location, directionVector)
        swipeView(topView, location: location, directionVector: directionVector)
    }

    // MARK: Private APIs
    private func allViews() -> [UIView] {
        return containerView.subviews
    }

    private func insert(view: UIView, atIndex index: Int) {
        guard !allViews().contains(view) else {
            // this view has been schedule to be removed
            guard let viewManager = viewManagers[view] else { return }
            viewManager.state = viewManager.snappingStateAtContainerCenter()
            return
        }

        let viewManager = ViewManager(view: view, containerView: containerView, index: index, miscContainerView: miscContainerView, animator: animator, swipeableView: self)
        viewManagers[view] = viewManager
    }

    private func remove(view: UIView) {
        guard allViews().contains(view) else { return }

        viewManagers.removeValueForKey(view)
        self.didDisappear?(view: view)
    }

    public func updateViews() {
        let activeViews = self.activeViews()
        let inactiveViews = allViews().arrayByRemoveObjectsInArray(activeViews)

        for view in inactiveViews {
            view.userInteractionEnabled = false
        }

        guard let gestureRecognizers = activeViews.first?.gestureRecognizers where gestureRecognizers.filter({ gestureRecognizer in gestureRecognizer.state != .Possible }).count == 0 else { return }

        for i in 0 ..< activeViews.count {
            let view = activeViews[i]
            view.userInteractionEnabled = onlySwipeTopCard ? i == 0 : true
            let shouldBeHidden = i >= Int(numberOfActiveView)
            view.hidden = shouldBeHidden
            guard !shouldBeHidden else { continue }
            animateView(view: view, index: i, views: activeViews, swipeableView: self)
        }
    }

    func swipeView(view: UIView, location: CGPoint, directionVector: CGVector) {
        let direction = Direction.fromPoint(CGPoint(x: directionVector.dx, y: directionVector.dy))

        scheduleToBeRemoved(view) { aView in
            !CGRectIntersectsRect(self.containerView.convertRect(aView.frame, toView: nil), UIScreen.mainScreen().bounds)
        }
        didSwipe?(view: view, inDirection: direction, directionVector: directionVector)
        loadViews()
    }

    func scheduleToBeRemoved(view: UIView, withPredicate predicate: (UIView) -> Bool) {
        guard allViews().contains(view) else { return }

        history.append(view)
        if UInt(history.count) > numberOfHistoryItem {
            history.removeFirst()
        }
        scheduler.scheduleRepeatedly({ () -> Void in
            self.allViews().arrayByRemoveObjectsInArray(self.activeViews()).filter({ view in predicate(view) }).forEach({ view in self.remove(view) })
            }, interval: 0.3) { () -> Bool in
                return self.activeViews().count == self.allViews().count
        }
    }

}

// MARK: - Default behaviors
extension ZLSwipeableView {

    static func defaultAnimateViewHandler() -> AnimateViewHandler {
        func toRadian(degree: CGFloat) -> CGFloat {
            return degree * CGFloat(M_PI / 180)
        }

        func rotateView(view: UIView, forDegree degree: CGFloat, duration: NSTimeInterval, offsetFromCenter offset: CGPoint, swipeableView: ZLSwipeableView,  completion: ((Bool) -> Void)? = nil) {
            UIView.animateWithDuration(duration, delay: 0, options: .AllowUserInteraction, animations: {
                view.center = swipeableView.convertPoint(swipeableView.center, fromView: swipeableView.superview)
                var transform = CGAffineTransformMakeTranslation(offset.x, offset.y)
                transform = CGAffineTransformRotate(transform, toRadian(degree))
                transform = CGAffineTransformTranslate(transform, -offset.x, -offset.y)
                view.transform = transform
                },
                completion: completion)
        }

        return { (view: UIView, index: Int, views: [UIView], swipeableView: ZLSwipeableView) in
            let degree = CGFloat(1)
            let duration = 0.4
            let offset = CGPoint(x: 0, y: CGRectGetHeight(swipeableView.bounds) * 0.3)
            switch index {
            case 0:
                rotateView(view, forDegree: 0, duration: duration, offsetFromCenter: offset, swipeableView: swipeableView)
            case 1:
                rotateView(view, forDegree: degree, duration: duration, offsetFromCenter: offset, swipeableView: swipeableView)
            case 2:
                rotateView(view, forDegree: -degree, duration: duration, offsetFromCenter: offset, swipeableView: swipeableView)
            default:
                rotateView(view, forDegree: 0, duration: duration, offsetFromCenter: offset, swipeableView: swipeableView)
            }
        }
    }

    static func defaultInterpretDirectionHandler() -> InterpretDirectionHandler {
        return { (topView: UIView, direction: Direction, views: [UIView], swipeableView: ZLSwipeableView) in
            let programmaticSwipeVelocity = CGFloat(1000)
            let location = CGPoint(x: topView.center.x, y: topView.center.y*0.7)
            var directionVector: CGVector!

            switch direction {
            case Direction.Left:
                directionVector = CGVector(dx: -programmaticSwipeVelocity, dy: 0)
            case Direction.Right:
                directionVector = CGVector(dx: programmaticSwipeVelocity, dy: 0)
            case Direction.Up:
                directionVector = CGVector(dx: 0, dy: -programmaticSwipeVelocity)
            case Direction.Down:
                directionVector = CGVector(dx: 0, dy: programmaticSwipeVelocity)
            default:
                directionVector = CGVector(dx: 0, dy: 0)
            }
            
            return (location, directionVector)
        }
    }

    static func defaultShouldSwipeViewHandler() -> ShouldSwipeHandler {
        return { (view: UIView, movement: Movement, swipeableView: ZLSwipeableView) -> Bool in
            let translation = movement.translation
            let velocity = movement.velocity
            let bounds = swipeableView.bounds
            let minTranslationInPercent = swipeableView.minTranslationInPercent
            let minVelocityInPointPerSecond = swipeableView.minVelocityInPointPerSecond
            let allowedDirection = swipeableView.allowedDirection

            func areTranslationAndVelocityInTheSameDirection() -> Bool {
                return CGPoint.areInSameTheDirection(translation, p2: velocity)
            }

            func isDirectionAllowed() -> Bool {
                return Direction.fromPoint(translation).intersect(allowedDirection) != .None
            }

            func isTranslationLargeEnough() -> Bool {
                return abs(translation.x) > minTranslationInPercent * bounds.width || abs(translation.y) > minTranslationInPercent * bounds.height
            }

            func isVelocityLargeEnough() -> Bool {
                return velocity.magnitude > minVelocityInPointPerSecond
            }

            return isDirectionAllowed() && areTranslationAndVelocityInTheSameDirection() && (isTranslationLargeEnough() || isVelocityLargeEnough())
        }
    }

}

// MARK: - Deprecated APIs
extension ZLSwipeableView {

    @available(*, deprecated=1, message="Use numberOfActiveView")
    public var numPrefetchedViews: UInt {
        get {
            return numberOfActiveView
        }
        set(newValue){
            numberOfActiveView = newValue
        }
    }

    @available(*, deprecated=1, message="Use allowedDirection")
    public var direction: Direction {
        get {
            return allowedDirection
        }
        set(newValue){
            allowedDirection = newValue
        }
    }

    @available(*, deprecated=1, message="Use minTranslationInPercent")
    public var translationThreshold: CGFloat {
        get {
            return minTranslationInPercent
        }
        set(newValue){
            minTranslationInPercent = newValue
        }
    }

    @available(*, deprecated=1, message="Use minVelocityInPointPerSecond")
    public var velocityThreshold: CGFloat {
        get {
            return minVelocityInPointPerSecond
        }
        set(newValue){
            minVelocityInPointPerSecond = newValue
        }
    }
    
}

// MARK: - Helper extensions
public func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}

extension CGPoint {

    init(vector: CGVector) {
        self.init(x: vector.dx, y: vector.dy)
    }

    var normalized: CGPoint {
        return CGPoint(x: x / magnitude, y: y / magnitude)
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

extension CGVector {

    init(point: CGPoint) {
        self.init(dx: point.x, dy: point.y)
    }

}

extension Array where Element: Equatable {

    func arrayByRemoveObjectsInArray(array: [Element]) -> [Element] {
        return Array(self).filter() { element in !array.contains(element) }
    }

}
