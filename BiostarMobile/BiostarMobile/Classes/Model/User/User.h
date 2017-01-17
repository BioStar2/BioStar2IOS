//
//  User.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 10. 27..
//  Copyright © 2016년 suprema. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "UserItemAccessGroup.h"
#import "SimpleModel.h"
#import "UserRole.h"
#import "FingerprintTemplate.h"
#import "Card.h"
#import "CloudPermission.h"
// V2 용
#import "Permission.h"
#import "FaceTemplate.h"


@interface User : NSObject <NSCopying>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSArray <UserItemAccessGroup*> *access_groups;
@property (nonatomic, strong) NSArray <CloudPermission*> *permissions;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *expiry_datetime;
@property (nonatomic, assign) NSInteger last_modify;
@property (nonatomic, strong) NSString *login_id;
@property (nonatomic, assign) BOOL password_exist;
@property (nonatomic, strong) NSString *phone_number;
@property (nonatomic, strong) NSString *photo;
@property (nonatomic, assign) BOOL pin_exist;
@property (nonatomic, strong) NSArray <UserRole*> *roles;
@property (nonatomic, assign) NSInteger security_level;
@property (nonatomic, strong) NSString *start_datetime;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, assign) NSInteger fingerprint_count;
@property (nonatomic, strong) NSString *fingerprint_template_count; // v2
@property (nonatomic, assign) NSInteger card_count;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) BOOL photo_exist;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) NSString *pin;
@property (nonatomic, strong) NSArray <FingerprintTemplate*> *fingerprint_templates;
@property (nonatomic, strong) NSArray <Card*> *cards;
@property (nonatomic, strong) NSArray *access_groups_in_user_group;
@property (nonatomic, assign) NSUInteger unread_notification_count;
@property (nonatomic, strong) SimpleModel *user_group;
@property (nonatomic, strong) NSString *password_strength_level;

// V2 용
@property (nonatomic, strong) NSArray <FaceTemplate*> *face_templates;
@property (nonatomic, strong) Permission *permission;


@end
