KKSwizzler
==========

Ad hoc swizzling for debugging purposes

I created this class to analyze class relations in Xcode for a plugin I'm working on. It seemed to be pretty useful, so I decided to publish it as a separate repository.

It's most useful for debugging and code analysis. It makes it a lot easier and faster to manage ad hoc swizzled methods.

To use it you have to add a method following a simple naming pattern. Swizzled methods have to start with swizzle$&lt;classname&gt;$ after which follows the method's name. Both instance and class methods are supported.

Usage examples
--------------

    #pragma mark - Swizzled methods
    
    // Rejects notifications which names start with XYZ
    - (void)swizzle$NSNotificationCenter$postNotification:(NSNotification *)notification
    {
        if ([notification.name hasPrefix:@"XYZ"]) {
            return;
        }
    
        [self swizzle$NSNotificationCenter$postNotification:notification];
    }

    // Logs names of alloced classes if they start with IDE
    + (id)swizzle$NSObject$alloc
    {
        if ([NSStringFromClass([self class]) hasPrefix:@"IDE"]) {
            NSLog(@"%@", [self class]);
        }
    
        return [self swizzle$NSObject$alloc];
    }
