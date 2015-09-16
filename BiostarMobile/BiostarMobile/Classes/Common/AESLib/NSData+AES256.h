//
//  NSData+AES256.h
//  BiostarMobile
//
//  Created by 정의석 on 2015. 3. 23..
//  Copyright (c) 2015년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NSData (AES256)
- (NSData*)AES256EncryptWithKey:(NSString*)key;
- (NSData*)AES256DecryptWithKey:(NSString*)key;
- (NSData*)AES256EncryptWithKey:(NSString*)key withIV:(NSString*)IV;
- (NSData*)AES256DecryptWithKey:(NSString*)key withIV:(NSString*)IV;
@end
