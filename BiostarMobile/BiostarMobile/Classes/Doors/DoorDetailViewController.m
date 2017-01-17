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

#import "DoorDetailViewController.h"

@interface DoorDetailViewController ()

@end

@implementation DoorDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setSharedViewController:self];
    doorProvider = [[DoorProvider alloc] init];
    menuIndex = NOT_SELECTED;
    needToReloadDoorList = NO;
    
    if ([AuthProvider hasWritePermission:DOOR_PERMISSION])
    {
        [doorControlButton setTitle:NSLocalizedString(@"door_control", nil) forState:UIControlStateNormal];
    }
    else
    {
        if ([AuthProvider hasWritePermission:MONITORING_PERMISSION] && [AuthProvider hasReadPermission:DOOR_PERMISSION])
        {
            [doorControlButton setTitle:NSLocalizedString(@"door_control", nil) forState:UIControlStateNormal];
        }
        else
        {
            [doorControlButton setTitle:NSLocalizedString(@"request_open", nil) forState:UIControlStateNormal];
        }
    }
        
    
    
    if ([AuthProvider hasReadPermission:MONITORING_PERMISSION])
    {
        [logImageButton setHidden:NO];
        [logLabelButton setHidden:NO];
        [logLabel setHidden:NO];
    }
    else
    {
        [logImageButton setHidden:YES];
        [logLabelButton setHidden:YES];
        [logLabel setHidden:YES];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)moveToLog:(id)sender
{
#warning 릴레이 없을 경우 모든 이벤트 다 가져옴 확인 필요
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MonitoringViewController *mornitorViewController = [storyboard instantiateViewControllerWithIdentifier:@"MonitoringViewController"];
    mornitorViewController.requestType = EVENT_DOOR;
    
    
    NSMutableArray <NSString *> *deviceIDs = [[NSMutableArray alloc] init];
    NSMutableArray <SearchResultDevice *> *devices = [[NSMutableArray alloc] init];
    
    if (currentDoor.door_relay)
    {
        SearchResultDevice *device = [[SearchResultDevice alloc] init];
        device.id = currentDoor.door_relay.device.id;
        device.name = currentDoor.door_relay.device.name;
        
        [deviceIDs addObject:currentDoor.door_relay.device.id];
        [devices addObject:device];
        [mornitorViewController setDeviceCondition:deviceIDs];
        [MonitorFilterViewController setFilterDevices:devices];
    }
    else
    {
        [mornitorViewController setDeviceCondition:nil];
        [MonitorFilterViewController setFilterDevices:nil];
    }
    
    [self pushChildViewController:mornitorViewController parentViewController:self contentView:self.view animated:YES];
}

- (IBAction)moveToBack:(id)sender
{
    if (needToReloadDoorList)
    {
        if ([self.delegate respondsToSelector:@selector(refreshDoorList)])
        {
            [self.delegate refreshDoorList];
        }
    }
    [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
}

- (IBAction)showDoorController:(id)sender
{
    
    NSString *controlBtnTitle = doorControlButton.titleLabel.text;
    if ([controlBtnTitle isEqualToString:NSLocalizedString(@"door_control", nil)])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        DoorControlPopupViewController *doorControlPopup = [storyboard instantiateViewControllerWithIdentifier:@"DoorControlPopupViewController"];
        [self showPopup:doorControlPopup parentViewController:self parentView:self.view];
        
        [doorControlPopup getIndexResponse:^(NSInteger index) {
            [self controlDoorOperator:index];
        }];
    }
    else
    {
        User *user = [AuthProvider getLoginUserInfo];
        NSString *phoneNumber = user.phone_number;
        
        [self requestOpen:[currentDoor.id integerValue] phoneNumber:phoneNumber];
    }
    
    
}

- (void)requestOpen:(NSInteger)openDoorID phoneNumber:(NSString*)phoneNumber
{
    [self startLoading:self];
    
    [doorProvider reqeustOpen:openDoorID phoneNumber:phoneNumber onComplete:^(Response *error) {
        
        [self finishLoading];
        
        needToReloadDoorList = YES;
        
        [self.view makeToast:[self getToastContent]
                    duration:2.0 position:CSToastPositionBottom
                       title:NSLocalizedString(@"request_open_sent", nil)
                       image:[UIImage imageNamed:@"toast_popup_i_02"]];
        
        [self getSelectedDoor:doorID];

        
    } onError:^(Response *error) {
        
        [self finishLoading];
        NSString *title = NSLocalizedString(@"request_open_fail", nil);
        
        [self.view makeToast:[self getErrorToastContent:error.message]
                    duration:2.0 position:CSToastPositionBottom
                       title:title
                       image:[UIImage imageNamed:@"toast_popup_i_02"]];
        
    }];
    
}
- (void)setDoorInfo:(ListDoorItem*)door
{
    currentDoor = door;
    doorID = [door.id integerValue];
    [detailTableView reloadData];
    titleLabel.text = door.name;
    doorMainDec.text = door.name;
    doorSubDec.text = door.door_description;
    
    DoorStatus *status = door.status;
    
    if (status.normal ||status.apb_failed)
    {
        // 초록
        doorImage.image = [UIImage imageNamed:@"ic_event_door_01"];
    }
    
    if (status.locked || status.unlocked ||
        status.held_opened || status.scheduleLocked ||
        status.scheduleUnlocked || status.operatorLocked ||
        status.unlocked)
    {
        // 노란
        doorImage.image = [UIImage imageNamed:@"ic_event_door_03"];
    }
    
    if (status.disconnected || status.forced_open ||
        status.emergencyLocked || status.emergencyUnlocked)
    {
        // 빨간
        doorImage.image = [UIImage imageNamed:@"ic_event_door_02"];
    }
}

- (void)getDoor:(NSInteger)searchDoorID
{
    [self startLoading:self];
    [doorProvider getDoor:searchDoorID completeBlock:^(ListDoorItem *door) {
        [self finishLoading];
        currentDoor = door;
        [self setDoorInfo:door];
        
    } onError:^(Response *error) {
        [self finishLoading];
        
        [self.view makeToast:NSLocalizedString(@"fail", nil)
                    duration:2.0
                    position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_02"]];
    }];
    
}

- (void)getSelectedDoor:(NSInteger)selectedDoorID
{
    doorID = selectedDoorID;
    [self getDoor:doorID];
}

- (NSString*)getToastContent
{
    NSString *doorName = currentDoor.name;
    if ([doorName isEqualToString:@""] || nil == doorName)
    {
        doorName = currentDoor.id;
    }
    
    NSString *timeFormat;
    
    if ([[PreferenceProvider getTimeFormat] isEqualToString:@"hh:mm a"])
    {
        timeFormat = [NSString stringWithFormat:@"%@ %@",[PreferenceProvider getDateFormat], @"hh:mm:ss a"];
    }
    else
    {
        timeFormat = [NSString stringWithFormat:@"%@ %@:ss",[PreferenceProvider getDateFormat], [PreferenceProvider getTimeFormat]];
    }

    NSString *dateString = [CommonUtil stringFromCurrentLocaleDateString:[[NSDate date] description] originDateFormat:@"YYYY-MM-dd HH:mm:ss z" transDateFormat:timeFormat];
    

    NSString *toastContent = [NSString stringWithFormat:@"%@ / %@",dateString ,doorName];
    return toastContent;
}

- (NSString*)getErrorToastContent:(NSString *)message
{
    NSString *doorName = currentDoor.name;
    if ([doorName isEqualToString:@""] || nil == doorName)
    {
        doorName = currentDoor.id;
    }
    
    NSString *timeFormat;
    
    if ([[PreferenceProvider getTimeFormat] isEqualToString:@"hh:mm a"])
    {
        timeFormat = [NSString stringWithFormat:@"%@ %@",[PreferenceProvider getDateFormat], @"hh:mm:ss a"];
    }
    else
    {
        timeFormat = [NSString stringWithFormat:@"%@ %@:ss",[PreferenceProvider getDateFormat], [PreferenceProvider getTimeFormat]];
    }
    
    NSString *dateString = [CommonUtil stringFromCurrentLocaleDateString:[[NSDate date] description] originDateFormat:@"YYYY-MM-dd HH:mm:ss z" transDateFormat:timeFormat];
    
    
    NSString *toastContent = [NSString stringWithFormat:@"%@ / %@ \n%@",dateString ,doorName, message];
    return toastContent;
    
}

- (void)controlDoorOperator:(NSInteger)index
{
    if (index == NOT_SELECTED)
    {
        return;
    }
    
    [self startLoading:self];
    
    menuIndex = index;
    switch (index)
    {
        case 0:
        {
            // open
            [doorProvider openDoor:[currentDoor.id integerValue] onComplete:^(Response *error) {
                [self finishLoading];
                
                needToReloadDoorList = YES;
                
                [self.view makeToast:[self getToastContent]
                            duration:2.0 position:CSToastPositionBottom
                               title:NSLocalizedString(@"door_is_open", nil)
                               image:[UIImage imageNamed:@"toast_popup_i_02"]];
                
                [self getSelectedDoor:doorID];
                
            } onError:^(Response *error) {
                [self finishLoading];
                
                [self showErrorToast:error.message];
            }];
            
        }
            break;
        case 1:
        {
            // lock
            [doorProvider lockDoor:[currentDoor.id integerValue] onComplete:^(Response *error) {
                [self finishLoading];
                needToReloadDoorList = YES;
                [self.view makeToast:[self getToastContent]
                            duration:2.0 position:CSToastPositionBottom
                               title:NSLocalizedString(@"manual_lock", nil)
                               image:[UIImage imageNamed:@"toast_popup_i_02"]];
                [self getSelectedDoor:doorID];
            } onError:^(Response *error) {
                [self finishLoading];
                
                [self showErrorToast:error.message];
            }];
            
        }
            break;
        case 2:
        {
            // unlock
            [doorProvider unlockDoor:[currentDoor.id integerValue] onComplete:^(Response *error) {
                [self finishLoading];
                needToReloadDoorList = YES;
                [self finishLoading];
                [self.view makeToast:[self getToastContent]
                            duration:2.0 position:CSToastPositionBottom
                               title:NSLocalizedString(@"manual_unlock", nil)
                               image:[UIImage imageNamed:@"toast_popup_i_02"]];
                [self getSelectedDoor:doorID];
                
            } onError:^(Response *error) {
                [self finishLoading];
                [self showErrorToast:error.message];
            }];
            
        }
            break;
        case 3:
        {
            // release
            [doorProvider releaseDoor:[currentDoor.id integerValue] onComplete:^(Response *error) {
                [self finishLoading];
                
                needToReloadDoorList = YES;
                [self finishLoading];
                [self.view makeToast:[self getToastContent]
                            duration:2.0 position:CSToastPositionBottom
                               title:NSLocalizedString(@"release", nil)
                               image:[UIImage imageNamed:@"toast_popup_i_02"]];
                [self getSelectedDoor:doorID];
            } onError:^(Response *error) {
                [self finishLoading];
                [self showErrorToast:error.message];
            }];
            
        }
            break;
        case 4:
        {
            // clear APB
            [doorProvider clearAntiPassback:[currentDoor.id integerValue] onComplete:^(Response *error) {
                [self finishLoading];
                needToReloadDoorList = YES;
                [self finishLoading];
                [self.view makeToast:[self getToastContent]
                            duration:2.0 position:CSToastPositionBottom
                               title:NSLocalizedString(@"clear_apb", nil)
                               image:[UIImage imageNamed:@"toast_popup_i_02"]];
                [self getSelectedDoor:doorID];
            } onError:^(Response *error) {
                [self finishLoading];
                [self showErrorToast:error.message];
            }];
            
        }
            break;
        case 5:
        {
            // clear alarm
            [doorProvider clearAlarm:[currentDoor.id integerValue]  onComplete:^(Response *error) {
                [self finishLoading];
                needToReloadDoorList = YES;
                [self finishLoading];
                [self.view makeToast:[self getToastContent]
                            duration:2.0 position:CSToastPositionBottom
                               title:NSLocalizedString(@"clear_alarm", nil)
                               image:[UIImage imageNamed:@"toast_popup_i_02"]];
                [self getSelectedDoor:doorID];
            } onError:^(Response *error) {
                [self finishLoading];
                [self showErrorToast:error.message];
            }];
        }
            break;
    }
}

- (void)showErrorToast:(NSString*)errorMessage
{
    
    NSString *title = nil;
    switch (menuIndex)
    {
        case 0:
            // open
            title = NSLocalizedString(@"request_open_fail", nil);
            break;
        case 1:
            // lock
            title = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"manual_lock", nil) ,NSLocalizedString(@"fail", nil)];
            break;
        case 2:
            // unlock
            title = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"manual_unlock", nil) ,NSLocalizedString(@"fail", nil)];
            break;
        case 3:
            // release
            title = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"release", nil) ,NSLocalizedString(@"fail", nil)];
            break;
        case 4:
            // clear APB
            title = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"clear_apb", nil) ,NSLocalizedString(@"fail", nil)];
            break;
        case 5:
            // clear alarm
            title = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"clear_alarm", nil) ,NSLocalizedString(@"fail", nil)];
            break;
            
        default:
            [self.view makeToast:NSLocalizedString(@"fail", nil)
                        duration:2.0
                        position:CSToastPositionBottom
                           image:[UIImage imageNamed:@"toast_popup_i_02"]];
            break;
    }
    
    [self.view makeToast:[self getErrorToastContent:errorMessage]
                duration:2.0 position:CSToastPositionBottom
                   title:title
                   image:[UIImage imageNamed:@"toast_popup_i_02"]];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 6;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DoorDetailCell" forIndexPath:indexPath];
    DoorDetailCell *customCell = (DoorDetailCell*)cell;
    NSString *content = NSLocalizedString(@"none", nil);
    switch (indexPath.row)
    {
        case 0:
        {
            customCell.titleLabel.text = NSLocalizedString(@"entry_device", nil);
            customCell.contentLabel.text = currentDoor.entry_device.name ? currentDoor.entry_device.name : NSLocalizedString(@"none", nil);
        }
            break;
            
        case 1:
        {
            customCell.titleLabel.text = NSLocalizedString(@"exit_device", nil);
            customCell.contentLabel.text = currentDoor.exit_device.name ? currentDoor.exit_device.name : NSLocalizedString(@"none", nil);
        }
            break;
            
        case 2:
        {
            customCell.titleLabel.text = NSLocalizedString(@"door_relay", nil);
            
            if (nil != currentDoor.door_relay)
            {
                content = [NSString stringWithFormat:@"%@ %ld %@"
                           , NSLocalizedString(@"relay", nil)
                           ,(long)currentDoor.door_relay.index
                           ,currentDoor.door_relay.device.name];
            }
            customCell.contentLabel.text = content;
        }
            break;
        case 3:
        {
            customCell.titleLabel.text = NSLocalizedString(@"exit_button", nil);
            
            if (nil != currentDoor.exit_button)
            {
                content = [NSString stringWithFormat:@"%@ %ld %@"
                           ,NSLocalizedString(@"input_port", nil)
                           ,(long)currentDoor.exit_button.index
                           ,currentDoor.exit_button.device.name];
            }
            
            customCell.contentLabel.text = content;
            break;
        }
        case 4:
        {
            customCell.titleLabel.text = NSLocalizedString(@"door_sensor", nil);
            
            if (nil != currentDoor.door_sensor)
            {
                content = [NSString stringWithFormat:@"%@ %ld %@"
                           ,NSLocalizedString(@"input_port", nil)
                           ,(long)currentDoor.door_sensor.index
                           ,currentDoor.door_sensor.device.name];
            }
            customCell.contentLabel.text = content;
            
        }
            break;
            
        case 5:
        {
            customCell.titleLabel.text = NSLocalizedString(@"open_time", nil);
            
            NSInteger time = currentDoor.open_duration;
            if ( time > 59)
            {
                NSInteger minute = time / 60;
                NSInteger second = time % 60;
                
                if (second != 0)
                {
                    content = [NSString stringWithFormat:NSLocalizedString(@"%ld minute ld@ sec", nil), minute, second];
                }
                else
                {
                    content = [NSString stringWithFormat:NSLocalizedString(@"%ld minute", nil), minute];
                }
                
            }
            else
            {
                content = [NSString stringWithFormat:NSLocalizedString(@"%ld sec", nil), time];
            }
                
        
            customCell.contentLabel.text = content;
        }
            break;
        default:
            break;
    }
    
    return customCell;
    
}


@end
