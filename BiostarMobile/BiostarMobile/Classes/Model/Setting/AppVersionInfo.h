//
//  AppVersionInfo.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 1..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppVersionInfo : NSObject

@property (nonatomic, strong) NSString *app_store_download_url;
@property (nonatomic, strong) NSString *direct_download_url;
@property (nonatomic, strong) NSString *force_update_version;
@property (nonatomic, strong) NSString *latest_version;
@property (nonatomic, strong) NSString *mobile_device_type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *version_message;


@end
