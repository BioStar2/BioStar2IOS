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
    
    description = [NSString stringWithFormat:@"%ld", self.fingerprint_index_list.count];
    
    return description;
    
//    NSString *description;
//    
//    NSUInteger index = [self.fingerprint_index_list[0] integerValue];
//    switch (index)
//    {
//        case 0:
//            description = NSLocalizedString(@"1st_fingerprint", nil);
//            break;
//            
//        case 1:
//            description = NSLocalizedString(@"2nd_fingerprint", nil);
//            break;
//            
//        case 2:
//            description = NSLocalizedString(@"3rd_fingerprint", nil);
//            break;
//            
//        default:
//            
//            description = [NSString stringWithFormat:NSLocalizedString(@"%ldth_fingerprint", nil), (long)index + 1];
//            break;
//    }
//    
//    if (self.fingerprint_index_list.count > 1)
//    {
//        NSMutableString *extraDec = [[NSMutableString alloc] init];
//        
//        [extraDec appendFormat:@" +%ld",self.fingerprint_index_list.count - 1];
//        
//        description = [NSString stringWithFormat:@"%@%@", description,  extraDec];
//    }
//    
//    return description;
}

@end
