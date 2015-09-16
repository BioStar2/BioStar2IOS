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

#import "MonitoringViewController.h"

@interface MonitoringViewController ()

@end

@implementation MonitoringViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [MonitorFilterViewController filterReset];
    
    offset = 0;
    limit = 50;
    totalCount = 0;
    hasNextPage = NO;
    canScrollTop = NO;
    canMoveToDetail = YES;
    secondYPosition = 0.0f;
    
    scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"refresh Event"];
    [eventTableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshEvents) forControlEvents:UIControlEventValueChanged];
    
    events = [[NSMutableArray alloc] init];
    doors = [[NSMutableArray alloc] init];
    doorDic = [[NSMutableDictionary alloc] init];
    
    eventProvider = [[EventProvider alloc] init];
    eventProvider.delegate = self;
    
    provider = [[DoorProvider alloc] init];
    provider.delegate = self;
    
    switch (_requestType)
    {
        case EVENT_USER:
            //[provider getDoors];
            [eventProvider searchEvent:condition offset:offset limit:limit];
            canMoveToDetail = NO;
            break;
            
        case EVENT_DOOR:
            [eventProvider searchEvent:condition offset:offset limit:limit];
            canMoveToDetail = NO;
            break;
            
        case EVENT_MONITOR:
            [eventProvider searchEvent:nil offset:offset limit:limit];
            [provider getDoors];
            requestCount = 2;
            break;
    }
    
    [self startLoading:self];
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

- (void)refreshEvents
{
    offset = 0;
    [events removeAllObjects];
    [eventTableView reloadData];
    [eventProvider searchEvent:condition offset:offset limit:limit];
    requestCount = 1;
    [self startLoading:self];
}
- (IBAction)moveToBack:(id)sender
{
    [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
}

- (IBAction)showFilter:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    filterViewController = [storyboard instantiateViewControllerWithIdentifier:@"MonitorFilterViewController"];
    filterViewController.delegate = self;
    if (condition)
    {
        [filterViewController setCondition:condition];
    }
    
    [self pushChildViewController:filterViewController parentViewController:self contentView:self.view animated:NO];
    
}

- (IBAction)scrollTopOrBottom:(id)sender
{
    if (nil == events || events.count == 0)
    {
        return;
    }
    
    if (canScrollTop)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [eventTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
        canScrollTop = NO;
    }
    else
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:events.count - 1 inSection:0];
        [eventTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
        
        if (events.count == totalCount)
        {
            canScrollTop = YES;
            scrollButton.transform = CGAffineTransformMakeRotation(0);
        }
    }
    
}

- (void)setDeviceCondition:(NSDictionary*)deviceCondition
{
    if (nil == condition)
    {
        condition = [[NSMutableDictionary alloc] initWithDictionary:deviceCondition];
    }
    else
    {
        [condition setDictionary:deviceCondition];
    }
    
    [MonitorFilterViewController setResetFilter:NO];
}

- (void)setUserCondition:(NSDictionary*)userCondition;
{
    if (nil == condition)
    {
        condition = [[NSMutableDictionary alloc] initWithDictionary:userCondition];
    }
    else
    {
        [condition setDictionary:userCondition];
    }
    [MonitorFilterViewController setResetFilter:NO];
}

- (void)setDefaultDateCondition
{
    NSDate *date = [NSDate date];
    
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date];
    
    NSDateComponents *newComponents = [[NSDateComponents alloc] init];
    [newComponents setTimeZone:[NSTimeZone localTimeZone]];
    //[newComponents setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [newComponents setYear:dateComponents.year];
    [newComponents setMonth:dateComponents.month];
    [newComponents setDay:dateComponents.day];
    [newComponents setHour:0];
    [newComponents setMinute:0];
    [newComponents setSecond:0];
    
    NSDate *startDate = [calendar dateFromComponents:newComponents];
    NSString *startDateStr = [startDate description];
    
    NSString *startDateString = [CommonUtil stringFromUTCDateToCurrentDateString:startDateStr originDateFormat:@"YYYY-MM-dd HH:mm:ss z" transDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    
    // expire 데이터로 변경
    [newComponents setMonth:dateComponents.month];
    [newComponents setHour:23];
    [newComponents setMinute:59];
    [newComponents setSecond:59];
    
    NSDate *expireDate = [calendar dateFromComponents:newComponents];
    NSString *expireDateStr = [expireDate description];
    
    NSString *expireDateString = [CommonUtil stringFromUTCDateToCurrentDateString:expireDateStr originDateFormat:@"YYYY-MM-dd HH:mm:ss z" transDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    
    [condition setObject:@[startDateString, expireDateString] forKey:@"datetime"];
}

- (void)searchByFilter
{
    offset = 0;
    [events removeAllObjects];
    [eventProvider searchEvent:condition offset:offset limit:limit];
    [self startLoading:self];
}

- (void)checkRequestResult
{
    requestCount--;
    
    if (requestCount == 0)
    {
        [self finishLoading];
        [eventTableView reloadData];
    }
    
    
}

- (void)moveToDetail:(SelectType)currentType ID:(NSInteger)currentID event:(NSDictionary*)eventDic
{
    NSDictionary *userDic = [eventDic objectForKey:@"user"];
    NSDictionary *deviceDic = [eventDic objectForKey:@"device"];
    
    NSString *devicename = [deviceDic objectForKey:@"name"];
    NSString *username = [userDic objectForKey:@"name"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    switch (currentType)
    {
        case NONE_SELECT:
            [self.view makeToast:NSLocalizedString(@"deleted_door_info", nil)
                        duration:2.0
                        position:CSToastPositionBottom
                           image:[UIImage imageNamed:@"toast_popup_i_03"]];
            break;
            
        case SELECT_USER:
        {
            
            UserNewDetailViewController *userDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserNewDetailViewController"];
            [userDetailViewController getUserInfo:[NSString stringWithFormat:@"%ld", (long)currentID]];
            [self pushChildViewController:userDetailViewController parentViewController:self contentView:self.view animated:YES];
            
        }
            
            break;
            
        case SELECT_DEVICE:
        {

            DoorDetailViewController *doorDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"DoorDetailViewController"];
            [self pushChildViewController:doorDetailViewController parentViewController:self contentView:self.view animated:YES];
            
            [doorDetailViewController getSelectedDoor:currentID];

        }
            break;
            
        case SELECT_BOTH:
        {
            
            if (nil == devicename)
            {
                devicename = @"";
            }
            
            if (nil == username)
            {
                // username 없으면 사용자 삭제여서 도어 디테일로 이동
                DoorDetailViewController *doorDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"DoorDetailViewController"];
                [self pushChildViewController:doorDetailViewController parentViewController:self contentView:self.view animated:YES];
                
                [doorDetailViewController getSelectedDoor:currentID];
                
                return;
            }
            
            NSString *doorName;
            for (NSDictionary *door in doors)
            {
                NSInteger doorID = [[door objectForKey:@"id"] integerValue];
                if (doorID == currentID)
                {
                    doorName = [door objectForKey:@"name"];
                }
            }
            
            NSDictionary *tempDeviceDic = @{@"name" : [NSString stringWithFormat:@"Door %@", doorName], @"ID" : [deviceDic objectForKey:@"id"], @"type" : [NSNumber numberWithInteger:SELECT_DEVICE]};
            NSDictionary *tempUserDic = @{@"name" : [NSString stringWithFormat:@"User %@", username], @"ID" : [userDic objectForKey:@"user_id"], @"type" : [NSNumber numberWithInteger:SELECT_USER]};
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            
            OneButtonTablePopupViewController *oneButtonPopup = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonTablePopupViewController"];
            [self showPopup:oneButtonPopup parentViewController:self parentView:self.view];
            oneButtonPopup.delegate = self;
            oneButtonPopup.type = MORNITORING;
            [oneButtonPopup setContentListArray:@[tempDeviceDic, tempUserDic]];
        }
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
    
    
    return [events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [events objectAtIndex:indexPath.row];
    NSDictionary *userDic = [dic objectForKey:@"user"];
    NSDictionary *deviceDic = [dic objectForKey:@"device"];

    if (nil == [userDic objectForKey:@"user_id"])
    {
        // 2줄 또는 3줄
        if (nil == [deviceDic objectForKey:@"id"])
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MonitoringCell" forIndexPath:indexPath];
            
            MonitoringCell *customCell = (MonitoringCell*)cell;
            
            
            [customCell setContent:dic doorInfo:doorDic canMoveDetail:canMoveToDetail];
            
            if (indexPath.row == events.count - 1)
            {
                if (hasNextPage)
                {
                    [eventProvider searchEvent:condition offset:offset limit:limit];
                    requestCount = 1;
                    [self startLoading:self];
                }

            }
            
            return customCell;
        }
        else
        {
            // 3줄
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MonitoringExtraCell" forIndexPath:indexPath];
            
            MonitoringExtraCell *customCell = (MonitoringExtraCell*)cell;
            
            
            [customCell setContent:dic doorInfo:doorDic canMoveDetail:canMoveToDetail];
            
            if (indexPath.row == events.count - 1)
            {
                if (hasNextPage)
                {
                    [eventProvider searchEvent:condition offset:offset limit:limit];
                    requestCount = 1;
                    [self startLoading:self];
                }

            }
            
            return customCell;
        }
    }
    else
    {
        // 4줄
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MonitoringSubExtraCell" forIndexPath:indexPath];
        
        MonitoringSubExtraCell *customCell = (MonitoringSubExtraCell*)cell;
        
        
        [customCell setContent:dic doorInfo:doorDic canMoveDetail:canMoveToDetail];
        
        if (indexPath.row == events.count - 1)
        {
            if (hasNextPage)
            {
                [eventProvider searchEvent:condition offset:offset limit:limit];
                requestCount = 1;
                [self startLoading:self];
            }

        }
        
        return customCell;
    }
}


#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    NSDictionary *eventDic = [events objectAtIndex:indexPath.row];
    NSDictionary *userDic = [eventDic objectForKey:@"user"];
    NSDictionary *deviceDic = [eventDic objectForKey:@"device"];
    if (nil == [userDic objectForKey:@"user_id"])
    {
        // 2줄 또는 3줄
        if (nil == [deviceDic objectForKey:@"id"])
        {
            height = 78;
        }
        else
        {
            height = 96;
        }
    }
    else
    {   // 4줄
        height = 114;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (canMoveToDetail)
    {
        NSDictionary *eventDic = [events objectAtIndex:indexPath.row];
        NSDictionary *userDic = [eventDic objectForKey:@"user"];
        NSDictionary *deviceDic = [eventDic objectForKey:@"device"];
        NSInteger ID = 0;
        SelectType type = NONE_SELECT;
        
        if (nil != [userDic objectForKey:@"user_id"])
        {
            ID = [[userDic objectForKey:@"user_id"] integerValue];
            type = SELECT_USER;
        }
        
        if (nil != [deviceDic objectForKey:@"id"])
        {
            if (nil != [doorDic objectForKey:[deviceDic objectForKey:@"id"]])
            {
                NSString *key = [deviceDic objectForKey:@"id"];
                ID = [[doorDic objectForKey:key] integerValue];
                
                if (type == SELECT_USER)
                {
                    type = SELECT_BOTH;
                }
                else
                {
                    type = SELECT_DEVICE;
                }
            }
        }
        
        [self moveToDetail:type ID:ID event:eventDic];
    }
}

#pragma mark - EventProviderDelegate

- (void)requestSearchEventDidFinish:(NSArray*)eventArray totalCount:(NSInteger)count
{
    if (count == 0)
    {
        [self.view makeToast:NSLocalizedString(@"no_more_data", nil)
                    duration:2.0
                    position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_03"]];
    }
    
    [refreshControl endRefreshing];
    
    if ([eventArray isKindOfClass:[NSArray class]])
    {
        [events addObjectsFromArray:eventArray];
    }
    
    if (events.count < count)
    {
        hasNextPage = YES;
        offset += limit;
    }
    else
    {
        hasNextPage = NO;
    }
    
    canScrollTop = NO;
    scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
    
    switch (_requestType)
    {
        case EVENT_USER:
            [self finishLoading];
            [eventTableView reloadData];
            break;
            
        case EVENT_DOOR:
            [self finishLoading];
            [eventTableView reloadData];
            break;
            
        case EVENT_MONITOR:
            [self checkRequestResult];
            break;
    }
}

- (void)requestEventProviderDidFail:(NSDictionary*)errDic
{
    [refreshControl endRefreshing];
    switch (_requestType)
    {
        case EVENT_USER:
            [self finishLoading];
            break;
            
        case EVENT_DOOR:
            [self finishLoading];
            break;
            
        case EVENT_MONITOR:
            [self checkRequestResult];
            break;
    }
    
}

#pragma mark - DoorProviderDelegate

- (void)requestGetDoorsDidFinish:(NSArray*)doorArray totalCount:(NSInteger)total
{
    [doors addObjectsFromArray:doorArray];
    switch (_requestType)
    {
        case EVENT_USER:
            break;
            
        case EVENT_DOOR:
            break;
            
        case EVENT_MONITOR:
            NSLog(@"requestGetDoorsDidFinish EVENT_MONITOR");
            
            if (doorArray.count < 1)
            {
                NSLog(@"doorArray.count < 1");
            }
            for (NSDictionary *door in doorArray)
            {
                if (nil != [door objectForKey:@"entry_device"])
                {
                    [doorDic setObject:
                                    [door objectForKey:@"id"]
                                forKey:
                                    [[door objectForKey:@"entry_device"] objectForKey:@"id"]];
                }
                
                if (nil != [door objectForKey:@"door_relay"] && nil != [[[door objectForKey:@"door_relay"] objectForKey:@"device"] objectForKey:@"id"])
                {
                    [doorDic setObject:
                                    [door objectForKey:@"id"]
                                forKey:
                                    [[[door objectForKey:@"door_relay"] objectForKey:@"device"] objectForKey:@"id"]];
                }
                
                if (nil != [door objectForKey:@"exit_button"] && nil != [[[door objectForKey:@"exit_button"] objectForKey:@"device"] objectForKey:@"id"])
                {
                    [doorDic setObject:
                                    [door objectForKey:@"id"]
                                forKey:
                                    [[[door objectForKey:@"exit_button"] objectForKey:@"device"] objectForKey:@"id"]];
                }
                
                if (nil != [door objectForKey:@"door_sensor"] && nil != [[[door objectForKey:@"door_sensor"] objectForKey:@"device"] objectForKey:@"id"])
                {
                    [doorDic setObject:
                                    [door objectForKey:@"id"]
                                forKey:
                                    [[[door objectForKey:@"door_sensor"] objectForKey:@"device"] objectForKey:@"id"]];
                }
                
                if (nil != [door objectForKey:@"exit_device"])
                {
                    [doorDic setObject:
                     [door objectForKey:@"id"]
                                forKey:
                     [[door objectForKey:@"exit_device"] objectForKey:@"id"]];
                }
                
                
            }
            [self checkRequestResult];
            break;
    }
    
    
}

- (void)requestDoorProviderDidFail:(NSDictionary*)errDic
{
    switch (_requestType)
    {
        case EVENT_USER:
            [self finishLoading];
            break;
            
        case EVENT_DOOR:
            [self finishLoading];
            break;
            
        case EVENT_MONITOR:
            [self checkRequestResult];
            break;
    }
    
}


#pragma mark - OneButtonTableDelegate

- (void)didSelectItem:(NSDictionary*)selectedDic
{
    if ([[selectedDic objectForKey:@"type"] integerValue]== SELECT_USER)
    {
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        UserNewDetailViewController __weak *userDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserNewDetailViewController"];
//        
//        [userDetailViewController getUserInfo:[selectedDic valueForKey:@"ID"]];
//        
//        [self pushChildViewController:userDetailViewController parentViewController:self contentView:self.view animated:YES];
        [self moveToDetail:SELECT_USER ID:[[selectedDic valueForKey:@"ID"] integerValue]event:nil];
    }
    else
    {
        NSString *key = [selectedDic objectForKey:@"ID"];
        
        NSInteger ID = [[doorDic objectForKey:key] integerValue];
        [self moveToDetail:SELECT_DEVICE ID:ID event:nil];
    }
}

#pragma mark - MonitorFilterDelegate

- (void)saveFilter
{
    if (nil == condition)
    {
        condition = [[NSMutableDictionary alloc] initWithDictionary:[filterViewController getFilterConditions]];
    }
    else
    {
        [condition removeAllObjects];
        [condition setDictionary:[filterViewController getFilterConditions]];
    }
}

- (void)searchEvent
{
    requestCount = 1;
    if (nil == condition)
    {
        condition = [[NSMutableDictionary alloc] initWithDictionary:[filterViewController getFilterConditions]];
    }
    else
    {
        [condition removeAllObjects];
        [condition setDictionary:[filterViewController getFilterConditions]];
    }
    
    // 사용자 장치 이벤트
    NSInteger userCount = 0;
    NSInteger deviceCount = 0;
    NSInteger eventCount = 0;
    
    NSArray *userValue = [condition objectForKey:@"user_id"];
    NSArray *deviceValue = [condition objectForKey:@"device_id"];
    NSArray *eventValue = [condition objectForKey:@"event_type_code"];
    if (userValue)
    {
        userCount = userValue.count;
    }
    
    if (deviceValue)
    {
        deviceCount = deviceValue.count;
    }
    
    if (eventValue)
    {
        eventCount = eventValue.count;
    }
    
    NSString *toastContent = [NSString stringWithFormat:NSLocalizedString(@"user:%ld device:%ld event:%ld", nil)
                              ,userCount
                              ,deviceCount
                              ,eventCount];
    
    
    [self.view makeToast:toastContent
                duration:2.0 position:CSToastPositionBottom
                   title:NSLocalizedString(@"applied_filter", nil)
                   image:[UIImage imageNamed:@"toast_popup_i_05"]];
    

    [self searchByFilter];
}

#pragma mark - ScrollView Delegate


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndDecelerating");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    secondYPosition = scrollView.contentOffset.y;
    NSLog(@"scrollViewDidEndDragging");
    if (firstYPosition < secondYPosition)
    {
        // 스크롤 위로 움직이게
        canScrollTop = NO;
    }
    else
    {
        // 스크롤 아래로
        canScrollTop = YES;
    }
    if (canScrollTop)
    {
        scrollButton.transform = CGAffineTransformMakeRotation(0);
    }
    else
    {
        scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
    }
    
    if (scrollView.contentOffset.y > scrollView.contentSize.height - eventTableView.frame.size.height) {
        NSLog(@"bouncing down");
        canScrollTop = YES;
        scrollButton.transform = CGAffineTransformMakeRotation(0);
    }
    
    if (scrollView.contentOffset.y < 0) {
        NSLog(@"bouncing up");
        canScrollTop = NO;
        scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidScroll");
    secondYPosition = scrollView.contentOffset.y;
    
    if (scrollView.contentOffset.y < 0) {
        NSLog(@"bouncing up");
        canScrollTop = NO;
        scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
    }
    
    
    if (scrollView.contentOffset.y > scrollView.contentSize.height - eventTableView.frame.size.height) {
        NSLog(@"bouncing down");
        canScrollTop = YES;
        scrollButton.transform = CGAffineTransformMakeRotation(0);
    }
    
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    firstYPosition = scrollView.contentOffset.y;
    
}
@end
