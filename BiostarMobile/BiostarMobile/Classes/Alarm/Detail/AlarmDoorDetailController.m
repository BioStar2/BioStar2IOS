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
    // Do any additional setup after loading the view.
    openTimeArray = [[NSMutableArray alloc] init];
    
    doorProvider = [[DoorProvider alloc] init];
    doorProvider.delegate = self;
    menuIndex = NOT_SELECTED;
    isEventSearch = NO;
    isFoundDoor = NO;
    
    // 알림시간 가져오기 위해서 필요함.
    eventProvider = [[EventProvider alloc] init];
    eventProvider.delegate = self;
    condition = [[NSMutableDictionary alloc] init];
    
    if (self.detailInfo)
    {
        // 출입문 열림 시간 가져오기
        NSDictionary *tempDoorDic = [[NSMutableDictionary alloc] initWithDictionary:[[[self.detailInfo objectForKey:@"event"] objectForKey:@"door_open_request"] objectForKey:@"door"]];
        doorID = [[tempDoorDic objectForKey:@"id"] integerValue];
        [doorProvider getDoor:doorID];
        isMainRequest = YES;
        [self startLoading:self];
        
        titleLabel.text = [[[self.detailInfo objectForKey:@"event"] objectForKey:@"door_open_request"] objectForKey:@"title"];
        doorDescription.text = [[[self.detailInfo objectForKey:@"event"] objectForKey:@"door_open_request"] objectForKey:@"message"];
        
        userDic = [[NSMutableDictionary alloc] initWithDictionary:[[[self.detailInfo objectForKey:@"event"] objectForKey:@"door_open_request"] objectForKey:@"request_user"]];
        NSString *phoneNumber = [[[self.detailInfo objectForKey:@"event"] objectForKey:@"door_open_request"] objectForKey:@"contact_phone_number"];
        if (nil != phoneNumber)
        {
            [userDic setObject:phoneNumber forKey:@"contact_phone_number"];
        }
        
        doorNameLabel.text = [tempDoorDic objectForKey:@"name"];
    }
}

- (void)searchEventForNotiTime
{
    [self setDefaultPeriod];
    [self setDefaultEventType];
    [self setDefaultDevice];
    
    [eventProvider searchEvent:condition offset:0 limit:1000];
}

- (void)setDefaultEventType
{
    NSArray *eventMessages = [eventProvider getEventMessages];
    
    NSDictionary *doorOpenEvent = nil;
    
    for (NSDictionary *event in eventMessages)
    {
        NSString *name = [event objectForKey:@"name"];
        if ([name isEqualToString:@"OPEN"])
        {
            doorOpenEvent = event;
        }
    }
    
    NSArray *values = @[[NSString stringWithFormat:@"%ld", (long)[[doorOpenEvent objectForKey:@"code"] integerValue]]];
    [condition setObject:values forKey:@"event_type_code"];
}

- (void)setDefaultPeriod
{
    //NSDate *date = [NSDate date];
    NSDate *date = [CommonUtil dateFromString:[_detailInfo objectForKey:@"event_datetime"]  originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
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
    
    [condition setObject:@[startDateString, expireDateString] forKey:@"datetime"];
}

- (void)setDefaultDevice
{
    NSDictionary *entryDevice = [doorDic objectForKey:@"entry_device"];
    NSDictionary *exitDevice = [doorDic objectForKey:@"exit_device"];
    NSDictionary *doorRelay = [[doorDic objectForKey:@"door_relay"] objectForKey:@"device"];
    NSDictionary *doorSensor = [[doorDic objectForKey:@"door_sensor"] objectForKey:@"device"];
    NSDictionary *exitButton = [[doorDic objectForKey:@"exit_button"] objectForKey:@"device"];
    
    NSMutableArray *deviceIDs = [[NSMutableArray alloc] init];
    NSMutableArray *devices = [[NSMutableArray alloc] init];
    
    if (entryDevice)
    {
        [deviceIDs addObject:[entryDevice objectForKey:@"id"]];
        [devices addObject:entryDevice];
    }
    
    if (exitDevice)
    {
        if (![deviceIDs containsObject:[exitDevice objectForKey:@"id"]])
        {
            [deviceIDs addObject:[exitDevice objectForKey:@"id"]];
            [devices addObject:exitDevice];
        }
    }
    
    if (doorRelay)
    {
        if (![deviceIDs containsObject:[doorRelay objectForKey:@"id"]])
        {
            [deviceIDs addObject:[doorRelay objectForKey:@"id"]];
            [devices addObject:doorRelay];
        }
    }
    
    if (doorSensor)
    {
        if (![deviceIDs containsObject:[doorSensor objectForKey:@"id"]])
        {
            [deviceIDs addObject:[doorSensor objectForKey:@"id"]];
            [devices addObject:doorSensor];
        }
    }
    
    if (exitButton)
    {
        if (![deviceIDs containsObject:[exitButton objectForKey:@"id"]])
        {
            [deviceIDs addObject:[exitButton objectForKey:@"id"]];
            [devices addObject:exitButton];
        }
    }
    
    [condition setObject:deviceIDs forKey:@"device_id"];
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
    ListSubInfoPopupViewController *listSubInfoPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListSubInfoPopupViewController"];
    listSubInfoPopupCtrl.delegate = self;
    listSubInfoPopupCtrl.type = DOOR_CONTROL;
    [self showPopup:listSubInfoPopupCtrl parentViewController:self parentView:self.view];
}

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
            // clear APB
            [doorProvider clearAntiPassback:[[doorDic objectForKey:@"id"] integerValue]];
            break;
        case 4:
            // clear alarm
            [doorProvider clearAlarm:[[doorDic objectForKey:@"id"] integerValue]];
            break;
            
        default:
            break;
    }
}

- (NSString*)getToastContent
{
    NSString *doorName = doorNameLabel.text;
    if ([doorName isEqualToString:@""] || nil == doorName)
    {
        doorName = [doorDic objectForKey:@"id"];
    }
    
    NSString *timeFormat;
    
    if ([[PreferenceProvider getTimeFormat] isEqualToString:@"hh:mm a"])
    {
        timeFormat = @"hh:mm:ss a";
    }
    else
    {
        timeFormat = [NSString stringWithFormat:@"%@ %@:ss",[PreferenceProvider getDateFormat], [PreferenceProvider getTimeFormat]];
    }
    
    NSString *dateString = [CommonUtil stringFromCurrentLocaleDateString:[[NSDate date] description] originDateFormat:@"YYYY-MM-dd HH:mm:ss z" transDateFormat:timeFormat];
    
    NSString *toastContent = [NSString stringWithFormat:@"%@ / %@",dateString ,doorName];
    return toastContent;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //return [alarmArray count];
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            // 알림 시간
            AlarmDoorDetailNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmDoorDetailNormalCell" forIndexPath:indexPath];
            
            NSDate *calculatedDate = [CommonUtil dateFromString:[self.detailInfo objectForKey:@"event_datetime"]  originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
            
            NSString *timeFormat;
            
            if ([[PreferenceProvider getTimeFormat] isEqualToString:@"hh:mm a"])
            {
                timeFormat = @"hh:mm:ss a";
            }
            else
            {
                timeFormat = [NSString stringWithFormat:@"%@ %@:ss",[PreferenceProvider getDateFormat], [PreferenceProvider getTimeFormat]];
            }
            
            NSString *content = [CommonUtil stringFromCurrentLocaleDateString:[calculatedDate description]
                                                originDateFormat:@"YYYY-MM-dd HH:mm:ss z"
                                                 transDateFormat:[NSString stringWithFormat:@"%@ %@",
                                                                  [PreferenceProvider getDateFormat],
                                                                  timeFormat]];
            
            [cell setContent:NSLocalizedString(@"notification_time", nil) content:content];

            return cell;
        }
            break;
        case 1:
        {
            // 출입문 열림 시간
            if (openTimeArray.count > 0)
            {
                if (openTimeArray.count == 1)
                {
                    AlarmDoorDetailNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmDoorDetailNormalCell" forIndexPath:indexPath];
                    
                    NSDictionary *tempDic = [openTimeArray objectAtIndex:0];
                    NSDate *calculatedDate = [CommonUtil localDateFromString:[tempDic objectForKey:@"datetime"] originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
                    
                    NSString *timeFormat;
                    
                    if ([[PreferenceProvider getTimeFormat] isEqualToString:@"hh:mm a"])
                    {
                        timeFormat = @"hh:mm:ss a";
                    }
                    else
                    {
                        timeFormat = [NSString stringWithFormat:@"%@ %@:ss",[PreferenceProvider getDateFormat], [PreferenceProvider getTimeFormat]];
                    };
                    
                    NSString *content = [CommonUtil stringFromCurrentLocaleDateString:[calculatedDate description]
                                                                        originDateFormat:@"YYYY-MM-dd HH:mm:ss z"
                                                                         transDateFormat:[NSString stringWithFormat:@"%@ %@",
                                                                                          [PreferenceProvider getDateFormat],
                                                                                          timeFormat]];
                    
                    [cell setContent:NSLocalizedString(@"open_door_time", nil) content:content];
                    return cell;
                }
                else
                {
                    AlarmDoorDetailAcclCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmDoorDetailAcclCell" forIndexPath:indexPath];
                    NSDictionary *tempDic = [openTimeArray objectAtIndex:0];
                    NSDate *calculatedDate = [CommonUtil localDateFromString:[tempDic objectForKey:@"datetime"] originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
                    
                    NSString *timeFormat;
                    
                    if ([[PreferenceProvider getTimeFormat] isEqualToString:@"hh:mm a"])
                    {
                        timeFormat = @"hh:mm:ss a";
                    }
                    else
                    {
                        timeFormat = [NSString stringWithFormat:@"%@ %@:ss",[PreferenceProvider getDateFormat], [PreferenceProvider getTimeFormat]];
                    }
                    
                    NSString *content = [CommonUtil stringFromCurrentLocaleDateString:[calculatedDate description]
                                                                     originDateFormat:@"YYYY-MM-dd HH:mm:ss z"
                                                                      transDateFormat:[NSString stringWithFormat:@"%@ %@",
                                                                                       [PreferenceProvider getDateFormat],
                                                                                       timeFormat]];
                    [cell setContent:NSLocalizedString(@"open_door_time", nil) content:content];
                    return cell;
                }
            }
            else
            {
                AlarmDoorDetailNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmDoorDetailNormalCell" forIndexPath:indexPath];
                [cell setContent:NSLocalizedString(@"open_door_time", nil) content:nil];
                return cell;
            }
            
            
        }
            break;
        case 2:
        {
            // 사용자
            AlarmDoorDetailAcclCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmDoorDetailAcclCell" forIndexPath:indexPath];
            NSString *content = [NSString stringWithFormat:@"%@ / %@"
                                 ,[userDic objectForKey:@"user_id"]
                                 ,[userDic objectForKey:@"name"]];
            [cell setContent:NSLocalizedString(@"user", nil) content:content];
            return cell;
        }
            break;
        case 3:
        {
            // 전화번호
            if (nil == [userDic objectForKey:@"contact_phone_number"] || [[userDic objectForKey:@"contact_phone_number"] isEqualToString:@""])
            {
                AlarmDoorDetailNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmDoorDetailNormalCell" forIndexPath:indexPath];
                [cell setContent:NSLocalizedString(@"telephone", nil) content:NSLocalizedString(@"none", nil)];
                return cell;
            }
            else
            {
                AlarmDoorDetailAcclCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmDoorDetailAcclCell" forIndexPath:indexPath];
                NSString *content = [userDic objectForKey:@"contact_phone_number"];
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
        if (openTimeArray.count > 1)
        {
            // 열림 시간이 1개 이상일때만 동작
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            AlarmTimeTablePopupController __weak *alarmTablePopupController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmTimeTablePopupController"];
            [alarmTablePopupController setTimeArray:openTimeArray];
            [self showPopup:alarmTablePopupController parentViewController:self parentView:self.view];
        }
    }
    else if (indexPath.row == 2)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UserNewDetailViewController __weak *userDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserNewDetailViewController"];
        [userDetailViewController getUserInfo:[userDic valueForKey:@"user_id"]];
        [userDetailViewController setType:VIEW_MODE];
        [self pushChildViewController:userDetailViewController parentViewController:self contentView:self.view animated:YES];
    }
    else if (indexPath.row == 3)
    {
        if ([userDic objectForKey:@"contact_phone_number"] && ![[userDic objectForKey:@"contact_phone_number"] isEqualToString:@""])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [userDic objectForKey:@"contact_phone_number"]]]];
        }
    }
}

#pragma mark - ListSubInfoPopupDelegate

- (void)confirmDoorControl:(NSInteger)index
{
    [self controlDoorOperator:index];
}

#pragma mark - DoorProviderDelegate

- (void)requestGetDoorDidFinish:(NSDictionary*)door
{
    isFoundDoor = YES;
    doorDic = [[NSMutableDictionary alloc] initWithDictionary:door];
    isMainRequest = YES;
    isEventSearch = YES;
    [self searchEventForNotiTime];
}

- (void)requestOpenDoorDidFinish:(NSDictionary*)result
{
    
    [self finishLoading];
    [self.view makeToast:[self getToastContent]
                duration:2.0 position:CSToastPositionBottom
                   title:NSLocalizedString(@"door_is_open", nil)
                   image:[UIImage imageNamed:@"toast_popup_i_02"]];
}

- (void)requestLockDoorDidFinish:(NSDictionary *)result
{
    [self finishLoading];
    [self.view makeToast:[self getToastContent]
                duration:2.0 position:CSToastPositionBottom
                   title:NSLocalizedString(@"lock", nil)
                   image:[UIImage imageNamed:@"toast_popup_i_02"]];
}

- (void)requestUnlockDoorDidFinish:(NSDictionary *)result
{
    [self finishLoading];
    [self.view makeToast:[self getToastContent]
                duration:2.0 position:CSToastPositionBottom
                   title:NSLocalizedString(@"unlock", nil)
                   image:[UIImage imageNamed:@"toast_popup_i_02"]];
}

- (void)requestClearArarmDidFinish:(NSDictionary *)result
{
    [self finishLoading];
    [self.view makeToast:[self getToastContent]
                duration:2.0 position:CSToastPositionBottom
                   title:NSLocalizedString(@"clear_alarm", nil)
                   image:[UIImage imageNamed:@"toast_popup_i_02"]];
}

- (void)requestClearAntiPassBackDidFinish:(NSDictionary *)result
{
    [self finishLoading];
    [self.view makeToast:[self getToastContent]
                duration:2.0 position:CSToastPositionBottom
                   title:NSLocalizedString(@"clear_apb", nil)
                   image:[UIImage imageNamed:@"toast_popup_i_02"]];
}

- (void)requestAskOpenDoorDidFinish:(NSDictionary *)result
{
    [self finishLoading];
    [self.view makeToast:[self getToastContent]
                duration:2.0 position:CSToastPositionBottom
                   title:NSLocalizedString(@"request_open_sent", nil)
                   image:[UIImage imageNamed:@"toast_popup_i_02"]];
}

- (void)requestDoorProviderDidFail:(NSDictionary*)errDic
{
    [self finishLoading];
    
    if (isMainRequest)
    {
        isFoundDoor = NO;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:[errDic objectForKey:@"message"]];
        imagePopupCtrl.delegate = self;
        imagePopupCtrl.type = MAIN_REQUEST_FAIL;
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
    }
    else
    {
        [self.view makeToast:NSLocalizedString(@"fail", nil)
                    duration:2.0
                    position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_02"]];
    }
    
}

#pragma mark - ImagePopupDelegate

- (void)confirmImagePopup
{
    isMainRequest = YES;
    
    if (isEventSearch)
    {
        [self searchEventForNotiTime];
    }
    else
    {
        [doorProvider getDoor:doorID];
    }
    
    [self startLoading:self];
}

- (void)cancelImagePopup
{
    if (isMainRequest)
    {
        if (isFoundDoor)
        {
            [self moveToBack:nil];
        }
        else
        {
            // 도어 찾지 못했을때
            [logImageButton setHidden:YES];
            [logButton setHidden:YES];
            [logLabel setHidden:YES];
            [doorControlButton setEnabled:NO];
        }
        
    }
}

#pragma mark - EventProviderDelegate

- (void)requestSearchEventDidFinish:(NSArray*)eventArray totalCount:(NSInteger)count
{
    [self finishLoading];
    [openTimeArray addObjectsFromArray:eventArray];
    [detailTableView reloadData];
}

- (void)requestEventProviderDidFail:(NSDictionary*)errDic
{
    [self finishLoading];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
    [imagePopupCtrl setContent:[errDic objectForKey:@"message"]];
    imagePopupCtrl.delegate = self;
    imagePopupCtrl.type = MAIN_REQUEST_FAIL;
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
}

@end
