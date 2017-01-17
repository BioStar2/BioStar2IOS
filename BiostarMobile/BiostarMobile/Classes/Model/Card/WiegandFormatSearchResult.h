//
//  WiegandFormatSearchResult.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 1..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "Response.h"
#import "WiegandFormat.h"

@interface WiegandFormatSearchResult : Response

@property (nonatomic, strong) NSArray <WiegandFormat*> *records;
@property (nonatomic, assign) NSInteger total;

@end
