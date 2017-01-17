//
//  RS485.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 5..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "RS485.h"

@implementation RS485



- (RS485Type)typeEnumFromString
{
    NSDictionary<NSString*,NSNumber*> *types = @{
                                                    @"MASTER": @(MASTER),
                                                    @"SLAVE": @(SLAVE),
                                                    @"DEFAULT": @(DEFAULT)
                                                    };
    return types[self.mode].integerValue;
}
@end
