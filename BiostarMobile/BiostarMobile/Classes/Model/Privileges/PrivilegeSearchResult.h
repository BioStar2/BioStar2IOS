//
//  PrivilegeSearchResult.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 23..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "Response.h"
#import "Permission.h"

@interface PrivilegeSearchResult : Response

@property (nonatomic, strong) NSArray <Permission*> *records;
@property (nonatomic, assign) NSInteger total;

@end
