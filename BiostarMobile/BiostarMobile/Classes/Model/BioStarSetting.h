//
//  BioStarSetting.h
//  BiostarMobile
//
//  Created by 정의석 on 2017. 1. 4..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BioStarSetting : NSObject


@property (nonatomic, strong) NSString *password_strength_level;
@property (nonatomic, assign) BOOL use_alphanumeric_user_id;

@end
