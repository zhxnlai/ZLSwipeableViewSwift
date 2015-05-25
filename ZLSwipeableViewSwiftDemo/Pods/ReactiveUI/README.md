# Reactive UI
A lightweight replacement for target action with closures, modified from [Scream.swift](https://github.com/tangplin/Scream.swift).

Why?
---

In UIKit, [Target-Action](https://developer.apple.com/library/ios/documentation/General/Conceptual/CocoaEncyclopedia/Target-Action/Target-Action.html) has been the default way to handle control events until the arrival of iOS 8 when [UIAlertController](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIAlertController_class/) introduces closure handler in [UIAlertAction](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIAlertAction_Class/index.html#//apple_ref/swift/cl/UIAlertAction).

Closure handlers, in many cases, are more concise and readable than Target-Action. ReactiveUI follows this approach, wrapping existing Target-Action APIs
~~~swift
// UIControl
func addTarget(_ target: AnyObject?, action action: Selector, forControlEvents controlEvents: UIControlEvents)

// UIGestureRecognizer
init(target target: AnyObject, action action: Selector)

// ...
~~~
in closures
~~~swift
// UIControl
func addAction(action: UIControl -> (), forControlEvents events: UIControlEvents)

// UIGestureRecognizer
init(action: UIGestureRecognizer -> ())

// ...
~~~

With ReactiveUI, control events handling is much simpler:
~~~swift
var button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
button.setTitle("Title", forState: .Normal)
button.addAction({_ in println("TouchDown")}, forControlEvents: .TouchDown)
button.addAction({_ in println("TouchUpInside")}, forControlEvents: .TouchUpInside)
button.addAction({_ in println("TouchDragOutside")}, forControlEvents: .TouchDragOutside)
~~~

CocoaPods
---
You can install `ReactiveUI` through CocoaPods adding the following to your Podfile:

~~~ruby
pod 'ReactiveUI'
~~~

CocoaPods' support for swift is still pre-released, and requires your iOS deployment target to be [8.0 or later](https://github.com/CocoaPods/swift):
```bash
[sudo] gem install cocoapods --pre
```


Usage
---
Checkout the [demo app](https://github.com/zhxnlai/ReactiveUI/tree/master/ReactiveUIDemo) for an example.

[<img width="320 px" src="Previews/screenshot.png"/>](https://github.com/zhxnlai/ReactiveUI/tree/master/ReactiveUIDemo)

ReactiveUI currently supports the following classes:

###UIControl
~~~swift
init(action: UIControl -> (), forControlEvents events: UIControlEvents)
init(forControlEvents events: UIControlEvents, action: UIControl -> ())
func addAction(action: UIControl -> (), forControlEvents events: UIControlEvents)
// can be called with a trailing closure
func forControlEvents(events: UIControlEvents, addAction action: UIControl -> ())
func removeAction(forControlEvents events: UIControlEvents)
func actionForControlEvent(events: UIControlEvents) -> (UIControl -> ())?
var actions: [UIControl -> ()]
~~~
###UIBarButtonItem
~~~swift
init(barButtonSystemItem systemItem: UIBarButtonSystemItem, action: UIBarButtonItem -> ())
init(title: String?, style: UIBarButtonItemStyle, action: UIBarButtonItem -> ())
init(image: UIImage?, style: UIBarButtonItemStyle, action: UIBarButtonItem -> ())
init(image: UIImage?, landscapeImagePhone: UIImage?, style: UIBarButtonItemStyle, action: UIBarButtonItem -> ())
func addAction(action: UIBarButtonItem -> ())
func removeAction()
~~~
###UIGestureRecognizer
~~~swift
init(action: UIGestureRecognizer -> ())
func addAction(action: UIGestureRecognizer -> ())
func removeAction()
~~~
###NSTimer
~~~swift
class func scheduledTimerWithTimeInterval(seconds: NSTimeInterval, action: NSTimer -> (), repeats: Bool) -> NSTimer
~~~

License
---
ReactiveUI is available under MIT license. See the LICENSE file for more info.
