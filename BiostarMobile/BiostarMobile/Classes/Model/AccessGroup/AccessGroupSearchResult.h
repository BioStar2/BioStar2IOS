//
//  AccessGroupSearchResult.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 2..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "Response.h"
#import "AccessGroupItem.h"

@interface AccessGroupSearchResult : Response

@property (nonatomic, strong) NSArray <AccessGroupItem *> *records;
@property (nonatomic, assign) NSInteger total;

@end
