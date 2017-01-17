//
//  GetDoorList.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 10..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "Response.h"
#import "ListDoorItem.h"

@interface GetDoorList : Response

@property (nonatomic, strong) NSArray <ListDoorItem*> *records;
@property (nonatomic, assign) NSInteger total;

@end
