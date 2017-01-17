//
//  PermissionItem.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 21..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "PermissionItem.h"
#import <objc/runtime.h>

@implementation PermissionItem


-(id)copyWithZone:(NSZone *)zone
{
    PermissionItem *myCopy = [[PermissionItem alloc] init];
    
    //deepCopy
    unsigned int numOfProperties;
    objc_property_t *properties = class_copyPropertyList([self class], &numOfProperties);
    
    for (int i = 0; i < numOfProperties; i++) {
        
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc]initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        NSLog(@"%@", propertyName);
        [myCopy setValue:[[self valueForKey:propertyName] copy] forKey:propertyName];
    }
    return myCopy;
}

@end
