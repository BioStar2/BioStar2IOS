//
//  ButtonModel.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 15..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ButtonModel : NSObject

typedef NS_ENUM(NSInteger, ButtonType) {
    USER_BUTTON                     = 0,
    MONITORING_BUTTON               = 1,
    ALARM_BUTTON                    = 2,
    MYPROFILE_BUTTON                = 3,
    DOOR_BUTTON                     = 4,
    MOBILE_CARD_BUTTON              = 5
};


@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *highlightedImage;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) ButtonType type;


@end
