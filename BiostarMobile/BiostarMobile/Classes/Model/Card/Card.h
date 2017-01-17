//
//  Card.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 2..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleCard.h"
#import "UserItemAccessGroup.h"
#import "SimpleUser.h"
#import "SimpleModel.h"
#import "FingerprintTemplate.h"
#import "NSString+EnumParser.h"
#import "WiegandFormat.h"

@interface Card : SimpleCard





@property (nonatomic, strong) NSArray <UserItemAccessGroup *>*access_groups;
//@property (nonatomic, strong) NSString *card_id;
@property (nonatomic, strong) NSString *expiry_datetime;
@property (nonatomic, strong) NSArray <NSString*> *fingerprint_index_list;
//@property (nonatomic, strong) NSString *id;     // 서버에 전달할 ID 실제 레코드 ID
@property (nonatomic, assign) BOOL is_blocked;
@property (nonatomic, assign) BOOL is_mobile_credential;
@property (nonatomic, assign) BOOL is_registered;
@property (nonatomic, strong) NSString *issue_count;
@property (nonatomic, assign) BOOL pin_exist;
@property (nonatomic, strong) SimpleModel *smart_card_layout;
@property (nonatomic, strong) NSString *start_datetime;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) BOOL unassigned;
@property (nonatomic, strong) SimpleUser *user;
@property (nonatomic, strong) WiegandFormat *wiegand_format;
@property (nonatomic, strong) NSArray <FingerprintTemplate*> *fingerprint_templates;
@property (nonatomic, assign) BOOL isSelected;

- (NSString*)getFingerprintDescription;

@end
