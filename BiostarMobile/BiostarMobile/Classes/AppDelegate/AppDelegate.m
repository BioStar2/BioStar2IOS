/*
 * Copyright 2015 Suprema(biostar2@suprema.co.kr)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AppDelegate.h"
#import "SDImageCache.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[SDImageCache sharedImageCache] clearDisk];
    
    // 환경설정 초기 셋팅값
    [LocalDataManager checkFirstAppLaunch];

    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              // Enable or disable features based on authorization.
                              if(!error && granted){
                                  
                              }
                          }];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
//    UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:
//                                           UIUserNotificationTypeSound | UIUserNotificationTypeAlert
//                                                                            categories:nil];
//    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    
    // Add registration for remote notifications
    
    //[LocalDataManager deleteMobileCredential];
    
    return YES;
}


- (void)deleteCookies
{
//    NSLog(@"*******************************************");
//    NSLog(@"deleteCookies");
    NSHTTPCookieStorage * sharedCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray * cookies = [sharedCookieStorage cookies];
    
    for (NSHTTPCookie * cookie in cookies)
    {
//        NSLog(@"delete cookie domain : %@",cookie.domain);
//        NSLog(@"delete cookie : %@", cookie);
        [sharedCookieStorage deleteCookie:cookie];
        
    }
}

- (void)setCookies
{
//    NSLog(@"*******************************************");
//    NSLog(@"setCookies");
    NSHTTPCookieStorage * sharedCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    NSArray *cookies = [LocalDataManager getCookies];
    for (NSHTTPCookie * cookie in cookies)
    {
//        NSLog(@"setCookies cookie domain : %@",cookie.domain);
//        NSLog(@"setCookies : %@", cookie);
        [sharedCookieStorage setCookie:cookie];
    }
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    handler(UIBackgroundFetchResultNewData);
    NSLog(@"didReceiveRemoteNotification");
    [[NSNotificationCenter defaultCenter] postNotificationName:PUSH_HAS_BEEN_OCCURED object:userInfo];
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self deleteCookies];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:APP_DID_ENTER_BACKGROUND object:nil];
    
    [self deleteCookies];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[NSNotificationCenter defaultCenter] postNotificationName:APP_WILL_ENTER_FOREGROUND object:nil];
    [self setCookies];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self setCookies];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self deleteCookies];
}

//- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
//{
//    //register to receive notifications
//    [application registerForRemoteNotifications];
//}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *device = [deviceToken description];
    device = [device stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    device = [device stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"token : %@", device);
    [PreferenceProvider setDeviceToken:device];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"error : %@", [error localizedDescription]);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    
    NSLog(@"willPresentNotification : %@", notification.request.content.userInfo);
    [[NSNotificationCenter defaultCenter] postNotificationName:PUSH_HAS_BEEN_OCCURED object:notification.request.content.userInfo];
}

@end
