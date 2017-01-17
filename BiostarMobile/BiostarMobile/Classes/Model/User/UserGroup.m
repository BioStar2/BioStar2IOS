//
//  UserGroup.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 10. 26..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "UserGroup.h"
#import <objc/runtime.h>

@implementation UserGroup

-(id)copyWithZone:(NSZone *)zone
{
    UserGroup *myCopy = [[UserGroup alloc] init];
    
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
