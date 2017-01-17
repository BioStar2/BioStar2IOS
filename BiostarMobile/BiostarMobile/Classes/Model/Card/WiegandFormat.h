//
//  WiegandFormat.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 19..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "SimpleModel.h"
#import "WiegandCardIDList.h"

@interface WiegandFormat : SimpleModel

@property (nonatomic, assign) BOOL use_facility_code;
@property (nonatomic, strong) NSArray <WiegandCardIDList*> *wiegand_card_id_list;

@end
