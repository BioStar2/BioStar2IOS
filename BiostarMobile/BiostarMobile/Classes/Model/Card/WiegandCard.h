//
//  WiegandCard.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 1..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WiegandCardID.h"

@interface WiegandCard : NSObject

@property (nonatomic, strong) NSArray <WiegandCardID*> *wiegand_card_id_list;
@property (nonatomic, strong) NSString *wiegand_format_id;


@end
