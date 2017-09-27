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
#import "DoorControlPopupViewController.h"
#import "DoorProvider.h"
#import "AlarmDoorDetailNormalCell.h"
#import "AlarmDoorDetailAcclCell.h"
#import "ImagePopupViewController.h"
#import "MonitoringViewController.h"
#import "AlarmTimeTablePopupController.h"
#import "NSString+EnumParser.h"

@interface AlarmForcedOpenDetailController : BaseViewController
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *doorNameLabel;
    __weak IBOutlet UILabel *doorDescription;
    __weak IBOutlet UITableView *detailTableView;
    __weak IBOutlet UIButton *doorControlButton;
    __weak IBOutlet UIImageView *alarmImage;
    
    DoorProvider *doorProvider;
    SimpleModel *currentDoor;
    
    NSMutableArray *openTimeArray;
    NSInteger menuIndex;
}

@property (strong, nonatomic) GetNotification *detailInfo;
@property (assign, nonatomic) NotificationType notiType;

- (IBAction)moveToBack:(id)sender;
- (IBAction)showDoorController:(id)sender;
- (void)controlDoorOperator:(NSInteger)index;
- (NSString*)getToastContent;
- (NSString*)getErrorToastContent:(NSString *)message;
- (void)showErrorPopup:(NSString*)errorMessage;
- (void)showSuccessPopup:(NSString*)title message:(NSString*)message;
- (NSString*)getLocalizedDecription:(NSString*)key args:(NSArray*)args;


@end
