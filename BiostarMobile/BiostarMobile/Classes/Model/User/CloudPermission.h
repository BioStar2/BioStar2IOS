//
//  CloudPermission.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 3..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudPermission : NSObject

@property (nonatomic, strong) NSString *module;
@property (nonatomic, assign) BOOL read;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) BOOL write;

@end
