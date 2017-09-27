//
//  FingerprintScanResult.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 4..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FingerprintScanResult : NSObject
   
@property (nonatomic, assign) int enroll_quality;
@property (nonatomic, strong) NSString *raw_image0;
@property (nonatomic, strong) NSString *template0;
@property (nonatomic, strong) NSString *template_image0;

@end
