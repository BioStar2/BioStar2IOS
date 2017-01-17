//
//  FaceTemplate.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 2..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FaceTemplate : NSObject

@property (nonatomic, assign) long face_index;
@property (nonatomic, strong) NSString *template;
@property (nonatomic, assign) long template_index;


@end
