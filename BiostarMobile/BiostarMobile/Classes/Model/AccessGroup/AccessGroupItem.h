//
//  AccessGroupItem.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 2..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserItemAccessGroup.h"

@interface AccessGroupItem : UserItemAccessGroup

@property (nonatomic, strong) NSString *access_level_summary;
@property (nonatomic, strong) NSString *access_group_description;
@property (nonatomic, strong) NSString *user_group_summary;
@property (nonatomic, strong) NSString *user_summary;



@end
