//
//  CloudRole.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 7..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudRole : NSObject

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *role_description;

@end
