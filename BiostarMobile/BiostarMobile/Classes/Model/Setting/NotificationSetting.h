//
//  NotificationSetting.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 1..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationSetting : NSObject

@property (nonatomic, strong) NSString *noti_description;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) BOOL subscribed;

@end
