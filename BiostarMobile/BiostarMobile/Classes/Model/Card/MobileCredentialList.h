//
//  MobileCredentialList.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 9..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@interface MobileCredentialList : NSObject

@property (nonatomic, strong) NSArray <Card*> *mobile_credential_list;

@end
