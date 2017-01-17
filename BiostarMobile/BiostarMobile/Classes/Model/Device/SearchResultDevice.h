//
//  SearchResultDevice.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 9..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RS485.h"
#import "ChildDevice.h"
#import "SmartCardLayout.h"
#import "DeviceLanInfo.h"
#import "DeviceType.h"
#import "DeviceLanInfo.h"
#import "WiegandFormat.h"

@interface SearchResultDevice : NSObject

@property (nonatomic, strong) NSArray <ChildDevice*> *children;
@property (nonatomic, strong) WiegandFormat *csn_wiegand_format;
@property (nonatomic, strong) SimpleModel *device_group;
@property (nonatomic, strong) DeviceType *device_type;
@property (nonatomic, strong) NSString *id;
//@property (nonatomic, strong) DeviceLanInfo *lan;     // 이전버전에서도 사용하지 않고 내용이 바뀌어 사용하지 않도록 빼버림
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *mode;           // 2.4.0 이전버전에서 사용하는 property
@property (nonatomic, strong) RS485 *rs485;
@property (nonatomic, strong) SmartCardLayout *smart_card_layout;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSArray <SimpleModel*> *used_by_doors;
@property (nonatomic, strong) NSArray <WiegandFormat*> *wiegand_format_list;
@property (nonatomic, assign) BOOL isSelected;
@end
