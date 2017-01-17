//
//  ChildDevice.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 5..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleModel.h"
#import "DeviceLanInfo.h"
#import "RS485.h"

@interface ChildDevice : NSObject

@property (nonatomic, strong) SimpleModel *device_group;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *DeviceLanInfo;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) SimpleModel *parent;
@property (nonatomic, strong) RS485 *rs485;


@end
