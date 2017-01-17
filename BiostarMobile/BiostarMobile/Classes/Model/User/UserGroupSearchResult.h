//
//  UserGroupSearchResult.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 1..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Response.h"
#import "UserGroup.h"

@interface UserGroupSearchResult : Response

@property (nonatomic, strong) NSArray <UserGroup*> *records;
@property (nonatomic, assign) NSInteger total;

@end
