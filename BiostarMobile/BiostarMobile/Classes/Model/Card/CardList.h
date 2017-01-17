//
//  CardList.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 30..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleCard.h"

@interface CardList : NSObject

@property (nonatomic, strong) NSArray <SimpleCard*> *card_list;

@end
