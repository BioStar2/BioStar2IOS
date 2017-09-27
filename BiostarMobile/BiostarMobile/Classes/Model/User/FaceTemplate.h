//
//  FaceTemplate.h
//  BiostarMobile
//
//  Created by 정의석 on 2017. 3. 9..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FaceTemplate : NSObject

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *index;
@property (nonatomic, strong) NSString *raw_image;
@property (nonatomic, strong) NSArray <NSString*> *templates;
@property (nonatomic, assign) BOOL isSelected;
@end
