//
//  UserItemAccessGroup.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 2..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserItemAccessGroup : NSObject

@property (nonatomic, strong) NSString *id;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) NSString *included_by_user_group;
@property (nonatomic, strong) NSString *name;

@end
