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
    doorProvider = [[DoorProvider alloc] init];
    doorProvider.delegate = self;
    menuIndex = NOT_SELECTED;
    isMainRequest = NO;
    needToReloadDoorList = NO;
    if (![AuthProvider hasWritePermission:@"DOOR"])
    {
        [doorControlButton setTitle:NSLocalizedString(@"request_open", nil) forState:UIControlStateNormal];
    }
    
    if ([AuthProvider hasReadPermission:@"MONITORING"])
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
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MonitoringViewController *mornitorViewController = [storyboard instantiateViewControllerWithIdentifier:@"MonitoringViewController"];
    mornitorViewController.requestType = EVENT_DOOR;
    
    NSDictionary *doorRelay = [[doorDic objectForKey:@"door_relay"] objectForKey:@"device"];
    
    NSMutableArray *deviceIDs = [[NSMutableArray alloc] init];
    NSMutableArray *devices = [[NSMutableArray alloc] init];
    
    if (doorRelay)
    {
        if (![deviceIDs containsObject:[doorRelay objectForKey:@"id"]])
        {
            [deviceIDs addObject:[doorRelay objectForKey:@"id"]];
            [devices addObject:doorRelay];
        }
    }
    
    NSDictionary *deviceCondition = @{@"device_id" : deviceIDs};
    [mornitorViewController setDeviceCondition:deviceCondition];
    [MonitorFilterViewController setFilterDevices:devices];
    
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
    if (![AuthProvider hasWritePermission:@"DOOR"])
    {
        [self startLoading:self];
        NSDictionary *userDic = [AuthProvider getLoginUserInfo];
        NSString *phoneNumber = [userDic objectForKey:@"phone_number"];
        
        [doorProvider reqeustOpen:[[doorDic objectForKey:@"id"] integerValue] phoneNumber:phoneNumber];
    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ListSubInfoPopupViewController *listSubInfoPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListSubInfoPopupViewController"];
        listSubInfoPopupCtrl.delegate = self;
        listSubInfoPopupCtrl.type = DOOR_CONTROL;
        [self showPopup:listSubInfoPopupCtrl parentViewController:self parentView:self.view];
    }
}

- (void)setDoorInfo:(NSDictionary*)info
{
    doorDic = [[NSDictionary alloc] initWithDictionary:info];
    doorID = [[doorDic objectForKey:@"id"] integerValue];
    [detailTableView reloadData];
    titleLabel.text = [doorDic objectForKey:@"name"];
    doorMainDec.text = [doorDic objectForKey:@"name"];
    doorSubDec.text = [doorDic objectForKey:@"description"];
    
    NSDictionary *status = [doorDic objectForKey:@"status"];
    
    if ([[status objectForKey:@"normal"] boolValue] || [[status objectForKey:@"apb_failed"] boolValue])
    {
        // 초록
        doorImage.image = [UIImage imageNamed:@"ic_event_door_01"];
    }
    
    if ([[status objectForKey:@"locked"] boolValue] || [[status objectForKey:@"unlocked"] boolValue] ||
        [[status objectForKey:@"held_opened"] boolValue] || [[status objectForKey:@"scheduleLocked"] boolValue] ||
        [[status objectForKey:@"scheduleUnlocked"] boolValue] || [[status objectForKey:@"operatorLocked"] boolValue] ||
        [[status objectForKey:@"operatorUnlocked"] boolValue])
    {
        // 노란
        doorImage.image = [UIImage imageNamed:@"ic_event_door_03"];
    }
    
    if ([[status objectForKey:@"disconnected"] boolValue] || [[status objectForKey:@"forced_open"] boolValue] ||
        [[status objectForKey:@"emergencyLocked"] boolValue] || [[status objectForKey:@"emergencyUnlocked"] boolValue])
    {
        // 빨간
        doorImage.image = [UIImage imageNamed:@"ic_event_door_02"];
    }
}

- (void)getSelectedDoor:(NSInteger)selectedDoorID
{
    doorID = selectedDoorID;
    isMainRequest = YES;
    [doorProvider getDoor:doorID];
    [self startLoading:self];
}

- (NSString*)getToastContent
{
    NSString *doorName = [doorDic objectForKey:@"name"];
    if ([doorName isEqualToString:@""] || nil == doorName)
    {
        doorName = [doorDic objectForKey:@"id"];
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
    NSString *doorName = [doorDic objectForKey:@"name"];
    if ([doorName isEqualToString:@""] || nil == doorName)
    {
        doorName = [doorDic objectForKey:@"id"];
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
    isMainRequest = NO;
    menuIndex = index;
    switch (index)
    {
        case 0:
            // open
            [doorProvider openDoor:[[doorDic objectForKey:@"id"] integerValue]];
            break;
        case 1:
            // lock
            [doorProvider lockDoor:[[doorDic objectForKey:@"id"] integerValue]];
            break;
        case 2:
            // unlock
            [doorProvider unlockDoor:[[doorDic objectForKey:@"id"] integerValue]];
            break;
        case 3:
            // release
            [doorProvider releaseDoor:[[doorDic objectForKey:@"id"] integerValue]];
            break;
        case 4:
            // clear APB
            [doorProvider clearAntiPassback:[[doorDic objectForKey:@"id"] integerValue]];
            break;
        case 5:
            // clear alarm
            [doorProvider clearAlarm:[[doorDic objectForKey:@"id"] integerValue]];
            break;
            
        default:
            break;
    }
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
            
            if (nil != [[doorDic objectForKey:@"entry_device"] objectForKey:@"name"])
            {
                content = [[doorDic objectForKey:@"entry_device"] objectForKey:@"name"];
            }
            customCell.contentLabel.text = content;
        }
            break;
            
        case 1:
        {
            customCell.titleLabel.text = NSLocalizedString(@"exit_device", nil);
            
            if (nil != [[doorDic objectForKey:@"exit_device"] objectForKey:@"name"])
            {
                content = [[doorDic objectForKey:@"exit_device"] objectForKey:@"name"];
            }
            customCell.contentLabel.text = content;
        }
            break;
            
        case 2:
        {
            customCell.titleLabel.text = NSLocalizedString(@"door_relay", nil);
            
            if (nil != [doorDic objectForKey:@"door_relay"])
            {
                content = [NSString stringWithFormat:@"%@ %ld %@"
                           , NSLocalizedString(@"relay", nil)
                           ,(long)[[[doorDic objectForKey:@"door_relay"] objectForKey:@"index"] integerValue]
                           ,[[[doorDic objectForKey:@"door_relay"] objectForKey:@"device"] objectForKey:@"name"] ];
            }
            customCell.contentLabel.text = content;
        }
            break;
        case 3:
        {
            customCell.titleLabel.text = NSLocalizedString(@"exit_button", nil);
            
            if (nil != [doorDic objectForKey:@"exit_button"])
            {
                content = [NSString stringWithFormat:@"%@ %ld %@"
                           ,NSLocalizedString(@"input_port", nil)
                           ,(long)[[[doorDic objectForKey:@"exit_button"] objectForKey:@"index"] integerValue]
                           ,[[[doorDic objectForKey:@"exit_button"] objectForKey:@"device"] objectForKey:@"name"]];
            }
            
            customCell.contentLabel.text = content;
            break;
        }
        case 4:
        {
            customCell.titleLabel.text = NSLocalizedString(@"door_sensor", nil);
            
            if (nil != [doorDic objectForKey:@"door_sensor"])
            {
                content = [NSString stringWithFormat:@"%@ %ld %@"
                           ,NSLocalizedString(@"input_port", nil)
                           ,(long)[[[doorDic objectForKey:@"door_sensor"] objectForKey:@"index"] integerValue]
                           ,[[[doorDic objectForKey:@"door_sensor"] objectForKey:@"device"] objectForKey:@"name"]];
            }
            customCell.contentLabel.text = content;
            
        }
            break;
            
        case 5:
        {
            customCell.titleLabel.text = NSLocalizedString(@"open_time", nil);
            
            if (nil != [doorDic objectForKey:@"open_duration"])
            {
                NSInteger time = [[doorDic objectForKey:@"open_duration"] integerValue];
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
                
            }
            customCell.contentLabel.text = content;
        }
            break;
        default:
            break;
    }
    
    return customCell;
    
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


#pragma mark - DoorProviderDelegate

- (void)requestGetDoorDidFinish:(NSDictionary*)door
{
    [self setDoorInfo:door];
    [self finishLoading];
}

- (void)requestOpenDoorDidFinish:(NSDictionary*)result
{
    
    needToReloadDoorList = YES;
    [self finishLoading];
    [self.view makeToast:[self getToastContent]
                duration:2.0 position:CSToastPositionBottom
                   title:NSLocalizedString(@"door_is_open", nil)
                   image:[UIImage imageNamed:@"toast_popup_i_02"]];
    
    [self getSelectedDoor:doorID];
    
}

- (void)requestLockDoorDidFinish:(NSDictionary *)result
{
    needToReloadDoorList = YES;
    [self finishLoading];
    [self.view makeToast:[self getToastContent]
                duration:2.0 position:CSToastPositionBottom
                   title:NSLocalizedString(@"manual_lock", nil)
                   image:[UIImage imageNamed:@"toast_popup_i_02"]];
    [self getSelectedDoor:doorID];
}

- (void)requestUnlockDoorDidFinish:(NSDictionary *)result
{
    needToReloadDoorList = YES;
    [self finishLoading];
    [self.view makeToast:[self getToastContent]
                duration:2.0 position:CSToastPositionBottom
                   title:NSLocalizedString(@"manual_unlock", nil)
                   image:[UIImage imageNamed:@"toast_popup_i_02"]];
    [self getSelectedDoor:doorID];
}

- (void)requestReleaseDoorDidFinish:(NSDictionary *)result
{
    needToReloadDoorList = YES;
    [self finishLoading];
    [self.view makeToast:[self getToastContent]
                duration:2.0 position:CSToastPositionBottom
                   title:NSLocalizedString(@"release", nil)
                   image:[UIImage imageNamed:@"toast_popup_i_02"]];
    [self getSelectedDoor:doorID];
}

- (void)requestClearArarmDidFinish:(NSDictionary *)result
{
    needToReloadDoorList = YES;
    [self finishLoading];
    [self.view makeToast:[self getToastContent]
                duration:2.0 position:CSToastPositionBottom
                   title:NSLocalizedString(@"clear_alarm", nil)
                   image:[UIImage imageNamed:@"toast_popup_i_02"]];
    [self getSelectedDoor:doorID];
}

- (void)requestClearAntiPassBackDidFinish:(NSDictionary *)result
{
    needToReloadDoorList = YES;
    [self finishLoading];
    [self.view makeToast:[self getToastContent]
                duration:2.0 position:CSToastPositionBottom
                   title:NSLocalizedString(@"clear_apb", nil)
                   image:[UIImage imageNamed:@"toast_popup_i_02"]];
    [self getSelectedDoor:doorID];
}

- (void)requestAskOpenDoorDidFinish:(NSDictionary *)result
{
    needToReloadDoorList = YES;
    [self finishLoading];
    [self.view makeToast:[self getToastContent]
                duration:2.0 position:CSToastPositionBottom
                   title:NSLocalizedString(@"request_open_sent", nil)
                   image:[UIImage imageNamed:@"toast_popup_i_02"]];
    [self getSelectedDoor:doorID];
}

- (void)requestDoorProviderDidFail:(NSDictionary*)errDic
{
    [self finishLoading];
    
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
    
    [self.view makeToast:[self getErrorToastContent:[errDic objectForKey:@"message"]]
                duration:2.0 position:CSToastPositionBottom
                   title:title
                   image:[UIImage imageNamed:@"toast_popup_i_02"]];
}


#pragma mark - ListSubInfoPopupDelegate

- (void)confirmDoorControl:(NSInteger)index
{
    [self controlDoorOperator:index];
}


#pragma mark = ImagePopupDelegate

- (void)confirmImagePopup
{
    if (isMainRequest)
    {
        [doorProvider getDoor:doorID];
        [self startLoading:self];
    }
    else
    {
        [self controlDoorOperator:menuIndex];
    }
}

- (void)cancelImagePopup
{
    if (isMainRequest)
    {
        [self moveToBack:nil];
    }
}

@end
