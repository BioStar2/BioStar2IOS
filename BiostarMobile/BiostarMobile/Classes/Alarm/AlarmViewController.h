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
#import "AlarmCell.h"
#import "PreferenceProvider.h"
#import "ImagePopupViewController.h"
#import "TextPopupViewController.h"
#import "AlarmDoorDetailController.h"
#import "AlarmDeviceDetailController.h"
#import "AlarmForcedOpenDetailController.h"


@interface AlarmViewController : BaseViewController <PreferenceProviderDelegate, ImagePopupDelegate, TextPopupDelegate>
{
    __weak IBOutlet UITableView *alarmTableView;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIButton *deleteButton;
    __weak IBOutlet UIButton *doneButton;
    __weak IBOutlet UIView *totalCountView;
    __weak IBOutlet UIView *deleteTotalCountView;
    __weak IBOutlet UIButton *scrollButton;
    __weak IBOutlet UILabel *totalCountLabel;
    __weak IBOutlet UILabel *deleteTotalCount;
    __weak IBOutlet UIButton *selectAllButton;
    
    BOOL isDeleteMode;
    BOOL hasNextPage;
    BOOL canScrollTop;
    BOOL isSelectedAll;
    BOOL isReadAlarm;
    
    NSInteger totalCount;
    NSInteger alarmIndex;
    NSInteger offset;
    NSInteger limit;
    NSInteger toDeletedNewAlarmCount;
    NSMutableArray *alarmArray;
    NSMutableArray *toDeleteArray;
    CGFloat firstYPosition;
    float secondYPosition;
    
    PreferenceProvider *provider;
}

- (IBAction)moveToBack:(id)sender;
- (IBAction)changeToDeleteMode:(id)sender;
- (IBAction)scrollTopOrBottom:(id)sender;
- (IBAction)deleteAlarm:(id)sender;
- (IBAction)selectAll:(id)sender;
- (void)readAlarm:(NSInteger)index;
- (void)moveToAlarmDetail:(NSDictionary*)notiInfo;

@end
