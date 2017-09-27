//
//  GetMobileCredential.h
//  BiostarMobile
//
//  Created by 정의석 on 2017. 3. 22..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserItemAccessGroup.h"
#import "SmartCardLayout.h"
#import "SimpleUser.h"

@interface GetMobileCredential : NSObject

@property (nonatomic, strong) NSArray <UserItemAccessGroup*> *access_groups;
@property (nonatomic, strong) NSString *card_id;
@property (nonatomic, strong) NSString *expiry_datetime;
@property (nonatomic, strong) NSArray <NSNumber*> *fingerprint_index_list; // max 4
@property (nonatomic, strong) NSString *id;
@property (nonatomic, assign) BOOL is_mobile_credential;
@property (nonatomic, assign) BOOL is_registered;
@property (nonatomic, strong) NSString *issue_count;
@property (nonatomic, assign) BOOL pin_exist;
@property (nonatomic, strong) SmartCardLayout *smart_card_layout;
@property (nonatomic, strong) NSString *start_datetime;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) SimpleUser *user;


@end
