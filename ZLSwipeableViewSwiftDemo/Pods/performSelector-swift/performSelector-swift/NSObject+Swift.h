//
//  UIResponder+Swift.h
//
//  Created by ToKoRo on 2014-07-18.
//

#import <Foundation/Foundation.h>

@interface NSObject (Swift)

- (id)swift_performSelector:(SEL)selector withObject:(id)object;
- (void)swift_performSelector:(SEL)selector withObject:(id)object afterDelay:(NSTimeInterval)delay;

@end
