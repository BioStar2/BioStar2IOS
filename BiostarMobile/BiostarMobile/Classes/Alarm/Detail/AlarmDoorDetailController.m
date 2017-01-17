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

#import "AlarmDoorDetailController.h"

@interface AlarmDoorDetailController ()

@end

@implementation AlarmDoorDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSharedViewController:self];
    // Do any additional setup after loading the view.
    
    doorProvider = [[DoorProvider alloc] init];
    menuIndex = NOT_SELECTED;
    
    
    // 알림시간 가져오기 위해서 필요함.
    eventProvider = [[EventProvider alloc] init];
    searchQuery = [[EventQuery alloc] init];
    
    if ([AuthProvider hasWritePermission:DOOR_PERMISSION])
    {
        [doorControlButton setEnabled:YES];
    }
    else
    {
        if ([AuthProvider hasWritePermission:MONITORING_PERMISSION] &&
            [AuthProvider hasReadPermission:DOOR_PERMISSION])
        {
            [doorControlButton setEnabled:YES];
        }
        else
        {
            [doorControlButton setEnabled:NO];
        }
    }
    
    if (self.detailInfo)
    {
        // 출입문 열림 시간 가져오기
        SimpleModel * door = self.detailInfo.event.door_open_request.door;
        doorID = [door.id integerValue];
        
        if ([PreferenceProvider isUpperVersion])
        {
            if (nil == door)
            {
                [logImageButton setHidden:YES];
                [logButton setHidden:YES];
                [logLabel setHidden:YES];
                [doorControlButton setEnabled:NO];
            }
            else
            {
                if ([AuthProvider hasReadPermission:DOOR_PERMISSION])
                {
                    [self getDoor:doorID];
                }
                else
                {
                    [logImageButton setHidden:YES];
                    [logButton setHidden:YES];
                    [logLabel setHidden:YES];
                    [doorControlButton setEnabled:NO];
                }
            }
            
        }
        else
        {
            [self getDoor:doorID];
        }
        
        
        titleLabel.text = NSLocalizedString(self.detailInfo.event.door_open_request.title_loc_key, nil);
        
        NSArray *args = self.detailInfo.event.door_open_request.loc_args;
        
        if (nil != args)
        {
            NSRange range = NSMakeRange(0, [args count]);
            NSMutableData* data = [NSMutableData dataWithLength: sizeof(id) * [args count]];
            [args getObjects: (__unsafe_unretained id *)data.mutableBytes range:range];
            
            NSString *content = [[NSString alloc] initWithFormat:NSLocalizedString(@"notificationType.message.doorOpenRequest", nil) arguments:data.mutableBytes];
            doorDescription.text = content;
        }
        else
            doorDescription.text = self.detailInfo.event.door_open_request.message;
        
        
        user = self.detailInfo.event.door_open_request.request_user;
        
        phoneNumber = self.detailInfo.event.door_open_request.contact_phone_number;
        
    }
    else
    {
        // 디테일 인포 없을때
        [logImageButton setHidden:YES];
        [logButton setHidden:YES];
        [logLabel setHidden:YES];
        [doorControlButton setEnabled:NO];
    }
}

- (void)getDoor:(NSInteger)searchDoorID
{
    
    [self startLoading:self];
    [doorProvider getDoor:searchDoorID completeBlock:^(ListDoorItem *door) {
        [self finishLoading];
        
        searchedDoor = door;
        doorNameLabel.text = door.name;
        [self setDefaultPeriod];
        [self setDefaultEventType];
        [self setDefaultDevice];
        
    } onError:^(Response *error) {
        [self finishLoading];
        
        if ([error.status_code isEqualToString:@"DOOR_NOT_FOUND"])
        {
            // 도어 찾지 못했을때
            [logImageButton setHidden:YES];
            [logButton setHidden:YES];
            [logLabel setHidden:YES];
            [doorControlButton setEnabled:NO];
        }
        else
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
            imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
            [imagePopupCtrl setContent:error.message];
            imagePopupCtrl.type = MAIN_REQUEST_FAIL;
            [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
            
            [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
                if (isConfirm)
                {
                    [self getDoor:doorID];
                }
                
            }];
        }
        
    }];
}

- (void)setDefaultEventType
{
    NSArray <EventType *>*eventTypes = [eventProvider getEventTypes];
    
    EventType *doorOpenEvent = nil;
    
    for (EventType *eventType in eventTypes)
    {
        NSString *name = eventType.name;
        if ([name isEqualToString:@"OPEN"])
        {
            doorOpenEvent = eventType;
        }
    }
    
    NSArray *values = @[[NSString stringWithFormat:@"%ld", (long)doorOpenEvent.code]];
    searchQuery.event_type_code = values;
}

- (void)setDefaultPeriod
{
    //NSDate *date = [NSDate date];
    NSDate *date = [CommonUtil dateFromString:self.detailInfo.event_datetime  originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date];
    
    NSDateComponents *newComponents = [[NSDateComponents alloc] init];
    [newComponents setTimeZone:[NSTimeZone localTimeZone]];
    [newComponents setYear:dateComponents.year];
    [newComponents setMonth:dateComponents.month];
    [newComponents setDay:dateComponents.day];
    [newComponents setHour:dateComponents.hour - 3];
    [newComponents setMinute:dateComponents.minute];
    [newComponents setSecond:dateComponents.second];
    
    NSDate *startDate = [calendar dateFromComponents:newComponents];
    NSString *startDateStr = [startDate description];
    
    NSString *startDateString = [CommonUtil stringFromUTCDateToCurrentDateString:startDateStr originDateFormat:@"YYYY-MM-dd HH:mm:ss z" transDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    
    // expire 데이터로 변경
    [newComponents setMonth:dateComponents.month];
    [newComponents setHour:dateComponents.hour];
    [newComponents setMinute:dateComponents.minute];
    [newComponents setSecond:dateComponents.second];
    
    NSDate *expireDate = [calendar dateFromComponents:newComponents];
    NSString *expireDateStr = [expireDate description];
    
    NSString *expireDateString = [CommonUtil stringFromUTCDateToCurrentDateString:expireDateStr originDateFormat:@"YYYY-MM-dd HH:mm:ss z" transDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    
    searchQuery.datetime = @[startDateString, expireDateString];
}

- (void)setDefaultDevice
{
    SimpleModel *entryDevice = searchedDoor.entry_device;;
    SimpleModel *exitDevice = searchedDoor.exit_device;
    SimpleModel *doorRelay = searchedDoor.door_relay.device;
    SimpleModel *doorSensor = searchedDoor.door_sensor.device;
    SimpleModel *exitButton = searchedDoor.exit_button.device;
    
    NSMutableArray <NSString*> *deviceIDs = [[NSMutableArray alloc] init];
    
    if (entryDevice)
    {
        [deviceIDs addObject:entryDevice.id];
    }
    
    if (exitDevice)
    {
        if (![deviceIDs containsObject:exitDevice.id])
        {
            [deviceIDs addObject:exitDevice.id];
        }
    }
    
    if (doorRelay)
    {
        if (![deviceIDs containsObject:doorRelay.id])
        {
            [deviceIDs addObject:doorRelay.id];
        }
    }
    
    if (doorSensor)
    {
        if (![deviceIDs containsObject:doorSensor.id])
        {
            [deviceIDs addObject:doorSensor.id];
        }
    }
    
    if (exitButton)
    {
        if (![deviceIDs containsObject:exitButton.id])
        {
            [deviceIDs addObject:exitButton.id];
        }
    }
    searchQuery.device_id = deviceIDs;
    
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

- (IBAction)moveToBack:(id)sender
{
    [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
}

- (IBAction)showDoorController:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    DoorControlPopupViewController *doorControlPopup = [storyboard instantiateViewControllerWithIdentifier:@"DoorControlPopupViewController"];
    [self showPopup:doorControlPopup parentViewController:self parentView:self.view];
    
    [doorControlPopup getIndexResponse:^(NSInteger index) {
        [self controlDoorOperator:index];
    }];

}

- (IBAction)moveToLog:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MonitoringViewController *mornitorViewController = [storyboard instantiateViewControllerWithIdentifier:@"MonitoringViewController"];
    mornitorViewController.requestType = EVENT_DOOR;
    
    SimpleModel *doorRelay = searchedDoor.door_relay.device;

    SearchResultDevice *device = [[SearchResultDevice alloc] init];
    device.id = doorRelay.id;
    device.name = doorRelay.name;
    
    NSMutableArray <NSString*> *deviceIDs = [[NSMutableArray alloc] init];
    NSMutableArray <SearchResultDevice*> *devices = [[NSMutableArray alloc] init];
    
    if (doorRelay)
    {
        [deviceIDs addObject:doorRelay.id];
        [devices addObject:device];
    }

    [mornitorViewController setDeviceCondition:deviceIDs];
    [MonitorFilterViewController setFilterDevices:devices];
    
    [self pushChildViewController:mornitorViewController parentViewController:self contentView:self.view animated:YES];
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
            [doorProvider openDoor:[searchedDoor.id integerValue] onComplete:^(Response *error) {
                
                [self finishLoading];
                
                [self.view makeToast:[self getToastContent]
                            duration:2.0 position:CSToastPositionBottom
                               title:NSLocalizedString(@"door_is_open", nil)
                               image:[UIImage imageNamed:@"toast_popup_i_02"]];
                
            } onError:^(Response *error) {
                
                [self finishLoading];
                
                [self showErrorToast:error.message];
            }];
        }
            break;
        case 1:
        {
            // lock
            [doorProvider lockDoor:[searchedDoor.id integerValue] onComplete:^(Response *error) {
                [self finishLoading];
                [self.view makeToast:[self getToastContent]
                            duration:2.0 position:CSToastPositionBottom
                               title:NSLocalizedString(@"manual_lock", nil)
                               image:[UIImage imageNamed:@"toast_popup_i_02"]];
            } onError:^(Response *error) {
                [self finishLoading];
                [self showErrorToast:error.message];
                
            }];
        }
            break;
        case 2:
        {
            // unlock
            [doorProvider unlockDoor:[searchedDoor.id integerValue] onComplete:^(Response *error) {
                [self finishLoading];
                
                [self.view makeToast:[self getToastContent]
                            duration:2.0 position:CSToastPositionBottom
                               title:NSLocalizedString(@"manual_unlock", nil)
                               image:[UIImage imageNamed:@"toast_popup_i_02"]];
            } onError:^(Response *error) {
                [self finishLoading];
                
                [self showErrorToast:error.message];
            }];
            
        }
            break;
        case 3:
        {
            // release
            [doorProvider releaseDoor:[searchedDoor.id integerValue] onComplete:^(Response *error) {
                [self finishLoading];
                
                [self.view makeToast:[self getToastContent]
                            duration:2.0 position:CSToastPositionBottom
                               title:NSLocalizedString(@"release", nil)
                               image:[UIImage imageNamed:@"toast_popup_i_02"]];
            } onError:^(Response *error) {
                [self finishLoading];
                
                [self showErrorToast:error.message];
            }];
            
        }
            break;
        case 4:
        {
            // clear APB
            [doorProvider clearAntiPassback:[searchedDoor.id integerValue] onComplete:^(Response *error) {
                [self finishLoading];
                
                [self.view makeToast:[self getToastContent]
                            duration:2.0 position:CSToastPositionBottom
                               title:NSLocalizedString(@"clear_apb", nil)
                               image:[UIImage imageNamed:@"toast_popup_i_02"]];
            } onError:^(Response *error) {
                [self finishLoading];
                
                [self showErrorToast:error.message];
            }];
            
        }
            break;
        case 5:
        {
            // clear alarm
            [doorProvider clearAlarm:[searchedDoor.id integerValue] onComplete:^(Response *error) {
                [self finishLoading];
                
                [self.view makeToast:[self getToastContent]
                            duration:2.0 position:CSToastPositionBottom
                               title:NSLocalizedString(@"clear_alarm", nil)
                               image:[UIImage imageNamed:@"toast_popup_i_02"]];
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
    
    [self.view makeToast:[self getErrorToastContent:errorMessage]
                duration:2.0 position:CSToastPositionBottom
                   title:title
                   image:[UIImage imageNamed:@"toast_popup_i_02"]];
    
}

- (NSString*)getToastContent
{
    NSString *doorName = searchedDoor.name;
    if (nil == doorName)
    {
        doorName = searchedDoor.id;
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
    NSString *doorName = searchedDoor.name;
    if (nil == doorName)
    {
        doorName = searchedDoor.id;
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            // 알림 시간
            AlarmDoorDetailNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmDoorDetailNormalCell" forIndexPath:indexPath];
            
            NSDate *calculatedDate = [CommonUtil dateFromString:self.detailInfo.event_datetime  originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
            
            NSString *timeFormat;
            
            if ([[PreferenceProvider getTimeFormat] isEqualToString:@"hh:mm a"])
            {
                timeFormat = [NSString stringWithFormat:@"%@ %@",[PreferenceProvider getDateFormat], @"hh:mm:ss a"];
            }
            else
            {
                timeFormat = [NSString stringWithFormat:@"%@ %@:ss",[PreferenceProvider getDateFormat], [PreferenceProvider getTimeFormat]];
            }
            
            NSString *content = [CommonUtil stringFromCurrentLocaleDateString:[calculatedDate description]
                                                             originDateFormat:@"YYYY-MM-dd HH:mm:ss z"
                                                              transDateFormat:timeFormat];
            
            [cell setContent:NSLocalizedString(@"notification_time", nil) content:content];

            return cell;
        }
            break;

        case 1:
        {
            // 사용자
            AlarmDoorDetailAcclCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmDoorDetailAcclCell" forIndexPath:indexPath];
            NSString *content = [NSString stringWithFormat:@"%@ / %@"
                                 ,user.user_id
                                 ,user.name];
            [cell setContent:NSLocalizedString(@"user", nil) content:content];
            return cell;
        }
            break;
        case 2:
        {
            // 전화번호
            if (nil == phoneNumber || [phoneNumber isEqualToString:@""])
            {
                AlarmDoorDetailNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmDoorDetailNormalCell" forIndexPath:indexPath];
                [cell setContent:NSLocalizedString(@"telephone", nil) content:NSLocalizedString(@"none", nil)];
                return cell;
            }
            else
            {
                AlarmDoorDetailAcclCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmDoorDetailAcclCell" forIndexPath:indexPath];
                NSString *content = phoneNumber;
                [cell setContent:NSLocalizedString(@"telephone", nil) content:content];
                return cell;
            }
        }
            break;
        default:
        {
            AlarmDoorDetailNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmDoorDetailNormalCell" forIndexPath:indexPath];
            return cell;
        }
            break;
    }
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1)
    {

        if ([AuthProvider hasReadPermission:USER_PERMISSION])
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UserNewDetailViewController __weak *userDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserNewDetailViewController"];
            [userDetailViewController getUserInfo:user.user_id];
            [userDetailViewController setType:VIEW_MODE];
            [self pushChildViewController:userDetailViewController parentViewController:self contentView:self.view animated:YES];
        }
    }
    else if (indexPath.row == 2)
    {
        if (phoneNumber && ![phoneNumber isEqualToString:@""])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNumber]]];
        }
    }
    
}


@end
