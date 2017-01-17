//
//  DeviceType.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 9..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceType : NSObject

@property (nonatomic, strong) NSString *id;
@property (nonatomic, assign) long input_port_num;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) long output_port_num;
@property (nonatomic, assign) long relay_num;
@property (nonatomic, assign) long rs485_channel_num;
@property (nonatomic, assign) BOOL scan_card;
@property (nonatomic, assign) BOOL scan_face;
@property (nonatomic, assign) BOOL scan_fingerprint;

@end
