//
//  KKSwizzler.m
//  KKSwizzler
//
//  Created by Karol Kozub on 2014-11-05.
//  Copyright (c) 2014 Karol Kozub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface KKSwizzler : NSObject
@end

@implementation KKSwizzler

+ (void)load
{
    [self swizzleMethodsWithIsInstance:YES];
    [self swizzleMethodsWithIsInstance:NO];
}

+ (void)swizzleMethodsWithIsInstance:(BOOL)isInstance
{
    Class sourceClass = isInstance ? self : object_getClass((id)self);
    unsigned int methodCount;
    Method *methods = class_copyMethodList(sourceClass, &methodCount);
    
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        NSString *methodName = NSStringFromSelector(method_getName(method));
        NSArray *components = [methodName componentsSeparatedByString:@"$"];
        
        if (![methodName hasPrefix:@"swizzle$"]) {
            continue;
        }
        
        if ([components count] != 3) {
            NSLog(@"KKSwizzler: Invalid swizzle method %@%@. Too many components.", isInstance ? @"-" : @"+", methodName);
            continue;
        }
        
        Class destinationClass = isInstance ? NSClassFromString(components[1]) : object_getClass((id)NSClassFromString(components[1]));
        NSString *destinationClassName = components[1];
        NSString *originalMethodName = components[2];
        NSString *swizzledMethodName = methodName;
        SEL originalSelector = NSSelectorFromString(originalMethodName);
        SEL swizzledSelector = NSSelectorFromString(swizzledMethodName);
        
        if (destinationClass == nil || originalSelector == nil || swizzledSelector == nil || !class_respondsToSelector(destinationClass, originalSelector)) {
            NSLog(@"KKSwizzler: Invalid swizzle method %@%@. Couldn't find class %@ or selector %@.", isInstance ? @"-" : @"+", swizzledMethodName, destinationClassName, originalMethodName);
            continue;
        }
        
        class_addMethod(destinationClass, swizzledSelector, method_getImplementation(method), method_getTypeEncoding(method));
        
        Method originalMethod = class_getInstanceMethod(destinationClass, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(destinationClass, swizzledSelector);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
        
        NSLog(@"KKSwizzler: Swizzled %@[%@ %@]", isInstance ? @"-" : @"+", NSStringFromClass(destinationClass), NSStringFromSelector(originalSelector));
    }
}

#pragma mark - Swizzled methods

@end
