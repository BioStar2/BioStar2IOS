//
//  CardProvider.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 15..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "CardProvider.h"

@implementation CardProvider

- (id)init
{
    if (self = [super init])
    {
        network = [[BSNetwork alloc] init];
        mappingProvider = [[InCodeMappingProvider alloc] init];
        mapper = [[ObjectMapper alloc] init];
        mapper.mappingProvider = mappingProvider;
    }
    
    return self;
}

- (void)getCards:(NSString*)query limit:(NSInteger)limit offset:(NSInteger)offset resultBlock:(CardSearchResultBolck)resultBlock onError:(ErrorBlock)errorBlock
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    if (nil != query)
        [param setObject:query forKey:@"text"];
    
    [param setObject:[NSString stringWithFormat:@"%ld", (long)limit] forKey:@"limit"];
    [param setObject:[NSString stringWithFormat:@"%ld", (long)offset] forKey:@"offset"];
    
    NSArray *allKeys = [param allKeys];
    NSMutableString *subURL = [[NSMutableString alloc] initWithString:@""];
    for (NSString *key in allKeys)
    {
        [subURL appendString:[NSString stringWithFormat:@"%@=%@&", key, [param objectForKey:key]]];
    }
    [subURL setString:[subURL substringToIndex:subURL.length -1]];
    
    
    NSString* url = [NSString stringWithFormat:@"%@%@?%@", [NetworkController sharedInstance].serverURL, API_CARDS, subURL];
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            [mappingProvider mapFromDictionaryKey:@"records" toPropertyKey:@"records" withObjectType:[Card class] forClass:[CardSearchResult class]];
            
            
            CardSearchResult *result = [mapper objectFromSource:responseObject toInstanceOfClass:[CardSearchResult class]];
            
            resultBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
    }];
}


- (void)getSmartCardLayouts:(NSString*)query limit:(NSInteger)limit offset:(NSInteger)offset resultBlock:(CardLayoutResultBolck)resultBlock onError:(ErrorBlock)errorBlock
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    if (nil != query)
        [param setObject:query forKey:@"text"];
    
    [param setObject:[NSString stringWithFormat:@"%ld", (long)limit] forKey:@"limit"];
    [param setObject:[NSString stringWithFormat:@"%ld", (long)offset] forKey:@"offset"];
    
    NSArray *allKeys = [param allKeys];
    NSMutableString *subURL = [[NSMutableString alloc] initWithString:@""];
    for (NSString *key in allKeys)
    {
        [subURL appendString:[NSString stringWithFormat:@"%@=%@&", key, [param objectForKey:key]]];
    }
    [subURL setString:[subURL substringToIndex:subURL.length -1]];
    
    
    NSString* url = [NSString stringWithFormat:@"%@%@?%@", [NetworkController sharedInstance].serverURL, API_SMART_CARD_LAYOUT, subURL];
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            [mappingProvider mapFromDictionaryKey:@"records" toPropertyKey:@"records" withObjectType:[SmartCardLayout class] forClass:[CardLayoutSearchResult class]];
            
            CardLayoutSearchResult *result = [mapper objectFromSource:responseObject toInstanceOfClass:[CardLayoutSearchResult class]];
            
            resultBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
    }];
}


- (void)makeCSNCard:(NSString*)cardID resultBlock:(AddBlock)resultBlock onError:(ErrorBlock)errorBlock
{
 
    NSDictionary *cardDic = @{@"card_id" : cardID};
    
    NSError *jsonError;
    NSData *jsonData;
    jsonData = [NSJSONSerialization dataWithJSONObject:cardDic options:kNilOptions error:&jsonError];
    
    if (nil != jsonError)
    {
        Response *response = [Response new];
        response.message = [jsonError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_CSN_CARDS];
    [network request:url withParam:jsonString method:POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            AddResponse *result = [mapper objectFromSource:responseObject toInstanceOfClass:[AddResponse class]];
            
            resultBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
    }];
}


- (void)makeWIEGANDCard:(WiegandCard*)wiegandCard resultBlock:(AddBlock)resultBlock onError:(ErrorBlock)errorBlock
{
    NSDictionary *wegiandCardDic = [mapper dictionaryFromObject:wiegandCard];
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:wegiandCardDic options:kNilOptions error:&jsonError];
    
    if (nil != jsonError)
    {
        Response *response = [Response new];
        response.message = [jsonError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_WIEGAND_CARDS];
    [network request:url withParam:jsonString method:POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            AddResponse *result = [mapper objectFromSource:responseObject toInstanceOfClass:[AddResponse class]];
            
            resultBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
    }];
}

- (void)makeSecureCredentialCard:(SecureCredential*)credential resultBlock:(AddBlock)resultBlock onError:(ErrorBlock)errorBlock
{
    NSDictionary *credentialDic = [mapper dictionaryFromObject:credential];
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:credentialDic options:kNilOptions error:&jsonError];
    
    if (nil != jsonError)
    {
        Response *response = [Response new];
        response.message = [jsonError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_SECURE_CARDS];
    [network request:url withParam:jsonString method:POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            AddResponse *result = [mapper objectFromSource:responseObject toInstanceOfClass:[AddResponse class]];
            
            resultBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
    }];
}

- (void)makeAccessOnCard:(AccessOnCredential*)credential resultBlock:(AddBlock)resultBlock onError:(ErrorBlock)errorBlock
{
    NSDictionary *credentialDic = [mapper dictionaryFromObject:credential];
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:credentialDic options:kNilOptions error:&jsonError];
    
    if (nil != jsonError)
    {
        Response *response = [Response new];
        response.message = [jsonError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_ACCESS_CARDS];
    [network request:url withParam:jsonString method:POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            AddResponse *result = [mapper objectFromSource:responseObject toInstanceOfClass:[AddResponse class]];
            
            resultBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
    }];
}

- (void)deleteMobileCredential:(NSString*)cardID resultBlock:(ResultBlock)resultBlock onError:(ErrorBlock)errorBlock
{
    
    NSString* url = [NSString stringWithFormat:@"%@%@/%@", [NetworkController sharedInstance].serverURL, API_MOBILE_CREDENTIAL, cardID];
    [network request:url withParam:nil method:DELETE completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
        
        if (nil == error)
        {
            resultBlock(response);
        }
        else
        {
            resultBlock(response);
        }
    }];
}

- (void)blockCard:(NSString*)cardID resultBlock:(ResultBlock)resultBlock onError:(ErrorBlock)errorBlock
{
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_BLOCK_CARD, cardID]];
    
    [network request:url withParam:nil method:POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            Response *result = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            resultBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
    }];
}

- (void)unblockCard:(NSString*)cardID resultBlock:(ResultBlock)resultBlock onError:(ErrorBlock)errorBlock
{
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_UNBLOCK_CARD, cardID]];
    
    [network request:url withParam:nil method:POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            Response *result = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            resultBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
    }];
}


- (void)getWiegandFormat:(WiegandFormatResultBolck)resultBlock onError:(ErrorBlock)errorBlock
{
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_WEIGAND_FORMAT];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            [mappingProvider mapFromDictionaryKey:@"wiegand_card_id_list" toPropertyKey:@"wiegand_card_id_list" withObjectType:[WiegandCardIDList class] forClass:[WiegandFormat class]];
            
            [mappingProvider mapFromDictionaryKey:@"records" toPropertyKey:@"records" withObjectType:[WiegandFormat class] forClass:[WiegandFormatSearchResult class]];
            
            WiegandFormatSearchResult *result = [mapper objectFromSource:responseObject toInstanceOfClass:[WiegandFormatSearchResult class]];
            
            resultBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
    }];
}

@end
