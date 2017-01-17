//
//  LocalDataManager.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 5..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "LocalDataManager.h"

@implementation LocalDataManager

+ (void)checkFirstAppLaunch
{
    // 환경설정 초기 셋팅값
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"UserCount"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"DoorCount"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)deleteLocalCookies
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"hasCookie"];
    
    NSHTTPCookieStorage * sharedCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray * cookies = [sharedCookieStorage cookies];
    for (NSHTTPCookie * cookie in cookies)
    {
        NSLog(@"%@",cookie.domain);
        NSLog(@"cookie : %@", cookie);
        [sharedCookieStorage deleteCookie:cookie];
    }
    
    [userDefaults synchronize];
}

+ (void)storeLocalCookies:(NSArray*)cookies URL:(NSURL *)URL
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *serverDomain = [userDefaults objectForKey:@"ServerAddress"];
    if ([serverDomain rangeOfString:@"https://"].location != NSNotFound)
    {
        serverDomain = [serverDomain substringFromIndex:8];
    }
    else if([serverDomain rangeOfString:@"http://"].location != NSNotFound)
    {
        serverDomain = [serverDomain substringFromIndex:7];
    }
    
    // 쿠키 저장하기
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:URL mainDocumentURL:[NSURL URLWithString:serverDomain]];
    
    [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"hasCookie"];
    [userDefaults synchronize];
}

+ (BOOL)hasStoredCooikes
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL hasCookie = [[userDefaults objectForKey:@"hasCookie"] boolValue];
    return hasCookie;
}

+ (NSInteger)getUserCount
{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userCount = [[userdefaults objectForKey:@"UserCount"] integerValue];
    
    return userCount;
}

+ (void)setUserCount:(NSInteger)userCount
{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:[NSNumber numberWithInteger:userCount]
                                              forKey:@"UserCount"];
    [userdefaults synchronize];
}


+ (NSInteger)getDoorCount
{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    return [[userdefaults objectForKey:@"DoorCount"] integerValue];
}


+ (void)setDoorCount:(NSInteger)userCount
{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:userCount]
                                              forKey:@"UserCount"];
    [userdefaults synchronize];
}

+ (NSString*)getServerAddress
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"ServerAddress"];
}

+ (void)setServerAddress:(NSString*)serverAddress
{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] setObject:serverAddress
                                              forKey:@"ServerAddress"];
    [userdefaults synchronize];
}


+ (NSString*)getName
{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    return [userdefaults objectForKey:@"Name"];
}


+ (void)setName:(NSString*)name
{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:name forKey:@"Name"];
    [userdefaults synchronize];
}

+ (NSString*)getUserLoginID
{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    return [userdefaults objectForKey:@"userID"];
}


+ (void)setUserLoginID:(NSString*)loginID;
{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:loginID forKey:@"userID"];
    [userdefaults synchronize];
}

+ (void)setBiostarACVersion:(NSString*)version
{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:version forKey:@"ACVersion"];
    [userdefaults synchronize];
}


+ (NSString*)getBiostarACVersion
{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    return [userdefaults objectForKey:@"ACVersion"];
}
@end
