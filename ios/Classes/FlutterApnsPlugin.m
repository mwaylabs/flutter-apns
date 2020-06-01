#import "FlutterApnsPlugin.h"
#import <objc/runtime.h>
#import <UserNotifications/UserNotifications.h>

static FlutterError *getFlutterError(NSError *error) {
  if (error == nil) return nil;
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %ld", (long)error.code]
                             message:error.domain
                             details:error.localizedDescription];
}

@interface FlutterApnsPlugin () <UNUserNotificationCenterDelegate>
@end

@implementation FlutterApnsPlugin {
    FlutterMethodChannel *_channel;
    NSDictionary *_launchNotification;
    BOOL _resumingFromBackground;
}

+ (void)apns_registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    // disabling FLTFirebaseMessagingPlugin
}

+ (void)load {
    Class c = NSClassFromString(@"FLTFirebaseMessagingPlugin");
    
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
        method_exchangeImplementations(origMethod, newMethod);
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel =
    [FlutterMethodChannel methodChannelWithName:@"flutter_apns"
                                binaryMessenger:[registrar messenger]];
    id instance = [[FlutterApnsPlugin alloc] initWithChannel:channel];
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
    self = [super init];
    
    if (self) {
        _channel = channel;
        _resumingFromBackground = NO;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *method = call.method;
    if ([@"requestNotificationPermissions" isEqualToString:method]) {
        NSDictionary *arguments = call.arguments;
           if (@available(iOS 10.0, *)) {
#if DEBUG
               if ([UNUserNotificationCenter currentNotificationCenter].delegate == nil) {
                   result([FlutterError errorWithCode:@"flutter_apns_delegate"
                                              message:@"UNUserNotificationCenterDelegate is not set. Check README of flutter_apns. This is debug only error."
                                              details:nil]);
                   return;
               }
#endif

               
             UNAuthorizationOptions authOptions = 0;
             NSNumber *provisional = arguments[@"provisional"];
             if ([arguments[@"sound"] boolValue]) {
               authOptions |= UNAuthorizationOptionSound;
             }
             if ([arguments[@"alert"] boolValue]) {
               authOptions |= UNAuthorizationOptionAlert;
             }
             if ([arguments[@"badge"] boolValue]) {
               authOptions |= UNAuthorizationOptionBadge;
             }

             NSNumber *isAtLeastVersion12;
             if (@available(iOS 12, *)) {
               isAtLeastVersion12 = [NSNumber numberWithBool:YES];
               if ([provisional boolValue]) authOptions |= UNAuthorizationOptionProvisional;
             } else {
               isAtLeastVersion12 = [NSNumber numberWithBool:NO];
             }

             [[UNUserNotificationCenter currentNotificationCenter]
                 requestAuthorizationWithOptions:authOptions
                               completionHandler:^(BOOL granted, NSError *_Nullable error) {
                                 if (error) {
                                   result(getFlutterError(error));
                                   return;
                                 }
                                 // This works for iOS >= 10. See
                                 // [UIApplication:didRegisterUserNotificationSettings:notificationSettings]
                                 // for ios < 10.
                                 [[UNUserNotificationCenter currentNotificationCenter]
                                     getNotificationSettingsWithCompletionHandler:^(
                                         UNNotificationSettings *_Nonnull settings) {
                                       NSDictionary *settingsDictionary = @{
                                         @"sound" : [NSNumber numberWithBool:settings.soundSetting ==
                                                                             UNNotificationSettingEnabled],
                                         @"badge" : [NSNumber numberWithBool:settings.badgeSetting ==
                                                                             UNNotificationSettingEnabled],
                                         @"alert" : [NSNumber numberWithBool:settings.alertSetting ==
                                                                             UNNotificationSettingEnabled],
                                         @"provisional" :
                                             [NSNumber numberWithBool:granted && [provisional boolValue] &&
                                                                      isAtLeastVersion12],
                                       };
                                       [self->_channel invokeMethod:@"onIosSettingsRegistered"
                                                          arguments:settingsDictionary];
                                     }];
                                 result([NSNumber numberWithBool:granted]);
                               }];

             [[UIApplication sharedApplication] registerForRemoteNotifications];
           } else {
             UIUserNotificationType notificationTypes = 0;
             if ([arguments[@"sound"] boolValue]) {
               notificationTypes |= UIUserNotificationTypeSound;
             }
             if ([arguments[@"alert"] boolValue]) {
               notificationTypes |= UIUserNotificationTypeAlert;
             }
             if ([arguments[@"badge"] boolValue]) {
               notificationTypes |= UIUserNotificationTypeBadge;
             }

             UIUserNotificationSettings *settings =
                 [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
             [[UIApplication sharedApplication] registerUserNotificationSettings:settings];

             [[UIApplication sharedApplication] registerForRemoteNotifications];
             result([NSNumber numberWithBool:YES]);
           }
    } else if ([@"configure" isEqualToString:method]) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        if (_launchNotification != nil) {
            [_channel invokeMethod:@"onLaunch" arguments:_launchNotification];
        }
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (_resumingFromBackground) {
        [_channel invokeMethod:@"onResume" arguments:userInfo];
    } else {
        [_channel invokeMethod:@"onMessage" arguments:userInfo];
    }
}

- (NSString *)stringWithDeviceToken:(NSData *)deviceToken {
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];

    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }

    return [token copy];
}

#pragma mark - AppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (launchOptions != nil) {
        _launchNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    }
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    _resumingFromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    _resumingFromBackground = NO;
    // Clears push notifications from the notification center, with the
    // side effect of resetting the badge count. We need to clear notifications
    // because otherwise the user could tap notifications in the notification
    // center while the app is in the foreground, and we wouldn't be able to
    // distinguish that case from the case where a message came in and the
    // user dismissed the notification center without tapping anything.
    // TODO(goderbauer): Revisit this behavior once we provide an API for managing
    // the badge number, or if we add support for running Dart in the background.
    // Setting badgeNumber to 0 is a no-op (= notifications will not be cleared)
    // if it is already 0,
    // therefore the next line is setting it to 1 first before clearing it again
    // to remove all
    // notifications.
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;
}

- (bool)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    [self didReceiveRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNoData);
    return YES;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString * token = [self stringWithDeviceToken:deviceToken];
    [_channel invokeMethod:@"onToken" arguments:token];
}

- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSDictionary *settingsDictionary = @{
                                         @"sound" : [NSNumber numberWithBool:notificationSettings.types & UIUserNotificationTypeSound],
                                         @"badge" : [NSNumber numberWithBool:notificationSettings.types & UIUserNotificationTypeBadge],
                                         @"alert" : [NSNumber numberWithBool:notificationSettings.types & UIUserNotificationTypeAlert],
                                         };
    [_channel invokeMethod:@"onIosSettingsRegistered" arguments:settingsDictionary];
}

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

// Received data message on iOS 10 devices while app is in the foreground.
// Only invoked if method swizzling is disabled and UNUserNotificationCenterDelegate has been
// registered in AppDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
    NS_AVAILABLE_IOS(10.0) {
  NSDictionary *userInfo = notification.request.content.userInfo;
  // Check to key to ensure we only handle messages from aps
  if (userInfo[@"aps"]) {
    [_channel invokeMethod:@"onMessage" arguments:userInfo];
    completionHandler(UNNotificationPresentationOptionNone);
  }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
    didReceiveNotificationResponse:(UNNotificationResponse *)response
             withCompletionHandler:(void (^)(void))completionHandler NS_AVAILABLE_IOS(10.0) {
  NSDictionary *userInfo = response.notification.request.content.userInfo;
  // Check to key to ensure we only handle messages from aps
  if (userInfo[@"aps"]) {
    [_channel invokeMethod:@"onResume" arguments:userInfo];
    completionHandler();
  }
}

#endif

@end
