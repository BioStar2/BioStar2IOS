//
//  UserFaceTemplateList.h
//  BiostarMobile
//
//  Created by 정의석 on 2017. 3. 9..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaceTemplate.h"

@interface UserFaceTemplateList : NSObject

@property (nonatomic, strong) NSArray <FaceTemplate*> *face_template_list;

@end
