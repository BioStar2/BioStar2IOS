//
//  RS485.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 5..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RS485 : NSObject

@property (nonatomic, strong) NSString *baud_rate;
@property (nonatomic, strong) NSString *mode;

typedef NS_ENUM(NSInteger, RS485Type) {
    MASTER                  = 0,
    SLAVE                    = 1,
    DEFAULT                    = 2,
};

- (RS485Type)typeEnumFromString;


@end
