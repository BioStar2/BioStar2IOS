//
//  SimpleModel.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 8..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleModel : NSObject <NSCopying>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, assign) BOOL isSelected;

@end
