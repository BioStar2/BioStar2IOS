//
//  ButtonModel.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 15..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "ButtonModel.h"
#import <objc/runtime.h>

@implementation ButtonModel

-(id)copyWithZone:(NSZone *)zone
{
    ButtonModel *myCopy = [[ButtonModel alloc] init];
    
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
