//
//  AlarmAction.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 10..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleModel.h"

@interface AlarmAction : NSObject

@property (nonatomic, strong) SimpleModel *device;
@property (nonatomic, assign) NSInteger output_relay;
@property (nonatomic, strong) SimpleModel *signal;
@property (nonatomic, strong) NSString *type;

@end
