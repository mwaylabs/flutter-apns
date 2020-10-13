#import "FlutterApnsSwizzler.h"
#import <objc/runtime.h>
#import <Flutter/Flutter.h>

static int swizzleCounter;

@interface FlutterApnsSwizzler ()
@end

@implementation FlutterApnsSwizzler

+ (BOOL)didSwizzle {
    return swizzleCounter == 2;
}

+ (void)apns_registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    swizzleCounter++;
}

+ (void)disablePluginNamed:(NSString *)name {
    Class c = NSClassFromString(name);
    
    if (!c) {
        return;
    }
    
    SEL orig = @selector(registerWithRegistrar:);
    SEL new = @selector(apns_registerWithRegistrar:);
    
    Method origMethod = class_getClassMethod(c, orig);
    Method newMethod = class_getClassMethod(self, new);
    
    c = object_getClass((id)c);
    
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_setImplementation(origMethod, method_getImplementation(newMethod));
}

+ (void)load {
    [self disablePluginNamed:@"FLTFirebaseCorePlugin"];
    [self disablePluginNamed:@"FLTFirebaseMessagingPlugin"];
}

@end
