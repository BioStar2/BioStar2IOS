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
    [self setSharedViewController:self];
    
    [MonitorFilterViewController filterReset];
    if (nil == searchQuery) {
        searchQuery = [[EventQuery alloc] init];
    }
    titleLabel.text = NSBaseLocalizedString(@"monitoring", nil);
    searchQuery.offset = 0;
    searchQuery.limit = 50;
    
    totalCount = 0;
    hasNextPage = NO;
    canScrollTop = NO;
    secondYPosition = 0.0f;
    
    scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
    
    refreshControl = [[UIRefreshControl alloc] init];
    [eventTableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshEvents) forControlEvents:UIControlEventValueChanged];
    
    events = [[NSMutableArray alloc] init];
    doors = [[NSMutableArray alloc] init];
    
    eventProvider = [[EventProvider alloc] init];
    doorProvider = [[DoorProvider alloc] init];
    
    isMainRequest = YES;
    [self searchEvent:searchQuery];
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


- (NSUInteger)searchDoorIDByDeviceID:(NSString*)devicdID
{
    NSUInteger doorID = 0;
    
    for (ListDoorItem *door in doors)
    {
        if (nil != door.entry_device)
        {
            if ([devicdID isEqualToString:door.entry_device.id])
            {
                doorID = [door.id integerValue];
            }
        }
        
        if (nil == door.door_relay)
        {
            if ([devicdID isEqualToString:door.door_relay.device.id])
            {
                doorID = [door.id integerValue];
            }
        }
        
        if (nil == door.exit_button)
        {
            if ([devicdID isEqualToString:door.exit_button.device.id])
            {
                doorID = [door.id integerValue];
            }
        }
        
        if (nil == door.door_sensor)
        {
            if ([devicdID isEqualToString:door.door_sensor.device.id])
            {
                doorID = [door.id integerValue];
            }
        }
        
        if (nil == door.exit_device)
        {
            if ([devicdID isEqualToString:door.exit_device.id])
            {
                doorID = [door.id integerValue];
            }
        }
    }

    return doorID;
}

- (void)searchEvent:(EventQuery*)query
{
#warning 2.4.1 query.device_id count == 0 이면 none 토스트 띄우고 movetobace 
    
    [self setSharedViewController:self];
    
    [self startLoading:self];
    
    [eventProvider searchEvent:query completeBlock:^(EventLogSearchResultWithoutTotal *result) {
        
        isMainRequest = NO;
        [refreshControl endRefreshing];
        
        [self finishLoading];
        
        [refreshControl endRefreshing];
        
        if (searchQuery.offset == 0)
        {
            [events removeAllObjects];
        }
        
        [events addObjectsFromArray:result.records];
        
        if (result.is_next)
        {
            hasNextPage = YES;
            searchQuery.offset += searchQuery.limit;
        }
        else
        {
            hasNextPage = NO;
        }
        
        canScrollTop = NO;
        scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
        
        [eventTableView reloadData];
    
        
    } onError:^(Response *error) {
        
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = MAIN_REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self searchEvent:query];
            }
            else
            {
                if (isMainRequest)
                {
                    [self moveToBack:nil];
                }
            }
        }];
    }];
    
    
}

- (void)refreshEvents
{
    searchQuery.offset = 0;
    
    [events removeAllObjects];
    [eventTableView reloadData];
    [self searchEvent:searchQuery];
}
- (IBAction)moveToBack:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NEED_TO_GET_MOBILE_CREDENTIAL object:nil];
    [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
}

- (IBAction)showFilter:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    filterViewController = [storyboard instantiateViewControllerWithIdentifier:@"MonitorFilterViewController"];
    filterViewController.delegate = self;
    if (searchQuery)
    {
        [filterViewController setSearchQuery:searchQuery];
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

- (void)setDeviceCondition:(NSArray <NSString *> *)deviceIDs
{
    if (nil == searchQuery)
    {
        searchQuery = [[EventQuery alloc] init];
    }
    searchQuery.device_id = deviceIDs;
    [MonitorFilterViewController setResetFilter:NO];
}

- (void)setUserCondition:(NSArray <NSString *> *)userIDs;
{
    if (nil == searchQuery)
    {
        searchQuery = [[EventQuery alloc] init];
    }
    searchQuery.user_id = userIDs;
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
    
    searchQuery.datetime = @[startDateString, expireDateString];
}

- (void)searchByFilter
{
    searchQuery.offset = 0;
    [self searchEvent:searchQuery];
}

- (NSString*)searchDoorNameByDoorID:(NSUInteger)ID
{
    NSString *doorName = nil;
    
    for (ListDoorItem *door in doors)
    {
        NSInteger doorID = [door.id integerValue];
        if (doorID == ID)
        {
            doorName = door.name;
            break;
        }
    }
    
    return doorName;
}

- (void)moveToDetail:(SelectType)currentType ID:(NSInteger)currentID event:(EventLogResult*)eventResult
{

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    switch (currentType)
    {
        case NONE_SELECT:
        {
            return;
        }
        case SELECT_USER:
        {
            
            UserNewDetailViewController *userDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserNewDetailViewController"];
            [userDetailViewController getUserInfo:[NSString stringWithFormat:@"%ld", (long)currentID]];
            [self pushChildViewController:userDetailViewController parentViewController:self contentView:self.view animated:YES];
            
        }
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
    
    
    return [events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventLogResult *result = [events objectAtIndex:indexPath.row];
    SimpleUser *user = result.user;
    SimpleModel *device = result.device;

    if (nil == user.user_id)
    {
        // 2줄 또는 3줄
        if (nil == device.id)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MonitoringCell" forIndexPath:indexPath];
            
            MonitoringCell *customCell = (MonitoringCell*)cell;
            
            
            [customCell setContent:result];
            
            if (indexPath.row == events.count - 1)
            {
                if (hasNextPage)
                {
                    [self searchEvent:searchQuery];
                }

            }
            
            return customCell;
        }
        else
        {
            // 3줄
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MonitoringExtraCell" forIndexPath:indexPath];
            
            MonitoringExtraCell *customCell = (MonitoringExtraCell*)cell;
            
            
            [customCell setContent:result];
            
            if (indexPath.row == events.count - 1)
            {
                if (hasNextPage)
                {
                    [self searchEvent:searchQuery];
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
        
        
        [customCell setContent:result doorInfo:result.device];
        
        if (indexPath.row == events.count - 1)
        {
            if (hasNextPage)
            {
                [self searchEvent:searchQuery];
            }

        }
        
        return customCell;
    }
}


#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    EventLogResult *event = [events objectAtIndex:indexPath.row];
    SimpleUser *user = event.user;
    SimpleModel *device = event.device;
    if (nil == user.user_id)
    {
        // 2줄 또는 3줄
        if (nil == device.id)
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
    if ([AuthProvider hasReadPermission:MONITORING_PERMISSION])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        MornitoringPopupViewController *monitoringPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"MornitoringPopupViewController"];
        
        [self showPopup:monitoringPopupCtrl parentViewController:self parentView:self.view];
        
        [monitoringPopupCtrl setContent:[events objectAtIndex:indexPath.row]];
    }
}


#pragma mark - MonitorFilterDelegate

- (void)saveFilter:(EventQuery*)filteredQuery
{
    searchQuery = filteredQuery;
}

- (void)searchEventByFilterController:(EventQuery*)filteredQuery withDoors:(NSArray<ListDoorItem*>*)filteredDoors
{
    searchQuery = filteredQuery;
    
    // 사용자 장치 이벤트
    NSString *userCount = searchQuery.user_id.count == 0 ? NSBaseLocalizedString(@"all_users", nil) : [NSString stringWithFormat:@"%ld", (unsigned long)searchQuery.user_id.count];
    
    NSString * eventCount = searchQuery.event_type_code.count == 0 ? NSBaseLocalizedString(@"all_events", nil) : [NSString stringWithFormat:@"%ld", (unsigned long)searchQuery.event_type_code.count];
    
    NSString * doorCount = filteredDoors.count == 0 ? @"0" : [NSString stringWithFormat:@"%ld", (unsigned long)filteredDoors.count];
    
    NSString * deviceCount;
    
    if (filteredDoors.count == 0)
    {
        deviceCount = searchQuery.device_id.count == 0 ? NSBaseLocalizedString(@"all_devices", nil) : [NSString stringWithFormat:@"%ld", (unsigned long)searchQuery.device_id.count];
    }
    else
    {
        deviceCount = @"0";
    }
    
    NSMutableString *toastDec = [[NSMutableString alloc] init];
    
    NSString *userCountStr = [NSString stringWithFormat:@"%@:%@",NSBaseLocalizedString(@"user", nil) ,userCount];
    NSString *deviceCountStr = [NSString stringWithFormat:@"%@:%@",NSBaseLocalizedString(@"device", nil) ,deviceCount];
    NSString *eventCountStr = [NSString stringWithFormat:@"%@:%@",NSBaseLocalizedString(@"event", nil) ,eventCount];
    NSString *doorCountStr = [NSString stringWithFormat:@"%@:%@",NSBaseLocalizedString(@"door", nil) ,doorCount];
    
    [toastDec appendString:[NSString stringWithFormat:@"%@ / %@ / %@ / %@",userCountStr ,deviceCountStr ,eventCountStr ,doorCountStr]];
    
    
    [self.view makeToast:toastDec
                duration:2.0 position:CSToastPositionBottom
                   title:NSBaseLocalizedString(@"applied_filter", nil)
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
        if (decelerate)
        {
            canScrollTop = NO;
        }
    }
    else
    {
        // 스크롤 아래로
        if (decelerate)
        {
            canScrollTop = YES;
        }
        
    }
    if (canScrollTop)
    {
        NSLog(@"canScrollTop");
        scrollButton.transform = CGAffineTransformMakeRotation(0);
    }
    else
    {
        NSLog(@"not canScrollTop");
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
    NSLog(@"scrollViewWillBeginDragging");
    firstYPosition = scrollView.contentOffset.y;
    
}
@end
