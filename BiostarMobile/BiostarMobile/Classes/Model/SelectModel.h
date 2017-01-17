//
//  SelectModel.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 4..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SelectModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, assign) NSInteger type;

@end
