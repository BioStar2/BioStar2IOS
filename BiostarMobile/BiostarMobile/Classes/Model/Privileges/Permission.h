//
//  Permission.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 23..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PermissionItem.h"
#import "SimpleUser.h"

@interface Permission : NSObject <NSCopying>

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray <PermissionItem*> *permissions;
@property (nonatomic, strong) NSArray <SimpleUser*> *users;
@property (nonatomic, assign) BOOL isSelected;
@end
