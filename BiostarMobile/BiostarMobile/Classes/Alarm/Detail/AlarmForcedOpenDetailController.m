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

#import "AlarmForcedOpenDetailController.h"

@interface AlarmForcedOpenDetailController ()

@end

@implementation AlarmForcedOpenDetailController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    doorProvider = [[DoorProvider alloc] init];
    doorProvider.delegate = self;
    menuIndex = NOT_SELECTED;
    isMainRequest = NO;
    
    isFoundDoor = NO;
    
    // 알림시간 가져오기 위해서 필요함.
    eventProvider = [[EventProvider alloc] init];
    eventProvider.delegate = self;
    condition = [[NSMutableDictionary alloc] init];
    openTimeArray = [[NSMutableArray alloc] init];
    
    
    if (self.detailInfo)
    {
        switch (self.alarmType)
        {
            case DOOR_FORCED_OPEN:
                [self setAlarmInfo:@"door_forced_open"];
                [alarmImage setImage:[UIImage imageNamed:@"ic_event_door_02"]];
                break;
            case ZONE_APB:
                [self setAlarmInfo:@"zone_apb"];
                [alarmImage setImage:[UIImage imageNamed:@"ic_event_zone_02"]];
                break;
            case DOOR_HELD_OPEN:
                [self setAlarmInfo:@"door_held_open"];
                [alarmImage setImage:[UIImage imageNamed:@"ic_event_door_03"]];
                break;
            default:
                break;
        }
    }
}

- (void)setAlarmInfo:(NSString*)alarmname
{
    // 출입문 열림 시간 가져오기
    NSDictionary *tempDoorDic = [[NSMutableDictionary alloc] initWithDictionary:[[[self.detailInfo objectForKey:@"event"] objectForKey:alarmname] objectForKey:@"door"]];
    doorID = [[tempDoorDic objectForKey:@"id"] integerValue];
    [doorProvider getDoor:doorID];
    isMainRequest = YES;
    [self startLoading:self];
    
    titleLabel.text = [[[self.detailInfo objectForKey:@"event"] objectForKey:alarmname] objectForKey:@"title"];
    doorNameLabel.text = [tempDoorDic objectForKey:@"name"];
    doorDescription.text = [[[self.detailInfo objectForKey:@"event"] objectForKey:alarmname] objectForKey:@"message"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)searchEventForNotiTime
//{
//    [self setDefaultPeriod];
//    [self setDefaultEventType];
//    [self setDefaultDevice];
//    
//    [eventProvider searchEvent:condition offset:0 limit:1000];
//}

- (void)setDefaultEventType
{
    NSArray *eventMessages = [eventProvider getEventMessages];
    
    NSDictionary *doorOpenEvent = nil;
    
    for (NSDictionary *event in eventMessages)
    {
        NSString *name = [event objectForKey:@"name"];
        switch (self.alarmType)
        {
            case DOOR_FORCED_OPEN:
                if ([name isEqualToString:@"FORCED_OPEN"])
                {
                    doorOpenEvent = event;
                }
                break;
                
            case ZONE_FIRE:
                if ([name isEqualToString:@"FIRE_ALARM"])
                {
                    doorOpenEvent = event;
                }
                break;
            case ZONE_APB:
                if ([name isEqualToString:@"APB_ALARM"])
                {
                    doorOpenEvent = event;
                }
                break;
            case DOOR_HELD_OPEN:
                if ([name isEqualToString:@"HELD_OPEN"])
                {
                    doorOpenEvent = event;
                }
                break;
            default:
                break;
        }
        
    }
    
    NSArray *values = @[[NSString stringWithFormat:@"%ld", (long)[[doorOpenEvent objectForKey:@"code"] integerValue]]];
    [condition setObject:values forKey:@"event_type_code"];
}

- (void)setDefaultPeriod
{
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
    //NSDictionary *deviceCondition = @{@"device_id" : deviceIDs};
    
    [condition setObject:deviceIDs forKey:@"device_id"];
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
            [doorProvider openDoor:doorID];
            break;
        case 1:
            // lock
            [doorProvider lockDoor:doorID];
            break;
        case 2:
            // unlock
            [doorProvider unlockDoor:doorID];
            break;
        case 3:
            // release
            [doorProvider releaseDoor:doorID];
            break;
        case 4:
            // clear APB
            [doorProvider clearAntiPassback:doorID];
            break;
        case 5:
            // clear alarm
            [doorProvider clearAlarm:doorID];
            break;
            
        default:
            break;
    }
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

- (void)setDoorInfo:(NSDictionary*)info
{
    [doorDic setDictionary:info];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //return [alarmArray count];
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 알림시간
    AlarmDoorDetailNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmDoorDetailNormalCell" forIndexPath:indexPath];
    NSDate *calculatedDate = [CommonUtil dateFromString:[self.detailInfo objectForKey:@"event_datetime"]  originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    
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


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == 1)
//    {
//        if (openTimeArray.count > 0)
//        {
//            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
//            AlarmTimeTablePopupController __weak *alarmTablePopupController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmTimeTablePopupController"];
//            [alarmTablePopupController setTimeArray:openTimeArray];
//            [self showPopup:alarmTablePopupController parentViewController:self parentView:self.view];
//        }
//    }
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
    
    [self finishLoading];
    
    [self setDefaultPeriod];
    [self setDefaultEventType];
    [self setDefaultDevice];
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
                   title:NSLocalizedString(@"manual_lock", nil)
                   image:[UIImage imageNamed:@"toast_popup_i_02"]];
}

- (void)requestUnlockDoorDidFinish:(NSDictionary *)result
{
    [self finishLoading];
    [self.view makeToast:[self getToastContent]
                duration:2.0 position:CSToastPositionBottom
                   title:NSLocalizedString(@"manual_unlock", nil)
                   image:[UIImage imageNamed:@"toast_popup_i_02"]];
}

- (void)requestReleaseDoorDidFinish:(NSDictionary *)result
{
    [self finishLoading];
    [self.view makeToast:[self getToastContent]
                duration:2.0 position:CSToastPositionBottom
                   title:NSLocalizedString(@"release", nil)
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
}

#pragma mark - ImagePopupDelegate

- (void)confirmImagePopup
{
    isMainRequest = YES;
    
    [doorProvider getDoor:doorID];
    
    [self startLoading:self];
}

- (void)cancelImagePopup
{
    if (isMainRequest)
    {
        if (isFoundDoor)
        {
            //도어 검색후 이벤트 프로바이더에서 실패했을 경우
            [self moveToBack:nil];
        }
        else
        {
            [doorControlButton setEnabled:NO];
            [logImageButton setHidden:YES];
            [logButton setHidden:YES];
            [logLabel setHidden:YES];
        }
        
    }
}

//#pragma mark - EventProviderDelegate
//
//- (void)requestSearchEventDidFinish:(NSArray*)eventArray isNextPage:(BOOL)isNext
//{
//    [self finishLoading];
//    [openTimeArray addObjectsFromArray:eventArray];
//    [detailTableView reloadData];
//}
//
//- (void)requestSearchEventDidFinish:(NSArray*)eventArray totalCount:(NSInteger)count
//{
//    [self finishLoading];
//    [openTimeArray addObjectsFromArray:eventArray];
//    [detailTableView reloadData];
//}
//
//- (void)requestEventProviderDidFail:(NSDictionary*)errDic
//{
//    [self finishLoading];
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
//    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
//    imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
//    [imagePopupCtrl setContent:[errDic objectForKey:@"message"]];
//    imagePopupCtrl.delegate = self;
//    imagePopupCtrl.type = MAIN_REQUEST_FAIL;
//    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
//}
@end
