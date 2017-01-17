//
//  AccessOnCredential.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 9..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccessOnCredential : NSObject


@property (nonatomic, strong) NSString *device_id;
@property (nonatomic, strong) NSArray <NSNumber*> *fingerprint_index_list; // max 4
@property (nonatomic, strong) NSString *user_id;

- (NSString*)getFingerprintDescription;

@end
