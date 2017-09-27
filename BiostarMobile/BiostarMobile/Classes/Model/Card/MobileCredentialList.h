//
//  MobileCredentialList.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 9..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetMobileCredential.h"

@interface MobileCredentialList : NSObject

@property (nonatomic, strong) NSArray <GetMobileCredential*> *mobile_credential_list;

@end
