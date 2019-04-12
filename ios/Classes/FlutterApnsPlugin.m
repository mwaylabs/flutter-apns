#import "FlutterApnsPlugin.h"

@implementation FlutterApnsPlugin {
    FlutterMethodChannel *_channel;
    NSDictionary *_launchNotification;
    BOOL _resumingFromBackground;
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
        UIUserNotificationType notificationTypes = 0;
        NSDictionary *arguments = call.arguments;
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
        
        result(nil);
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
    NSString * token = [[[[deviceToken description]
                          stringByReplacingOccurrencesOfString: @"<" withString: @""]
                         stringByReplacingOccurrencesOfString: @">" withString: @""]
                        stringByReplacingOccurrencesOfString: @" " withString: @""];
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

@end
