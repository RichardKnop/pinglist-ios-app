//
//  AppDelegate.m
//  Pinglist
//
//  Created by admin on 5/2/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "AppDelegate.h"
#import "Global.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  UIStoryboard *storyboard = [Global getStoryboard];

  self.window.rootViewController =
      [storyboard instantiateInitialViewController];
  [self.window makeKeyAndVisible];

  [Global sharedInstance].credential =
      [AFOAuthCredential retrieveCredentialWithIdentifier:@"credential"];

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [Global sharedInstance].accessToken = [defaults objectForKey:@"accessToken"];
  [Global sharedInstance].refreshToken =
      [defaults objectForKey:@"refreshToken"];

  [[FBSDKApplicationDelegate sharedInstance] application:application
                           didFinishLaunchingWithOptions:launchOptions];

  if ([[UIApplication sharedApplication]
          respondsToSelector:@selector(registerUserNotificationSettings:)]) {
    // iOS 9
    UIUserNotificationSettings *notificationSettings =
        [UIUserNotificationSettings
            settingsForTypes:(UIUserNotificationTypeAlert |
                              UIUserNotificationTypeBadge |
                              UIUserNotificationTypeSound)
                  categories:nil];
    [[UIApplication sharedApplication]
        registerUserNotificationSettings:notificationSettings];
  } else {
    // iOS < 9
    [[UIApplication sharedApplication]
        registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |
                                            UIRemoteNotificationTypeSound |
                                            UIRemoteNotificationTypeBadge)];
  }

  return YES;
}

- (void)application:(UIApplication *)application
    didRegisterUserNotificationSettings:
        (UIUserNotificationSettings *)notificationSettings {
  if (notificationSettings.types != UIUserNotificationTypeNone) {
    NSLog(@"didRegisterUser");
    [application registerForRemoteNotifications];
  }
}

- (void)application:(UIApplication *)application
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  NSLog(@"error here : %@", error); // not called
}

- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

  NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
  // Format token as you need:
  token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
  token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
  token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];

  [Global sharedInstance].deviceToken = token;
  NSLog(@"%@", token);

  if ([Global sharedInstance].accessToken != nil) {
    NSString *requestURL =
        [NSString stringWithFormat:@"%@/v1/devices", endpointURL];
    NSDictionary *params = @{
      @"platform" : @"iOS",
      @"token" : [Global sharedInstance].deviceToken
    };

    [[Global afManager] POST:requestURL
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"register token success");
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          [SVProgressHUD showErrorWithStatus:operation.responseString
                                    maskType:SVProgressHUDMaskTypeClear];
        }];
  }
}

- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo {
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
  BOOL handled =
      [[FBSDKApplicationDelegate sharedInstance] application:application
                                                     openURL:url
                                           sourceApplication:sourceApplication
                                                  annotation:annotation];
  // Add any custom logic here.
  return handled;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state.
  // This can occur for certain types of temporary interruptions (such as an
  // incoming phone call or SMS message) or when the user quits the application
  // and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down
  // OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate
  // timers, and store enough application state information to restore your
  // application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called
  // instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state;
  // here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if
  // appropriate. See also applicationDidEnterBackground:.
}

@end
