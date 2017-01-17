//
//  DHCP.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 5..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHCP : NSObject

@property (nonatomic, strong) NSString *device_ip;
@property (nonatomic, strong) NSString *device_port;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) NSString *gateway;
@property (nonatomic, strong) NSString *subnet_mask;

@end
