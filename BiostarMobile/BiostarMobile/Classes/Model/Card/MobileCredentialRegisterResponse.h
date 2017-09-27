//
//  MobileCredentialRegisterResponse.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 8..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "Response.h"

@interface MobileCredentialRegisterResponse : Response

@property (nonatomic, strong) NSString *raw;
@property (nonatomic, strong) NSString *smart_card_layout_primary_key; 
@property (nonatomic, strong) NSString *smart_card_layout_second_key;

@end
