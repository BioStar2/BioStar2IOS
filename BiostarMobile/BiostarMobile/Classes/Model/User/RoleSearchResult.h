//
//  RoleSearchResult.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 7..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "Response.h"
#import "CloudRole.h"
@interface RoleSearchResult : Response

@property (nonatomic, strong) NSArray <CloudRole*> *records;
@property (nonatomic, assign) NSInteger total;

@end
