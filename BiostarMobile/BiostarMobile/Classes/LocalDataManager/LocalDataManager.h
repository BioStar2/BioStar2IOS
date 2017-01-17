//
//  LocalDataManager.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 5..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalDataManager : NSObject

+ (void)checkFirstAppLaunch;

+ (void)deleteLocalCookies;

+ (void)storeLocalCookies:(NSArray*)cookies URL:(NSURL *)URL;

+ (BOOL)hasStoredCooikes;

+ (NSInteger)getUserCount;

+ (void)setUserCount:(NSInteger)userCount;

+ (NSInteger)getDoorCount;

+ (void)setDoorCount:(NSInteger)userCount;

+ (NSString*)getServerAddress;

+ (void)setServerAddress:(NSString*)serverAddress;

+ (NSString*)getName;

+ (void)setName:(NSString*)name;

+ (NSString*)getUserLoginID;

+ (void)setUserLoginID:(NSString*)loginID;

+ (void)setBiostarACVersion:(NSString*)version;

+ (NSString*)getBiostarACVersion;
@end
