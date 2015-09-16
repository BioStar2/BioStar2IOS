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
#import "DoorDetailCell.h"
#import "AuthProvider.h"
#import "BaseViewController.h"
#import "DoorProvider.h"
#import "ListSubInfoPopupViewController.h"
#import "ImagePopupViewController.h"
#import "MonitoringViewController.h"
#import "EventProvider.h"
#import "MonitorFilterViewController.h"

@interface DoorDetailViewController : BaseViewController <DoorProviderDelegate, ListSubInfoPopupDelegate, ImagePopupDelegate>
{
    
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UITableView *detailTableView;
    __weak IBOutlet UILabel *doorMainDec;
    __weak IBOutlet UILabel *doorSubDec;
    __weak IBOutlet UIImageView *doorImage;
    __weak IBOutlet UIButton *doorControlButton;
    __weak IBOutlet UIButton *logImageButton;
    __weak IBOutlet UILabel *logLabel;
    __weak IBOutlet UIButton *logLabelButton;
    
    NSDictionary *doorDic;
    DoorProvider *doorProvider;
    BOOL isMainRequest;
    NSInteger menuIndex;
    NSInteger doorID;
}

- (IBAction)moveToLog:(id)sender;
- (IBAction)moveToBack:(id)sender;
- (IBAction)showDoorController:(id)sender;
- (void)setDoorInfo:(NSDictionary*)info;
- (void)getSelectedDoor:(NSInteger)selectedDoorID;  //도어 메인외에 다른 컨트롤러에서 진입할때
- (void)controlDoorOperator:(NSInteger)index;
- (NSString*)getToastContent;
@end
