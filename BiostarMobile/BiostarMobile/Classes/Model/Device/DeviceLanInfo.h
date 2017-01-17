//
//  DeviceLanInfo.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 9..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "SimpleDeviceLanInfo.h"
#import "ConnectionMode.h"
#import "DHCP.h"

@interface DeviceLanInfo : SimpleDeviceLanInfo

@property (nonatomic, strong) ConnectionMode *connection_mode;
@property (nonatomic, strong) DHCP *dhcp;

@end
