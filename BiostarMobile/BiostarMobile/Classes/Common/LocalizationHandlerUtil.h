//
//  LocalizationHandlerUtil.h
//  BiostarMobile
//
//  Created by 정의석 on 2017. 4. 13..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalizationHandlerUtil : NSObject

+ (LocalizationHandlerUtil *)singleton;
- (NSString *)localizedString:(NSString *)key comment:(NSString *)comment;

@end
