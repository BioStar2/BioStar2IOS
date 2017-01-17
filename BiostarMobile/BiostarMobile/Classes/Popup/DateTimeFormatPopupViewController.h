//
//  DateTimeFormatPopupViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 1..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "BaseViewController.h"
#import "RadioCell.h"
#import "TimeFormat.h"
#import "DateFormat.h"

@interface DateTimeFormatPopupViewController : BaseViewController
{
    __weak IBOutlet NSLayoutConstraint *containerHeightConstraint;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *totalDecLabel;
    __weak IBOutlet UILabel *totalCountLabel;
    __weak IBOutlet UITableView *listTableView;
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UIButton *confirmBtn;
    
    NSMutableArray <TimeFormat*> *timeFormats;
    NSMutableArray <DateFormat*> *dateFormats;
    BOOL isMenuSelected;
    
    TimeFormat *selectedTimeFormat;
    DateFormat *selectedDateFormat;
}

typedef enum{
    TIME_FORMAT,                // 셋팅 타임 포맷
    DATE_FORMAT,                // 셋팅 데이트 포맷
    
} SettingPopupType;

typedef void (^TimeFormatResponseBlock)(TimeFormat *timeformat);
typedef void (^DateFormatResponseBlock)(DateFormat *dateformat);

@property (nonatomic, strong) TimeFormatResponseBlock timeFormatBlock;
@property (nonatomic, strong) DateFormatResponseBlock dateFormateBlock;
@property (assign, nonatomic) SettingPopupType type;

- (void)adjustHeight:(NSInteger)count;
- (void)setTimeFormats:(NSArray*)array;
- (void)setDateFormats:(NSArray*)array;
- (void)getTimeFormatResponse:(TimeFormatResponseBlock)timeFormatBlock;
- (void)getDateFormatResponse:(DateFormatResponseBlock)dateFormateBlock;

@end
