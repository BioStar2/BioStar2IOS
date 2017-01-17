//
//  DoorExitButton.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 10..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleModel.h"

@interface DoorExitButton : NSObject

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSString *default_status;
@property (nonatomic, strong) SimpleModel *device;

@end
