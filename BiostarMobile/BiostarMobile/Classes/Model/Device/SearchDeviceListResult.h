//
//  SearchDeviceListResult.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 3..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "Response.h"
#import "SearchResultDevice.h"

@interface SearchDeviceListResult : Response

@property (nonatomic, strong) NSArray <SearchResultDevice*> *records;
@property (nonatomic, assign) NSInteger total;

@end
