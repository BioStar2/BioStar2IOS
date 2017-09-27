//
//  DualAuthentication.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 10..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DualAuthentication : NSObject

//@property (nonatomic, assign) NSArray <NSNumber*>*approval_group_ids;
@property (nonatomic, strong) NSString *dual_authentication_device;
@property (nonatomic, strong) NSString *dual_authentication_type;
@property (nonatomic, assign) NSInteger schedule_id;
@property (nonatomic, assign) NSInteger second_auth_timeout;


@end
