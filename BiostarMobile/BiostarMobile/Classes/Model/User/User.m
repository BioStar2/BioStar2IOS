//
//  User.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 10. 27..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "User.h"
#import <objc/runtime.h>

@implementation User


- (id)init
{
    if (self = [super init])
    {
        self.isSelected = NO;
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    User *myCopy = [[User alloc] init];
    
    //deepCopy
    unsigned int numOfProperties;
    objc_property_t *properties = class_copyPropertyList([self class], &numOfProperties);
    
    for (int i = 0; i < numOfProperties; i++) {
        
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc]initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        
        [myCopy setValue:[[self valueForKey:propertyName] copy] forKey:propertyName];
    }
    return myCopy;
}

@end
