//
//  Card.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 2..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "Card.h"

@implementation Card

- (id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}


- (NSString*)getFingerprintDescription
{
    NSString *description;
    
    description = [NSString stringWithFormat:@"%ld", (unsigned long)self.fingerprint_templates.count];
    
    return description;
    
}


@end
