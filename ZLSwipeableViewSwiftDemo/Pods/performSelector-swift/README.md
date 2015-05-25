# performSelector-swift

## Usage

- performSelector:withObject:

```swift
let ret: AnyObject! = self.swift_performSelector("say:", withObject: "hello")
println("ret = \(ret)");
```

- performSelector:withObject:afterDelay:

```swift
self.swift_performSelector("say:", withObject: "hello", afterDelay: 3.0)
```

## Sample Code

- [Example](https://github.com/tokorom/performSelector-swift/tree/master/Example)

## Setup

### Using CocoaPods

```ruby
// Podfile
pod 'performSelector-swift'
```

and

```shell
pod install
```

and

```objective-c
// YOur Bridging-Header.h
#import "performSelector-swift.h"
```


