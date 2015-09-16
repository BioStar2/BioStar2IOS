    //
//  NSData+AES256.m
//  BiostarMobile
//
//  Created by 정의석 on 2015. 3. 23..
//  Copyright (c) 2015년 suprema. All rights reserved.
//

#import "NSData+AES256.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (AES256)

- (NSData*)AES256EncryptWithKey:(NSString*)key withIV:(NSString*)IV
{
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256 + 1];
    // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr));
    
    NSData *keyData = [[NSData alloc] initWithBase64EncodedString:key options:NSUTF8StringEncoding];
    Byte *keyByte = (Byte*) [keyData bytes];
    
    // fetch key data
    for (int i = 0; i < keyData.length; i++)
    {
        keyPtr[i] = (int)keyByte[i];
    }
    
    // room for terminator (unused)
    char ivPtr[kCCKeySizeAES128 + 1];
    // fill with zeroes (for padding)
    bzero(ivPtr, sizeof(ivPtr));
    
    NSData *IVData = [[NSData alloc] initWithBase64EncodedString:IV options:NSUTF8StringEncoding];
    Byte *IVByte = (Byte*) [IVData bytes];
    // fetch IV data
    for (int i = 0; i < kCCBlockSizeAES128; i++)
    {
        ivPtr[i] = IVByte[i];
    }
    
    NSUInteger dataLength = [self length];
    
    
    //See the doc: For block ciphers, the output size will always be less than or
    
    //equal to the input size plus the size of one block.
    
    //That's why we need to add the size of one block here
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    size_t numBytesEncrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          ivPtr
                                          /* initialization vector (optional) */
                                          ,
                                          [self bytes], dataLength,
                                          /* input */
                                          buffer, bufferSize,
                                          /* output */
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess)
    {
        
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    //free the buffer;
    return nil;
}

- (NSData*)AES256DecryptWithKey:(NSString*)key withIV:(NSString*)IV
{
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256 + 1];
    // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr));
    // fill with zeroes (for padding)
    
    NSData *keyData = [[NSData alloc] initWithBase64EncodedString:key options:NSUTF8StringEncoding];
    Byte *keyByte = (Byte*) [keyData bytes];
    
    // fetch key data
    //[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    for (int i = 0; i < keyData.length; i++)
    {
        //NSLog(@"keyByte : %d", keyByte[i]);
        keyPtr[i] = (int)keyByte[i];
    }
    
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char ivPtr[kCCKeySizeAES128 + 1];
    // room for terminator (unused)
    bzero(ivPtr, sizeof(ivPtr));
    // fill with zeroes (for padding)
    NSData *IVData = [[NSData alloc] initWithBase64EncodedString:IV options:NSUTF8StringEncoding];
    Byte *IVByte = (Byte*) [IVData bytes];
    
    // fetch IV data
    for (int i = 0; i < kCCBlockSizeAES128; i++)
    {
        //NSLog(@"IVByte : %d", IVByte[i]);
        ivPtr[i] = IVByte[i];
    }
    //[IV getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    
    //See the doc: For block ciphers, the output size will always be less than or
    
    //equal to the input size plus the size of one block.
    
    //That's why we need to add the size of one block here
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    size_t numBytesDecrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          ivPtr
                                          /* initialization vector (optional) */
                                          ,
                                          [self bytes], dataLength,
                                          /* input */
                                          buffer, bufferSize,
                                          /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess)
    {
        
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer); 
    //free the buffer;
    return nil;
}

- (NSData*)AES256EncryptWithKey:(NSString*)key {
    
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256 + 1];
    // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr));
    // fill with zeroes (for padding)
    
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    
    //See the doc: For block ciphers, the output size will always be less than or
    
    //equal to the input size plus the size of one block.
    
    //That's why we need to add the size of one block here
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    size_t numBytesEncrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL
    /* initialization vector (optional) */
                                          ,
                                          [self bytes], dataLength,
    /* input */
                                          buffer, bufferSize,
    /* output */
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess)
    {
        
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    //free the buffer;
    return nil;
}

- (NSData*)AES256DecryptWithKey:(NSString*)key {
    
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256 + 1];
    // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr));
    // fill with zeroes (for padding)
    
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    
    //See the doc: For block ciphers, the output size will always be less than or
    
    //equal to the input size plus the size of one block.
    
    //That's why we need to add the size of one block here
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    size_t numBytesDecrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL
    /* initialization vector (optional) */
                                          ,
                                          [self bytes], dataLength,
    /* input */
                                          buffer, bufferSize,
    /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess)
    {
        
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer); 
    //free the buffer;
    return nil;
}
@end
