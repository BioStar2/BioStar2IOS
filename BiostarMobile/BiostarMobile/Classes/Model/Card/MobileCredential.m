//
//  MobileCredential.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 16..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "MobileCredential.h"



@implementation MobileCredential

- (NSString*)getFingerprintDescription
{
    NSString *description;
    
    description = [NSString stringWithFormat:@"%ld", (unsigned long)self.fingerprint_index_list.count];
    
    return description;
}

@end
