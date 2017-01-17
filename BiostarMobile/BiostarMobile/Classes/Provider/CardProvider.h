//
//  CardProvider.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 15..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSNetwork.h"
#import "ObjectMapper.h"
#import "InCodeMappingProvider.h"
#import "CardSearchResult.h"
#import "AddResponse.h"
#import "MobileCredential.h"
#import "CardLayoutSearchResult.h"
#import "SecureCredential.h"
#import "WiegandCard.h"
#import "WiegandFormatSearchResult.h"


@interface CardProvider : NSObject
{
    BSNetwork *network;
    ObjectMapper *mapper;
    InCodeMappingProvider *mappingProvider;
}

typedef void(^CardSearchResultBolck)(CardSearchResult *result);
typedef void(^CardLayoutResultBolck)(CardLayoutSearchResult *result);
typedef void(^WiegandFormatResultBolck)(WiegandFormatSearchResult *result);

/**
 *  Get Unassigned Card List
 *
 *  @param query        Search string
 *  @param limit        Number of results
 *  @param offset       Results data offset
 *  @param handler      NetworkCompleteBolck
 */

- (void)getCards:(NSString*)query limit:(NSInteger)limit offset:(NSInteger)offset resultBlock:(CardSearchResultBolck)resultBlock onError:(ErrorBlock)errorBlock;


- (void)getSmartCardLayouts:(NSString*)query limit:(NSInteger)limit offset:(NSInteger)offset resultBlock:(CardLayoutResultBolck)resultBlock onError:(ErrorBlock)errorBlock;

- (void)makeCSNCard:(NSString*)cardID resultBlock:(AddBlock)resultBlock onError:(ErrorBlock)errorBlock;

- (void)makeWIEGANDCard:(WiegandCard*)wiegandCard resultBlock:(AddBlock)resultBlock onError:(ErrorBlock)errorBlock;

- (void)makeSecureCredentialCard:(SecureCredential*)credential resultBlock:(AddBlock)resultBlock onError:(ErrorBlock)errorBlock;

- (void)makeAccessOnCard:(AccessOnCredential*)credential resultBlock:(AddBlock)resultBlock onError:(ErrorBlock)errorBlock;

- (void)deleteMobileCredential:(NSString*)cardID resultBlock:(ResultBlock)resultBlock onError:(ErrorBlock)errorBlock;

- (void)blockCard:(NSString*)cardID resultBlock:(ResultBlock)resultBlock onError:(ErrorBlock)errorBlock;

- (void)unblockCard:(NSString*)cardID resultBlock:(ResultBlock)resultBlock onError:(ErrorBlock)errorBlock;

- (void)getWiegandFormat:(WiegandFormatResultBolck)resultBlock onError:(ErrorBlock)errorBlock;

@end
