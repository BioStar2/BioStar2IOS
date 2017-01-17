//
//  UserSearchResult.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 10. 26..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Response.h"
#import "User.h"

@interface UserSearchResult : Response

@property (nonatomic, strong) NSArray <User*> *records;
@property (nonatomic, assign) NSInteger total;


@end
