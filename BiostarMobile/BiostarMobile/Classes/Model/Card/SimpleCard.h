//
//  SimpleCard.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 8..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleCard : NSObject

@property (nonatomic, strong) NSString *card_id;
@property (nonatomic, strong) NSString *id;



- (id)initWithID:(NSString*)id cardID:(NSString*)cardID;

@end
