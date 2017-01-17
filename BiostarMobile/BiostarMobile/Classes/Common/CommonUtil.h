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
#import "Common.h"
#import "KeychainItemWrapper.h"

@interface CommonUtil : NSObject

/**
 *  Convert hex string to UIColor
 *
 *  @param hexString        hex color string
 *  @return UIColor
 */
+ (UIColor *)colorFromHexString:(NSString *)hexString;


/**
 *  UIImage scale
 *
 *  @param image        Original UIImage
 *  @param newSize      CGSize scale size
 *  @return UIImage
 */
+ (UIImage *)imageScale:(UIImage *)__autoreleasing image size:(CGSize)newSize;


/**
 *  UIImage compress by filesize
 *
 *  @param fileSize        file size
 *  @param image           Original image
 *  @return UIImage
 */
+ (UIImage *)imageCompress:(UIImage *)__autoreleasing image fileSize:(unsigned long)fileSize;


/**
 *  UIImage compress and convert to NSData by filesize
 *
 *  @param fileSize        file size
 *  @param image           Original image
 *  @return NSData
 */
+ (NSData *)getImageDataCompress:(UIImage *)__autoreleasing image fileSize:(unsigned long)fileSize;


/**
 *  Convert date string
 *
 *  @param dateString        date string
 *  @param originFormat      origin date string format
 *  @param transFormat       To be transformed format
 *  @return NSString
 */
// 데이터 포맷만 바꾸기
+ (NSString *)stringFromDateString:(NSString*)dateString originDateFormat:(NSString*)originFormat transDateFormat:(NSString*)transFormat;

/**
 *  Convert date string to specific locale time
 *
 *  @param dateString        date string
 *  @param originFormat      origin date string format
 *  @param transFormat       To be transformed format
 *  @param locale            specific locale
 *  @return NSString
 */
// UCT Date string 을 locale 시간대의 데이터 포맷 바꾸기
+ (NSString *)stringFromDateString:(NSString*)dateString originDateFormat:(NSString*)originFormat transDateFormat:(NSString*)transFormat targetLocale:(NSString*)locale;

/**
 *  Convert date string to current locale date
 *
 *  @param dateString        date string
 *  @param originFormat      origin date string format
 *  @param transFormat       To be transformed format
 *  @return NSString
 */
// GMT (UTC) 시간을 현지 Date String 로 바꿔주기
+ (NSString *)stringFromCurrentLocaleDateString:(NSString*)dateString originDateFormat:(NSString*)originFormat transDateFormat:(NSString*)transFormat;

/**
 *  Convert current locale date string to UTC date
 *
 *  @param UTCDateString        UTC Date String
 *  @param originFormat         origin date string format
 *  @param transFormat          To be transformed format
 *  @return NSString
 */
// 현지 Date을 GMT (UTC) Date String 로 바꿔주기
+ (NSString *)stringFromUTCDateToCurrentDateString:(NSString*)UTCDateString originDateFormat:(NSString*)originFormat transDateFormat:(NSString*)transFormat;

/**
 *  Convert Date string to NSDate (YYYY-MM-dd HH:mm:ss z)
 *
 *  @param dateString           origin Date String
 *  @param originFormat         origin date string format
 *  @return NSDate              YYYY-MM-dd HH:mm:ss z
 */
// YYYY-MM-dd HH:mm:ss z (2015-03-29 02:31:21 +0000)  Date 형식으로 변환
+ (NSDate *)dateFromString:(NSString*)dateString originDateFormat:(NSString*)originFormat;

/**
 *  Convert UTC date to currnet lacale NSDate
 *
 *  @param dateString           origin Date String
 *  @param originFormat         origin date string format
 *  @return NSDate
 */
// GMT (UTC) 시간을 현지 Date 로 바꿔주기
+ (NSDate *)localDateFromString:(NSString*)dateString originDateFormat:(NSString*)originFormat;

+ (NSDate *)dateFromstring:(NSString*)dateString timezone:(NSInteger)timezone originDateFormat:(NSString*)originFormat;

+ (NSString *)getTenRandomNumber;

+ (BOOL)matchingByRegex:(NSString*)regex withField: (NSString*)field;


// 스트링 CGSize 가져오기
+ (CGSize)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font;


+ (NSString*)getUUID;

@end
