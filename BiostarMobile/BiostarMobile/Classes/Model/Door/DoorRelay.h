//
//  DoorRelay.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 10..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleModel.h"

@interface DoorRelay : NSObject

@property (nonatomic, strong) SimpleModel *device;
@property (nonatomic, assign) NSInteger index;


@end
