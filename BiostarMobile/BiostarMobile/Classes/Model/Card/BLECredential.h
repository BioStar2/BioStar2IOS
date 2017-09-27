//
//  BLECredential.h
//  BiostarMobile
//
//  Created by 정의석 on 2017. 2. 22..
//  Copyright © 2017년 suprema. All rights reserved.
//


#import "CommonUtil.h"
@interface BLECredential : NSObject

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *raw;
@property (nonatomic, strong) NSString *smart_card_layout_primary_key;  // primary key
@property (nonatomic, strong) NSString *smart_card_layout_second_key;   //
//@property (nonatomic, strong) NSString *issue_count;
//@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, assign) NSUInteger templateSize;


- (NSData*)getHeaderData;
- (NSData*)getCardIDData;
- (NSData*)getPINData;
- (NSData*)getFingerprintData:(NSUInteger)index;
- (NSData*)getAOCData;
- (NSData*)getPrimaryIVData;
- (NSData*)getSecondaryIVData;
- (BOOL)isAOC;
- (NSUInteger)getFingerprintCount;
- (NSUInteger)getTemplateSize;
- (NSString*)getTemplateSizeString;

- (NSData*)getTotalData;
- (NSData*)getRawData;


@end
