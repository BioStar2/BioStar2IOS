//
//  UserFingerprintRecords.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 7..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FingerprintTemplate.h"

@interface UserFingerprintRecords : NSObject

@property (nonatomic, strong) NSArray <FingerprintTemplate*> *fingerprint_template_list;
                                                         
@end
