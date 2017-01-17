//
//  MobileCredential.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 16..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SECURE           @"SECURE_CREDENTIAL"
#define ACCESS           @"ACCESS_ON"

@interface MobileCredential : NSObject


@property (nonatomic, strong) NSString *card_id;
@property (nonatomic, strong) NSArray <NSNumber*> *fingerprint_index_list; // max 4
@property (nonatomic, strong) NSString *layout_id;
@property (nonatomic, strong) NSString *type;

- (NSString*)getFingerprintDescription;

@end
