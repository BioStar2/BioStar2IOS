//
//  Response.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 10. 28..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "Response.h"

@implementation Response

- (void)setMessage:(NSString *)message
{
    _message = [message stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    
}
@end
