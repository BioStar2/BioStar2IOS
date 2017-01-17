//
//  SimpleCard.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 8..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "SimpleCard.h"

@implementation SimpleCard

- (id)initWithID:(NSString*)id cardID:(NSString*)cardID
{
    if (self = [super init])
    {
        self.id = id;
        self.card_id = cardID;
    }
    
    return self;
}

@end
