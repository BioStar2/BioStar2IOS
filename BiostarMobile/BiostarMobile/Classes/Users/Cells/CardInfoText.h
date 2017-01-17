//
//  CardInfoText.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 8..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "CardAddInfoCell.h"
#import "CommonUtil.h"
#import "PreferenceProvider.h"
#import "SearchResultDevice.h"
#import "NSString+EnumParser.h"

@protocol CardInfoTextCellDelegate <NSObject>

@optional

- (void)textfieldContentDidChanged:(NSString*)content;
- (void)wiegandContentDidChanged:(NSString*)content cell:(UITableViewCell*)cell;
- (void)maxValueIsOver:(NSInteger)maxValue;
- (void)zeroValueNotAllowed;

@end

#define CSN_MAXLENGTH 32
#define WIEGAND_MAXLENGTH 5
#define SMART_MAXLENGTH 24

@interface CardInfoText : UITableViewCell <UITextFieldDelegate>
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIImageView *accImage;
    __weak IBOutlet UILabel *contentLabel;
    __weak IBOutlet UILabel *multiSelectContentLabel;
    __weak IBOutlet UITextField *cardIDTextField;
    __weak IBOutlet UITextField *PINTextField;
    
    NSMutableArray *formatNames;
    DeviceMode deviceMode;
    NSInteger maxValue;
}

@property (nonatomic, weak) id <CardInfoTextCellDelegate> delegate;

- (void)setTitle:(NSString*)title content:(NSString*)content;
- (void)setTitle:(NSString*)title field:(NSString*)content;
- (void)setTitle:(NSString*)title field:(NSString*)content maxValue:(NSInteger)value;
- (void)setTitle:(NSString*)title smartCardType:(NSString*)cardType;
- (void)setCardInfoType:(RegistrationType)registrationType deviceMode:(DeviceMode)mode;
- (void)setOnlyContent;
- (void)setPinExist:(BOOL)pinExist;
- (void)setStartDate:(NSString*)startDate andExpireDate:(NSString*)expireDate;
- (NSString*)getTitle;
- (void)setWiegandFormat:(SearchResultDevice*)device;

@end
