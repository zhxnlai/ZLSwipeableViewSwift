//
//  UIResponder+Swift.m
//
//  Created by ToKoRo on 2014-07-18.
//

#import "NSObject+Swift.h"

@implementation NSObject (Swift)
    
- (id)swift_performSelector:(SEL)selector withObject:(id)object
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [self performSelector:selector withObject:object];
#pragma clang diagnostic pop
}

- (void)swift_performSelector:(SEL)selector withObject:(id)object afterDelay:(NSTimeInterval)delay
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [self performSelector:selector withObject:object afterDelay:delay];
#pragma clang diagnostic pop
}

@end
