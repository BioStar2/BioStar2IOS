//
//  BLECredential.m
//  BiostarMobile
//
//  Created by 정의석 on 2017. 2. 22..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import "BLECredential.h"
#import "NSData+Base64.h"

@implementation BLECredential

- (NSData*)getHeaderData
{
    NSData *header;
    
    if (self.raw && ![self.raw isEqualToString:@""])
    {
        NSData *cardByteData = [NSData base64DataFromString:self.raw];
        //NSLog(@"%@", cardByteData);
        header = [cardByteData subdataWithRange:NSMakeRange(0, 16)];
        //NSLog(@"%@", header);
    }
    
    return header;
}

- (NSData*)getTotalData
{
    NSMutableData *totalData = [NSMutableData new];
    
    if (self.raw && ![self.raw isEqualToString:@""])
    {
        NSData *header = [self getHeaderData];
        NSData *cardID = [self getCardIDData];
        NSData *AOC = [self getAOCData];
        
        [totalData appendData:header];
        [totalData appendData:cardID];
        [totalData appendData:AOC];
        
    }
    
    return totalData;
}

- (NSData*)getRawData
{
    NSData *rawData;
    
    if (self.raw && ![self.raw isEqualToString:@""])
    {
        rawData = [NSData base64DataFromString:self.raw];
        
    }
    return rawData;
}

- (NSData*)getCardIDData
{
    NSData *cardID;
    
    NSUInteger start = 16;
    NSUInteger end = 32;
    
    if (self.raw && ![self.raw isEqualToString:@""])
    {
        NSData *cardByteData = [NSData base64DataFromString:self.raw];
        //NSLog(@"%@", cardByteData);
        cardID = [cardByteData subdataWithRange:NSMakeRange(start, end)];
        //NSLog(@"%@", cardID);
    }
    
    return cardID;
}

- (NSData*)getPINData
{
    NSData *PIN;
    
    NSUInteger start = 16 + 32;
    NSUInteger end = 32;
    
    if (self.raw && ![self.raw isEqualToString:@""])
    {
        NSData *cardByteData = [NSData base64DataFromString:self.raw];
        //NSLog(@"%@", cardByteData);
        PIN = [cardByteData subdataWithRange:NSMakeRange(start, end)];
        //NSLog(@"%@", PIN);
    }
    
    return PIN;
}

- (NSData*)getFingerprintData:(NSUInteger)index
{
    NSData *fingerprint;
    
    NSUInteger start = 80 + (index * self.templateSize);
    NSUInteger length = [self getTemplateSize];

    if (self.raw && ![self.raw isEqualToString:@""])
    {
        NSData *cardByteData = [NSData base64DataFromString:self.raw];
        //NSLog(@"%@", cardByteData);
        fingerprint = [cardByteData subdataWithRange:NSMakeRange(start, length)];
        //NSLog(@"%@", fingerprint);
    }
    
    return fingerprint;
}

- (NSData*)getAOCData
{
    NSData *AOC;
    if ([self isAOC])
    {
        if (self.raw && ![self.raw isEqualToString:@""])
        {
            NSData *cardByteData = [NSData base64DataFromString:self.raw];
            //NSLog(@"%@", cardByteData);
            AOC = [cardByteData subdataWithRange:NSMakeRange(cardByteData.length - 40, 40)];
            //NSLog(@"%@", AOC);
        }
    }
    
    
    return AOC;
}

- (NSData*)getPrimaryIVData
{
    NSMutableData *tempData = [[NSMutableData alloc] initWithLength:16];
    
    char defaultData[] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
    
    if (nil == self.smart_card_layout_primary_key || [self.smart_card_layout_primary_key isEqualToString:@""])
    {
        NSData *primaryKey = [NSData dataWithBytes:defaultData length:sizeof(char)*16];
        return primaryKey;
    }
    else
    {
        [tempData replaceBytesInRange:NSMakeRange(0, tempData.length) withBytes:defaultData];
        
        NSData *plainData = [self.smart_card_layout_primary_key dataUsingEncoding:NSASCIIStringEncoding];
        
        [tempData replaceBytesInRange:NSMakeRange(0, plainData.length) withBytes:[plainData bytes]];
        
        return tempData;
    }
    
}

- (NSData*)getSecondaryIVData
{
    NSMutableData *tempData = [[NSMutableData alloc] initWithLength:16];
    
    char defaultData[] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
    
    if (nil == self.smart_card_layout_second_key || [self.smart_card_layout_second_key isEqualToString:@""])
    {
        NSData *primaryKey = [NSData dataWithBytes:defaultData length:sizeof(char)*16];
        return primaryKey;
    }
    else
    {
        [tempData replaceBytesInRange:NSMakeRange(0, tempData.length) withBytes:defaultData];
        
        NSData *plainData = [self.smart_card_layout_second_key dataUsingEncoding:NSASCIIStringEncoding];
        
        [tempData replaceBytesInRange:NSMakeRange(0, plainData.length) withBytes:[plainData bytes]];
        
        return tempData;
    }
}

- (BOOL)isAOC
{
    BOOL isAOC;
    
    NSData *cardByteData = [NSData base64DataFromString:self.raw];
    //NSLog(@"%@", cardByteData);
    NSData *checkData = [cardByteData subdataWithRange:NSMakeRange(4, 1)];
    
    NSString *checkStr = NSDataToHex(checkData);
    isAOC = [checkStr isEqualToString:@"03"];
    
    return isAOC;
}

- (NSUInteger)getFingerprintCount
{
    NSUInteger count;
    
    NSData *cardByteData = [NSData base64DataFromString:self.raw];
    //NSLog(@"%@", cardByteData);
    NSData *checkData = [cardByteData subdataWithRange:NSMakeRange(5, 1)];
    NSString *checkStr = NSDataToHex(checkData);
    count = [checkStr integerValue];
    
    return count;
}

- (NSUInteger)getTemplateSize
{
    if (self.raw && ![self.raw isEqualToString:@""])
    {
        NSData *cardByteData = [NSData base64DataFromString:self.raw];
        
        NSMutableData *sizeData = [[NSMutableData alloc] init];
        NSData *checkData = [cardByteData subdataWithRange:NSMakeRange(7, 1)];
        [sizeData appendData:checkData];
        checkData = [cardByteData subdataWithRange:NSMakeRange(6, 1)];
        [sizeData appendData:checkData];
        
        NSString *checkStr = NSDataToHex(sizeData);
        
        unsigned value = 0;
        NSScanner *scanner = [NSScanner scannerWithString:[NSString stringWithFormat:@"#%@", checkStr]];
        
        [scanner setScanLocation:1]; // bypass '#' character
        [scanner scanHexInt:&value];
        //NSLog(@"%d", value);
        
        self.templateSize = value;
    
    }
    
    return self.templateSize;
}

- (NSString*)getTemplateSizeString
{
    NSString *sizeString;
    if (self.raw && ![self.raw isEqualToString:@""])
    {
        NSData *cardByteData = [NSData base64DataFromString:self.raw];
        
        NSMutableData *sizeData = [[NSMutableData alloc] init];
        NSData *checkData = [cardByteData subdataWithRange:NSMakeRange(7, 1)];
        [sizeData appendData:checkData];
        checkData = [cardByteData subdataWithRange:NSMakeRange(6, 1)];
        [sizeData appendData:checkData];
        
        sizeString = NSDataToHex(sizeData);
        
    }
    
    return sizeString;
}


@end
