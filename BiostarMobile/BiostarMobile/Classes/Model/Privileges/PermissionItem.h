//
//  PermissionItem.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 21..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PermissionItem : NSObject <NSCopying>

@property (nonatomic, strong) NSArray <NSNumber*>*allowed_group_id_list;
@property (nonatomic, strong) NSString *module;
@property (nonatomic, assign) BOOL read;
@property (nonatomic, assign) BOOL write;

@end
