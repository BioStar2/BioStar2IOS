//
//  UserGroup.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 10. 26..
//  Copyright © 2016년 suprema. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "SimpleModel.h"

@interface UserGroup : NSObject <NSCopying>

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) SimpleModel *parent;
@property (nonatomic, assign) NSInteger user_total;
@property (nonatomic, assign) NSInteger user_total_including_sub_groups;

@end
