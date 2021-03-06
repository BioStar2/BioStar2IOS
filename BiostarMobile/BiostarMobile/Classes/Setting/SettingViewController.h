/*
 * Copyright 2015 Suprema(biostar2@suprema.co.kr)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "SectionCell.h"
#import "VersionCell.h"
#import "TimezoneCell.h"
#import "DateTimeCell.h"
#import "SwitchCell.h"
#import "BLESettingCell.h"
#import "PreferenceProvider.h"
#import "AuthProvider.h"
#import "DateTimeFormatPopupViewController.h"
#import "OneButtonPopupViewController.h"
#import "ImagePopupViewController.h"
#import "BLESwtichCell.h"
#import "BLEDistanceCell.h"

@interface SettingViewController : BaseViewController <BLESettingCellDelegate, BLESwtichCellDelegate, BLEDistanceCellDelegate>
{
    __weak IBOutlet UITableView *settingTableView;
    __weak IBOutlet UILabel *titleLabel;
    PreferenceProvider *provider;
    BOOL hasNewVersion;
    
    
}

@property (strong, nonatomic) Setting *setting;
@property (strong, nonatomic) NSString *userID;
@property (assign, nonatomic) BOOL BLEisOn;
@property (assign, nonatomic) BOOL justTurnOnUsage;

@property (assign, nonatomic) NSUInteger BLEdistance;

- (void)getPreferencd;
- (void)getAppVersions;
- (IBAction)moveToBack:(id)sender;
- (IBAction)switchDidChangedValue:(UISwitch *)sender;
- (IBAction)saveSettingData:(id)sender;

@end
