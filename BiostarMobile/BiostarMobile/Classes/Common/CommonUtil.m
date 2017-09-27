/*
 * Copyright 2015 Suprema(biostar2@suprema.co.kr)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "CommonUtil.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation CommonUtil

+ (UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (UIImage *)imageScale:(UIImage *)__autoreleasing image size:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)imageCompress:(UIImage *)__autoreleasing image fileSize:(unsigned long)fileSize
{
    CGFloat width = 200;
    CGFloat height = 200;
    
    CGSize tempSize = CGSizeMake(width, height);
    UIImage *newImage = [self imageScale:image size:tempSize];
    
    NSData *photoData = UIImageJPEGRepresentation(newImage, 0);
    
    unsigned long photoSize = (unsigned long)[photoData length];
    
    while (photoSize >= fileSize)
    {
        width = width - 1;
        height = height - 1;
        tempSize = CGSizeMake(width, height);
        newImage = [self imageScale:image size:tempSize];
        photoData = UIImageJPEGRepresentation(newImage, 0);
        photoSize = (unsigned long)[photoData length];
        
        NSLog(@"Size of Image(bytes):%lu",(unsigned long)photoSize);
    }
    
    return newImage;
}

+ (NSData *)getImageDataCompress:(UIImage *)__autoreleasing image fileSize:(unsigned long)fileSize
{
    CGFloat width = 200;
    CGFloat height = 200;
    
    CGSize tempSize = CGSizeMake(width, height);
    UIImage *newImage = [self imageScale:image size:tempSize];
    
    NSData *photoData = UIImageJPEGRepresentation(newImage, 0);
    
    unsigned long photoSize = (unsigned long)[photoData length];
    
    while (photoSize >= fileSize)
    {
        width = width - 1;
        height = height - 1;
        tempSize = CGSizeMake(width, height);
        newImage = [self imageScale:image size:tempSize];
        photoData = UIImageJPEGRepresentation(newImage, 0);
        photoSize = (unsigned long)[photoData length];
        
        NSLog(@"Size of Image(bytes):%lu",(unsigned long)photoSize);
    }
    
    return photoData;
}

// 데이터 포맷만 바꾸기
+ (NSString *)stringFromDateString:(NSString*)dateString originDateFormat:(NSString*)originFormat transDateFormat:(NSString*)transFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [formatter setDateFormat:originFormat];
    NSDate *startDate = [formatter dateFromString:dateString];
    
    [formatter setDateFormat:transFormat];
    NSString *startDateStr = [formatter stringFromDate:startDate];
    
    return startDateStr;
}

// UCT Date string 을 locale 시간대의 데이터 포맷 바꾸기
+ (NSString *)stringFromDateString:(NSString*)dateString originDateFormat:(NSString*)originFormat transDateFormat:(NSString*)transFormat targetLocale:(NSString*)locale
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:locale]];
    [formatter setDateFormat:originFormat];
    NSDate *startDate = [formatter dateFromString:dateString];
    
    [formatter setDateFormat:transFormat];
    NSString *startDateStr = [formatter stringFromDate:startDate];
    
    return startDateStr;
}

// GMT (UTC) Date을 현지 Date 로 바꿔주기
+ (NSString *)stringFromCurrentLocaleDateString:(NSString*)dateString originDateFormat:(NSString*)originFormat transDateFormat:(NSString*)transFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [formatter setDateFormat:originFormat];

    NSDate *startDate = [formatter dateFromString:dateString];
    
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:transFormat];
    
    NSString *isoCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *identifier = [NSString stringWithFormat:@"%@_POSIX", isoCode];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:identifier];
    
    NSString *startDateStr = [formatter stringFromDate:startDate];
    
    return startDateStr;
}

// 현지 Date을 GMT (UTC) Date 로 바꿔주기
+ (NSString *)stringFromUTCDateToCurrentDateString:(NSString*)UTCDateString originDateFormat:(NSString*)originFormat transDateFormat:(NSString*)transFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:originFormat];
    
    NSDate *startDate = [formatter dateFromString:UTCDateString];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [formatter setDateFormat:transFormat];
    
    NSString *startDateStr = [formatter stringFromDate:startDate];
    
    return startDateStr;
}

// YYYY-MM-dd HH:mm:ss z (2015-03-29 02:31:21 +0000) Date 형식으로 변환
+ (NSDate *)dateFromString:(NSString*)dateString originDateFormat:(NSString*)originFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [dateFormatter setDateFormat:originFormat];
    
    NSDate *newDate = [dateFormatter dateFromString:dateString];
    
    return newDate;
}

// GMT (UTC) 시간을 현지 Date 로 바꿔주기
+ (NSDate *)localDateFromString:(NSString*)dateString originDateFormat:(NSString*)originFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [dateFormatter setDateFormat:originFormat];
    
    NSDate *newDate = [dateFormatter dateFromString:dateString];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    
    NSString *localDateString = [dateFormatter stringFromDate:newDate];
    NSDate *localDate = [dateFormatter dateFromString:localDateString];
    
    return localDate;
}


+ (NSDate *)dateFromstring:(NSString*)dateString timezone:(NSInteger)timezone originDateFormat:(NSString*)originFormat
{
    NSDate *date = [self dateFromString:dateString originDateFormat:originFormat];
    
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date];
    
    NSDateComponents *newComponents = [[NSDateComponents alloc] init];
    [newComponents setTimeZone:[NSTimeZone localTimeZone]];
    [newComponents setYear:dateComponents.year];
    [newComponents setMonth:dateComponents.month];
    [newComponents setDay:dateComponents.day];
    [newComponents setHour:dateComponents.hour];
    [newComponents setMinute:dateComponents.minute];
    [newComponents setSecond:dateComponents.second];
    
    // 셋팅된 타임존으로 시간 계산.
    switch (timezone)
    {
        case 0:
            [newComponents setHour:newComponents.hour - 12];
            break;
        case 1:
            [newComponents setHour:newComponents.hour - 11];
            break;
        case 2:
            [newComponents setHour:newComponents.hour - 10];
            break;
        case 3:
            [newComponents setHour:newComponents.hour - 9];
            break;
        case 4:
            [newComponents setHour:newComponents.hour - 8];
            break;
        case 5:
            [newComponents setHour:newComponents.hour - 7];
            break;
        case 6:
            [newComponents setHour:newComponents.hour - 6];
            break;
        case 7:
            [newComponents setHour:newComponents.hour - 5];
            break;
        case 8:
            [newComponents setHour:newComponents.hour - 4];
            break;
        case 9:
            [newComponents setHour:newComponents.hour - 3];
            [newComponents setMinute:newComponents.minute - 30];
            break;
        case 10:
            [newComponents setHour:newComponents.hour - 3];
            break;
        case 11:
            [newComponents setHour:newComponents.hour - 2];
            break;
        case 12:
            [newComponents setHour:newComponents.hour - 1];
            break;
        case 13:
            
            break;
        case 14:
            [newComponents setHour:newComponents.hour + 1];
            break;
        case 15:
            [newComponents setHour:newComponents.hour + 2];
            break;
        case 16:
            [newComponents setHour:newComponents.hour + 3];
            break;
        case 17:
            [newComponents setHour:newComponents.hour + 3];
            [newComponents setMinute:newComponents.minute + 30];
            break;
        case 18:
            [newComponents setHour:newComponents.hour + 4];
            [newComponents setMinute:newComponents.minute + 30];
            break;
        case 19:
            [newComponents setHour:newComponents.hour + 5];
            break;
        case 20:
            [newComponents setHour:newComponents.hour + 5];
            [newComponents setMinute:newComponents.minute + 30];
            break;
        case 21:
            [newComponents setHour:newComponents.hour + 5];
            [newComponents setMinute:newComponents.minute + 45];
            break;
        case 22:
            [newComponents setHour:newComponents.hour + 6];
            break;
        case 23:
            [newComponents setHour:newComponents.hour + 7];
            break;
        case 24:
            [newComponents setHour:newComponents.hour + 8];
            break;
        case 25:
            [newComponents setHour:newComponents.hour + 9];
            break;
        case 26:
            [newComponents setHour:newComponents.hour + 9];
            [newComponents setMinute:newComponents.minute + 30];
            break;
        case 27:
            [newComponents setHour:newComponents.hour + 10];
            break;
        case 28:
            [newComponents setHour:newComponents.hour + 11];
            break;
        case 29:
            [newComponents setHour:newComponents.hour + 12];
            break;
            
        default:
            break;
    }
    NSDate *expireDate = [calendar dateFromComponents:newComponents];
    
    return expireDate;
}

+ (NSString *)getTenRandomNumber
{
    
    NSInteger r = 0;
    while (r < 1000000000) {
        r = arc4random();
    }
    
    NSString *randomNumber = [NSString stringWithFormat:@"%ld", (long)r];
    
    
    if (randomNumber.length > 10)
    {
        randomNumber = [randomNumber substringToIndex:10];
    }
    
    return randomNumber;
}

+ (BOOL) matchingByRegex:(NSString*)regex withField: (NSString*)field
{
    NSRange r = [field rangeOfString:regex options:NSRegularExpressionSearch];
    
    if (r.location != NSNotFound)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}


+ (CGSize)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font {
    CGSize size = CGSizeZero;
    if (text) {
        //iOS 7
        CGRect frame = [text boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:font } context:nil];
        size = CGSizeMake(frame.size.width, frame.size.height + 1);
    }
    return size;
}


+ (BOOL)isAllDigits:(NSString*)content
{
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [content rangeOfCharacterFromSet: nonNumbers];
    return r.location == NSNotFound && content.length > 0;
}

static inline char itoh(int i) {
    if (i > 9) return 'A' + (i - 10);
    return '0' + i;
}

NSString * NSDataToHex(NSData *data) {
    NSUInteger i, len;
    unsigned char *buf, *bytes;
    
    len = data.length;
    bytes = (unsigned char*)data.bytes;
    buf = malloc(len*2);
    
    for (i=0; i<len; i++) {
        buf[i*2] = itoh((bytes[i] >> 4) & 0xF);
        buf[i*2+1] = itoh(bytes[i] & 0xF);
    }
    
    return [[NSString alloc] initWithBytesNoCopy:buf
                                          length:len*2
                                        encoding:NSASCIIStringEncoding
                                    freeWhenDone:YES];
}

+ (NSUInteger)getIngetegerFromHexString:(NSString*)hexString
{
    unsigned value = 0;
    NSScanner *scanner = [NSScanner scannerWithString:[NSString stringWithFormat:@"#%@", hexString]];
    
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&value];
    
    return value;
}

+ (NSData*)encryptData:(NSData*)data key:(NSData*)key iv:(NSData*)iv
{
    NSData* result = nil;
    
    // setup key
    unsigned char cKey[FBENCRYPT_KEY_SIZE];
    bzero(cKey, sizeof(cKey));
    [key getBytes:cKey length:FBENCRYPT_KEY_SIZE];
    
    // setup iv
    char cIv[FBENCRYPT_BLOCK_SIZE];
    bzero(cIv, FBENCRYPT_BLOCK_SIZE);
    if (iv) {
        [iv getBytes:cIv length:FBENCRYPT_BLOCK_SIZE];
    }
    
    // setup output buffer
    size_t bufferSize = [data length] + FBENCRYPT_BLOCK_SIZE;
    void *buffer = malloc(bufferSize);
    
    // do encrypt
    size_t encryptedSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          FBENCRYPT_ALGORITHM,
                                          kCCOptionECBMode,
                                          cKey,
                                          FBENCRYPT_KEY_SIZE,
                                          cIv,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &encryptedSize);
    if (cryptStatus == kCCSuccess) {
        result = [NSData dataWithBytesNoCopy:buffer length:encryptedSize];
    } else {
        free(buffer);
        NSLog(@"[ERROR] failed to encrypt|CCCryptoStatus: %d", cryptStatus);
    }
    
    return result;
}

+(UIImage*)drawFront:(UIImage*)image text:(NSString*)text atPoint:(CGPoint)point font:(UIFont*)font atRect:(CGRect)rect
{
    UIFont *tempFont = [UIFont fontWithName:font.fontName size:14];
    CGSize size = CGSizeMake(rect.size.width, rect.size.height);
    UIGraphicsBeginImageContext(size);
    
    CGRect drawRect = CGRectMake(rect.origin.x, rect.origin.y + 4, rect.size.width, rect.size.height - 4);
    
    [image drawInRect:drawRect];
    
    [[UIColor whiteColor] set];
    
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:text];
    NSRange range = NSMakeRange(0, [attString length]);
    
    [attString addAttribute:NSFontAttributeName value:tempFont range:range];
    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:range];
    
//    NSShadow* shadow = [[NSShadow alloc] init];
//    shadow.shadowColor = [UIColor darkGrayColor];
//    shadow.shadowOffset = CGSizeMake(1.0f, 1.5f);
//    [attString addAttribute:NSShadowAttributeName value:shadow range:range];
    
    [attString drawInRect:CGRectIntegral(drawRect)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    //text drawInRect:CGRectIntegral(rect) withAttributes:<#(nullable NSDictionary<NSString *,id> *)#>
    [text drawInRect:CGRectIntegral(rect) withFont:font];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
