//
//  LocalizationHandlerUtil.m
//  BiostarMobile
//
//  Created by 정의석 on 2017. 4. 13..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import "LocalizationHandlerUtil.h"

@implementation LocalizationHandlerUtil

static LocalizationHandlerUtil * singleton = nil;

+ (LocalizationHandlerUtil *)singleton
{
    return singleton;
}

__attribute__((constructor))
static void staticInit_singleton()
{
    singleton = [[LocalizationHandlerUtil alloc] init];
}

- (NSString *)localizedString:(NSString *)key comment:(NSString *)comment
{
    NSString* localizedString = NSLocalizedString(key, nil);
    
    //use base language if current language setting on device does not find a proper value
    if([localizedString isEqualToString:key])
    {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"Base" ofType:@"lproj"];
        NSBundle * bundle = nil;
        if(path == nil){
            bundle = [NSBundle mainBundle];
        }else{
            bundle = [NSBundle bundleWithPath:path];
        }
        localizedString = [bundle localizedStringForKey:key value:comment table:nil];
    }
    
    return localizedString;
}

@end
