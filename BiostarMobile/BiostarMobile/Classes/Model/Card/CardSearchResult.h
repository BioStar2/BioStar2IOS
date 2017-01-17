//
//  CardSearchResult.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 9..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "Response.h"
#import "Card.h"

@interface CardSearchResult : Response

@property (nonatomic, strong) NSArray <Card*> *records;
@property (nonatomic, assign) NSInteger total;

@end
