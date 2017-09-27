//
//  BLESettingCell.h
//  BiostarMobile
//
//  Created by 정의석 on 2017. 3. 6..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalDataManager.h"
#import "Common.h"
#import "UIView+Toast.h"

@protocol BLESettingCellDelegate <NSObject>

- (void)BLEuseStatusHasChanged:(BOOL)isOn;

@end

@interface BLESettingCell : UITableViewCell
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UISwitch *settingSwitch;
}

@property (nonatomic, weak) id <BLESettingCellDelegate> delegate;
@property (nonatomic, assign) NSUInteger distanceLevel;

- (IBAction)setUseMobileCredential:(UISwitch *)sender;

- (void)setBLEUsage:(BOOL)usage;

@end
