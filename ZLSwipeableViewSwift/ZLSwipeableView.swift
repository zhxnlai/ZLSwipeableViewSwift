//
//  ZLSwipeableView.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 4/27/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

// MARK: - Helper classes
public typealias ZLSwipeableViewDirection = Direction

public func ==(lhs: Direction, rhs: Direction) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

/**
*  Swiped direction.
*/
public struct Direction : OptionSetType, CustomStringConvertible {

    public var rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public static let None = Direction(rawValue: 0b0000)
    public static let Left = Direction(rawValue: 0b0001)
    public static let Right = Direction(rawValue: 0b0010)
    public static let Up = Direction(rawValue: 0b0100)
    public static let Down = Direction(rawValue: 0b1000)
    public static let Horizontal: Direction = [Left, Right]
    public static let Vertical: Direction = [Up, Down]
    public static let All: Direction = [Horizontal, Vertical]

    public static func fromPoint(point: CGPoint) -> Direction {
        switch (point.x, point.y) {
        case let (x, y) where abs(x) >= abs(y) && x > 0:
            return .Right
        case let (x, y) where abs(x) >= abs(y) && x < 0:
            return .Left
        case let (x, y) where abs(x) < abs(y) && y < 0:
            return .Up
        case let (x, y) where abs(x) < abs(y) && y > 0:
            return .Down
        case (_, _):
            return .None
        }
    }

    public var description: String {
        switch self {
        case Direction.None:
            return "None"
        case Direction.Left:
            return "Left"
        case Direction.Right:
            return "Right"
        case Direction.Up:
            return "Up"
        case Direction.Down:
            return "Down"
        case Direction.Horizontal:
            return "Horizontal"
        case Direction.Vertical:
            return "Vertical"
        case Direction.All:
            return "All"
        default:
            return "Unknown"
        }
    }

}

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

    // MARK: Delegate
    public var didStart: DidStartHandler?
    public var swiping: SwipingHandler?
    public var didEnd: DidEndHandler?
    public var didSwipe: DidSwipeHandler?
    public var didCancel: DidCancelHandler?

    // MARK: Private properties
    /// Contains subviews added by the user.
    private var containerView = UIView()

    /// Contains auxiliary subviews.
    private var miscContainerView = UIView()

    private var animator: UIDynamicAnimator!

    private var viewManagers = [UIView: ViewManager]()

    private var scheduler = Scheduler()

    // MARK: Life cycle
    override init(frame: CGRect) {
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
        for var i = UInt(activeViews().count); i < numberOfActiveView; i++ {
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
            view.userInteractionEnabled = true
            let shouldBeHidden = i >= Int(numberOfActiveView)
            view.hidden = shouldBeHidden
            guard !shouldBeHidden else { continue }
            animateView(view: view, index: i, views: activeViews, swipeableView: self)
        }
    }

    private func swipeView(view: UIView, location: CGPoint, directionVector: CGVector) {
        let direction = Direction.fromPoint(CGPoint(x: directionVector.dx, y: directionVector.dy))

        scheduleToBeRemoved(view) { aView in
            !CGRectIntersectsRect(self.containerView.convertRect(aView.frame, toView: nil), UIScreen.mainScreen().bounds)
        }
        didSwipe?(view: view, inDirection: direction, directionVector: directionVector)
        loadViews()
    }

    private func scheduleToBeRemoved(view: UIView, withPredicate predicate: (UIView) -> Bool) {
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

// MARK: - Internal classes
internal class ViewManager : NSObject {

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

        view.addGestureRecognizer(ZLPanGestureRecognizer(target: self, action: Selector("handlePan:")))
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

internal class Scheduler : NSObject {

    typealias Action = () -> Void
    typealias EndCondition = () -> Bool

    var timer: NSTimer?
    var action: Action?
    var endCondition: EndCondition?

    func scheduleRepeatedly(action: Action, interval: NSTimeInterval, endCondition: EndCondition)  {
        guard timer == nil && interval > 0 else { return }
        self.action = action
        self.endCondition = endCondition
        timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("doAction:"), userInfo: nil, repeats: true)
    }

    func doAction(timer: NSTimer) {
        guard let action = action, let endCondition = endCondition where !endCondition() else {
            timer.invalidate()
            self.timer = nil
            return
        }
        action()
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
