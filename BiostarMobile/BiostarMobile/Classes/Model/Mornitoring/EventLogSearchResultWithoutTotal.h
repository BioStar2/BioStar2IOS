//
//  EventLogSearchResultWithoutTotal.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 10..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "Response.h"
#import "EventLogResult.h"

@interface EventLogSearchResultWithoutTotal : Response


@property (nonatomic, assign) BOOL is_next;
@property (nonatomic, strong) NSArray <EventLogResult*> *records;



@end
