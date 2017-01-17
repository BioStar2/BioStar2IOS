//
//  FingerprintTemplate.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 2..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FingerprintTemplate : NSObject

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL is_prepare_for_duress;
@property (nonatomic, strong) NSString *template0;
@property (nonatomic, strong) NSString *template1;

@end
