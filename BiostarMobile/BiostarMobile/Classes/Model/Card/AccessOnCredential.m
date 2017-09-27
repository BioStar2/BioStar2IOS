//
//  AccessOnCredential.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 9..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "AccessOnCredential.h"

@implementation AccessOnCredential

- (NSString*)getFingerprintDescription
{
    NSString *description;
    
    description = [NSString stringWithFormat:@"%ld", (unsigned long)self.fingerprint_index_list.count];
    
    return description;
    
}

@end
