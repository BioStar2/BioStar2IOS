//
//  NotificationSearchResult.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 10..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "Response.h"
#import "GetNotification.h"

@interface NotificationSearchResult : Response

@property (nonatomic, strong) NSArray <GetNotification*> *records;
@property (nonatomic, assign) NSInteger total;

@end
