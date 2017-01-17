//
//  UserCardList.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 8..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "Response.h"
#import "Card.h"

@interface UserCardList : Response

@property (nonatomic, strong) NSArray <Card*> *card_list;

@end
