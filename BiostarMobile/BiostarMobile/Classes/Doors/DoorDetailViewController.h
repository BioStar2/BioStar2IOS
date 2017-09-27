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
#import "DoorControlPopupViewController.h"
#import "MonitoringViewController.h"
#import "EventProvider.h"
#import "MonitorFilterViewController.h"
#import "PreferenceProvider.h"
#import "OneButtonPopupViewController.h"

@protocol DoorDetailViewControllerDelegate <NSObject>

@optional

- (void)refreshDoorList;

@end

@interface DoorDetailViewController : BaseViewController
{
    
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UITableView *detailTableView;
    __weak IBOutlet UILabel *doorMainDec;
    __weak IBOutlet UILabel *doorSubDec;
    __weak IBOutlet UIImageView *doorImage;
    __weak IBOutlet UIButton *doorControlButton;
    
    ListDoorItem *currentDoor;
    BOOL needToReloadDoorList;
    DoorProvider *doorProvider;
    NSInteger menuIndex;
    NSInteger doorID;
}

@property (assign, nonatomic) id <DoorDetailViewControllerDelegate> delegate;


- (IBAction)moveToBack:(id)sender;
- (IBAction)showDoorController:(id)sender;
- (void)setDoorInfo:(ListDoorItem*)door;
- (void)getDoor:(NSInteger)searchDoorID;
- (void)getSelectedDoor:(NSInteger)selectedDoorID;  //도어 메인외에 다른 컨트롤러에서 진입할때
- (void)controlDoorOperator:(NSInteger)index;
- (void)requestOpen:(NSInteger)openDoorID phoneNumber:(NSString*)phoneNumber;
- (NSString*)getToastContent;
- (NSString*)getErrorToastContent:(NSString *)message;
- (void)showErrorPopup:(NSString*)errorMessage;
- (void)showSuccessPopup:(NSString*)title message:(NSString*)message;
@end
