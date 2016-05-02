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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CommonUtil : NSObject

+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (UIImage *)imageScale:(UIImage *)__autoreleasing image size:(CGSize)newSize;
+ (UIImage *)imageCompress:(UIImage *)__autoreleasing image fileSize:(unsigned long)fileSize;
+ (NSData *)getImageDataCompress:(UIImage *)__autoreleasing image fileSize:(unsigned long)fileSize;

// 데이터 포맷만 바꾸기
+ (NSString *)stringFromDateString:(NSString*)dateString originDateFormat:(NSString*)originFormat transDateFormat:(NSString*)transFormat;

// UCT Date string 을 locale 시간대의 데이터 포맷 바꾸기
+ (NSString *)stringFromDateString:(NSString*)dateString originDateFormat:(NSString*)originFormat transDateFormat:(NSString*)transFormat targetLocale:(NSString*)locale;

// GMT (UTC) 시간을 현지 Date String 로 바꿔주기
+ (NSString *)stringFromCurrentLocaleDateString:(NSString*)dateString originDateFormat:(NSString*)originFormat transDateFormat:(NSString*)transFormat;

// 현지 Date을 GMT (UTC) Date String 로 바꿔주기
+ (NSString *)stringFromUTCDateToCurrentDateString:(NSString*)UTCDateString originDateFormat:(NSString*)originFormat transDateFormat:(NSString*)transFormat;

// YYYY-MM-dd HH:mm:ss z (2015-03-29 02:31:21 +0000)  Date 형식으로 변환
+ (NSDate *)dateFromString:(NSString*)dateString originDateFormat:(NSString*)originFormat;

// GMT (UTC) 시간을 현지 Date 로 바꿔주기
+ (NSDate *)localDateFromString:(NSString*)dateString originDateFormat:(NSString*)originFormat;

+ (NSDate *)dateFromstring:(NSString*)dateString timezone:(NSInteger)timezone originDateFormat:(NSString*)originFormat;

+ (NSString *)getTenRandomNumber;

+ (BOOL)matchingByRegex:(NSString*)regex withField: (NSString*)field;


// 스트링 CGSize 가져오기
+ (CGSize)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font;
@end
