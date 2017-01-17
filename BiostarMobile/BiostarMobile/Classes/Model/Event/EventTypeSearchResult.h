//
//  EventTypeSearchResult.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 10..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "Response.h"
#import "EventType.h"

@interface EventTypeSearchResult : Response

@property (nonatomic, strong) NSArray <EventType*> *records;
@property (nonatomic, assign) NSInteger total;

@end
