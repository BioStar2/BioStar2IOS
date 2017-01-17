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

#import "MonitorFilterViewController.h"

NSArray <User* >*filterUsers = nil;
NSArray <SearchResultDevice*> *filterDevices = nil;
NSArray <EventType*> *filterEvents = nil;
BOOL needToResetFilter = NO;

@interface MonitorFilterViewController ()

@end

@implementation MonitorFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSharedViewController:self];
    // Do any additional setup after loading the view.
    titleLabel.text = NSLocalizedString(@"filter", nil);
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    if (nil == searchQuery)
    {
        searchQuery = [[EventQuery alloc] init];
    }
    eventProvider = [[EventProvider alloc] init];
    [self setDefaultValue];
}

+ (void)setFilterDevices:(NSArray<SearchResultDevice*>*)devices
{
    filterDevices = devices;
}

+ (void)setFilterUsers:(NSArray<User*>*)users
{
    filterUsers = users;
}

+ (void)setResetFilter:(BOOL)neetToReset
{
    needToResetFilter = neetToReset;
}

+ (void)filterReset
{
    if (needToResetFilter)
    {
        filterUsers = nil;
        filterDevices = nil;
        filterEvents = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)moveToBack:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(saveFilter:)])
    {
        [self.delegate saveFilter:searchQuery];
    }
    
    [self popChildViewController:self parentViewController:self.parentViewController animated:NO];
}

- (IBAction)searchEventByFilter:(id)sender
{
    if (![self verifyPeriod])
    {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(searchEventByFilterController:)])
    {
        [self.delegate searchEventByFilterController:searchQuery];
    }
    [self popChildViewController:self parentViewController:self.parentViewController animated:NO];
}

- (EventQuery *)searchQuery
{
    return searchQuery;
}

- (BOOL)verifyPeriod
{
    
    NSArray <NSString *>*values = searchQuery.datetime;
    
    NSString *startDate = [values objectAtIndex:0];
    NSString *endDate = [values lastObject];
    
    NSDate *start = [CommonUtil dateFromString:startDate originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    NSDate *end = [CommonUtil dateFromString:endDate originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    
    NSComparisonResult comparing = [start compare:end];
    
    if (comparing == NSOrderedDescending || comparing == NSOrderedSame)
    {
        [self showVerificationPopup:NSLocalizedString(@"error_set_date", nil)];
        return NO;
    }
    
    return YES;
}

- (void)showVerificationPopup:(NSString*)message
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    OneButtonPopupViewController *oneButtonPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonPopupViewController"];
    oneButtonPopupCtrl.type = USER_INFO_VERIFICATION_FAIL;
    oneButtonPopupCtrl.popupContent = message;
    [self showPopup:oneButtonPopupCtrl parentViewController:self parentView:self.view];
}

- (void)setDefaultValue
{
    if (nil != searchQuery.datetime)
    {
        return;
    }
    
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
    
    searchQuery.datetime = @[startDateString, expireDateString];
    
    [filterTableView reloadData];
}

- (NSString*)stringFromChanging:(NSString*)origin targetDate:(NSString*)target
{
    NSDate *targetDate = [CommonUtil dateFromString:target originDateFormat:@"YYYY-MM-dd HH:mm:ss z"];
    NSCalendar *targetCalendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit targetUnitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *targetDateComponents = [targetCalendar components:targetUnitFlags fromDate:targetDate];
    
    
    NSDate *originDate = [CommonUtil dateFromString:origin originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:originDate];
    
    NSDateComponents *newComponents = [[NSDateComponents alloc] init];
    [newComponents setTimeZone:[NSTimeZone localTimeZone]];
    [newComponents setYear:targetDateComponents.year];
    [newComponents setMonth:targetDateComponents.month];
    [newComponents setDay:targetDateComponents.day];
    [newComponents setHour:dateComponents.hour];
    [newComponents setMinute:dateComponents.minute];
    [newComponents setSecond:dateComponents.second];
    
    NSDate *startDate = [calendar dateFromComponents:newComponents];
    NSString *startDateStr = [startDate description];
    
    startDateStr = [CommonUtil stringFromDateString:startDateStr originDateFormat:@"YYYY-MM-dd HH:mm:ss z" transDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    return startDateStr;
}

- (NSString*)stringFromChanging:(NSString*)origin targetTime:(NSString*)target
{
    NSDate *targetDate = [CommonUtil dateFromString:target originDateFormat:@"YYYY-MM-dd HH:mm:ss z"];
    NSCalendar *targetCalendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit targetUnitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *targetDateComponents = [targetCalendar components:targetUnitFlags fromDate:targetDate];
    
    NSDate *date = [CommonUtil dateFromString:origin originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date];
    
    NSDateComponents *newComponents = [[NSDateComponents alloc] init];
    [newComponents setTimeZone:[NSTimeZone localTimeZone]];
    [newComponents setYear:dateComponents.year];
    [newComponents setMonth:dateComponents.month];
    [newComponents setDay:dateComponents.day];
    [newComponents setHour:targetDateComponents.hour];
    [newComponents setMinute:targetDateComponents.minute];
    [newComponents setSecond:dateComponents.second];
    
    NSDate *startDate = [calendar dateFromComponents:newComponents];
    NSString *startDateStr = [startDate description];
    
    startDateStr = [CommonUtil stringFromDateString:startDateStr originDateFormat:@"YYYY-MM-dd HH:mm:ss z" transDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    return startDateStr;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)showDatePicker:(UIButton *)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    
    DatePickerPopupViewController *datePickerPopup = [storyboard instantiateViewControllerWithIdentifier:@"DatePickerPopupViewController"];
    [self showPopup:datePickerPopup parentViewController:self parentView:self.view];
    
    
    if (sender.tag == 0)
    {
        datePickerPopup.isStartDate = YES;   
        NSString *startStr = searchQuery.datetime[0];
        
        NSDate *startDate = [CommonUtil localDateFromString:startStr originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
        [datePickerPopup setIsLocalTime:YES];
        [datePickerPopup setDate:startDate];
        
        [datePickerPopup getResponse:^(NSString *dateString) {
            
            NSString *startStr = searchQuery.datetime[0];
            startStr = [self stringFromChanging:startStr targetDate:dateString];
            NSString *endStr = searchQuery.datetime[1];
            
            searchQuery.datetime = @[startStr, endStr];
            [filterTableView reloadData];
        }];
    }
    else
    {
        datePickerPopup.isStartDate = NO;
        
        NSString *expireStr = searchQuery.datetime[1];
        NSDate *expireDate = [CommonUtil dateFromString:expireStr originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
        [datePickerPopup setIsLocalTime:YES];
        [datePickerPopup setDate:expireDate];
        
        [datePickerPopup getResponse:^(NSString *dateString) {
            
            NSString *endStr = searchQuery.datetime[1];
            endStr = [self stringFromChanging:expireStr targetDate:dateString];
            
            NSString *startStr = searchQuery.datetime[0];
            
            searchQuery.datetime = @[startStr, endStr];
            [filterTableView reloadData];
        }];
        
    }
    
    
}

- (IBAction)showTimePicker:(UIButton *)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    
    TimePickerPopupViewController *timePickerPopup = [storyboard instantiateViewControllerWithIdentifier:@"TimePickerPopupViewController"];
    [self showPopup:timePickerPopup parentViewController:self parentView:self.view];
    
    if (sender.tag == 0)
    {
        timePickerPopup.isStartDate = YES;
        
        NSString *startStr = searchQuery.datetime[0];
        
        NSDate *startDate = [CommonUtil localDateFromString:startStr originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
        [timePickerPopup setDate:startDate];
        
        [timePickerPopup getResponse:^(NSString *dateString) {
            
            NSString *startStr = searchQuery.datetime[0];
            startStr = [self stringFromChanging:startStr targetTime:dateString];
            
            NSString *endStr = searchQuery.datetime[1];
            
            searchQuery.datetime = @[startStr, endStr];
            [filterTableView reloadData];
            
        }];
    }
    else
    {
        timePickerPopup.isStartDate = NO;
        
        NSString *expireStr = searchQuery.datetime[1];
        NSDate *expireDate = [CommonUtil localDateFromString:expireStr originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
        [timePickerPopup setDate:expireDate];
        
        [timePickerPopup getResponse:^(NSString *dateString) {
            
            NSString *expireStr = searchQuery.datetime[1];
            expireStr = [self stringFromChanging:expireStr targetTime:dateString];
            
            NSString *startStr = searchQuery.datetime[0];
            
            searchQuery.datetime = @[startStr, expireStr];
            [filterTableView reloadData];
            
        }];
    }
}

- (void)setSearchQuery:(EventQuery*)query
{
    searchQuery = query;
    
    if (nil != searchQuery.device_id)
    {
        if (filterDevices)
        {
            [self setDeviceContent:filterDevices];
        }
    }

    if (nil != searchQuery.user_id)
    {
        if (filterUsers)
        {
            [self setUserContent:filterUsers];
        }
    }

    if (nil != searchQuery.event_type_code)
    {
        if (filterEvents)
        {
            [self setEventsContent:filterEvents];
        }
    }
}

- (IBAction)resetCondition:(id)sender
{
    searchQuery.user_id = nil;
    searchQuery.datetime = nil;
    searchQuery.device_id = nil;
    searchQuery.event_type_code = nil;
    
    [self setDefaultValue];
    if ([self.delegate respondsToSelector:@selector(saveFilter:)])
    {
        [self.delegate saveFilter:searchQuery];
    }

}

- (void)setEventsContent:(NSArray <EventType*> *)events
{
    NSMutableArray <NSString*> *values = [[NSMutableArray alloc] init];
    for (EventType *event in events)
    {
        [values addObject:[NSString stringWithFormat:@"%ld", (long)event.code]];
    }
    
    searchQuery.event_type_code = values;
    
    switch (events.count)
    {
        case 0:
            
            break;
        case 1:
            if ([PreferenceProvider isUpperVersion])
            {
                eventDec = events[0].event_type_description;
            }
            else
            {
                eventDec = events[0].name;
            }
            break;
            
        default:
            if ([PreferenceProvider isUpperVersion])
            {
                eventDec = [NSString stringWithFormat:@"%@ +", events[0].event_type_description];
                NSInteger value = events.count - 1;
                eventCount = [NSString stringWithFormat:@"%lu", (long)value];
            }
            else
            {
                eventDec = [NSString stringWithFormat:@"%@ +", events[0].name];
                NSInteger value = events.count - 1;
                eventCount = [NSString stringWithFormat:@"%lu", (long)value];
            }
            break;
    }
    
    [filterTableView reloadData];
}

- (void)setUserContent:(NSArray <User*> *)users;
{
    NSMutableArray <NSString*> *values = [[NSMutableArray alloc] init];
    for (User *user in users)
    {
        [values addObject:user.user_id];
    }
    
    searchQuery.user_id = values;
    
    switch (users.count)
    {
        case 0:
            break;
        case 1:
            if (nil == users[0].name || [users[0].name isEqualToString:@""])
            {
                userDec = users[0].user_id;
            }
            else
            {
                userDec = users[0].name;
            }
            
            break;
            
        default:
            if (nil == users[0].name || [users[0].name isEqualToString:@""])
            {
                userDec = [NSString stringWithFormat:@"%@ +", users[0].user_id];
            }
            else
            {
                userDec = [NSString stringWithFormat:@"%@ +", users[0].name];
            }
            
            NSInteger value = users.count - 1;
            userCount = [NSString stringWithFormat:@"%lu", (long)value];
            break;
    }
    
    [filterTableView reloadData];
}

- (void)setDeviceContent:(NSArray <SearchResultDevice*>*)devices
{
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for (SearchResultDevice *device in devices)
    {
        [values addObject:device.id];
    }
    searchQuery.device_id = values;
    
    switch (devices.count)
    {
        case 0:
            
            break;
        case 1:
            deviceDec = devices[0].name;
            break;
            
        default:
            deviceDec = [NSString stringWithFormat:@"%@ +", devices[0].name];
            NSInteger value = devices.count - 1;
            deviceCount = [NSString stringWithFormat:@"%lu", (long)value];
            break;
    }
    
    [filterTableView reloadData];
}

- (void)showListDatePopup:(BOOL)isDate
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ListPopupViewController *listPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListPopupViewController"];
    listPopupCtrl.type = PEROID;
    [self showPopup:listPopupCtrl parentViewController:self parentView:self.view];
    
    [listPopupCtrl addOptions:@[NSLocalizedString(@"start_date", nil), NSLocalizedString(@"end_date", nil)]];
    
    [listPopupCtrl getIndexResponseBlock:^(NSInteger index) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = index;
        if (isDate)
        {
            [self showDatePicker:button];
        }
        else
        {
            [self showTimePicker:button];
        }
    }];
}

- (void)getEventMessage
{
    [self startLoading:self];

    [eventProvider getEventTypes:^(EventTypeSearchResult *result) {
        
        [self finishLoading];
        
        // 이벤트 선택 팝업 띄워주기
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        EventPopupViewController *eventPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"EventPopupViewController"];
        
        [self showPopup:eventPopupCtrl parentViewController:self parentView:self.view];
        
        [eventPopupCtrl getEventTypeBlock:^(NSArray<EventType *> *eventTypes) {
            filterEvents = eventTypes;
            [self setEventsContent:eventTypes];
        }];
        
    } onError:^(Response *error) {
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = MAIN_REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self getEventMessage];
            }
        }];
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DateCell" forIndexPath:indexPath];
            DateCell *customCell = (DateCell*)cell;
            customCell.titleLabel.text = NSLocalizedString(@"period", nil);
            
            NSString *startStr = searchQuery.datetime[0];
            NSString *expireStr = searchQuery.datetime[1];
            startStr = [CommonUtil stringFromCurrentLocaleDateString:startStr originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'" transDateFormat:@"yyyy/MM/dd"];
            expireStr = [CommonUtil stringFromCurrentLocaleDateString:expireStr originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'" transDateFormat:@"yyyy/MM/dd"];
            
            customCell.startDateLabel.text = startStr;
            customCell.expireDateLabel.text = expireStr;
            return customCell;
        }
            
            break;
            
        case 1:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimeCell" forIndexPath:indexPath];
            
            TimeCell *customCell = (TimeCell*)cell;
            customCell.titleLabel.text = NSLocalizedString(@"time", nil);
            
            NSString *startStr = searchQuery.datetime[0];
            NSString *expireStr = searchQuery.datetime[1];
            
            startStr = [CommonUtil stringFromCurrentLocaleDateString:startStr originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'" transDateFormat:@"HH:mm"];
            expireStr = [CommonUtil stringFromCurrentLocaleDateString:expireStr originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'" transDateFormat:@"HH:mm"];
            
            customCell.startTimeLabel.text = startStr;
            customCell.expireTimeLabel.text = expireStr;
            return customCell;
        }
            
            break;
            
        case 2:
        {
            // Event
            NSArray *values = searchQuery.event_type_code;
            switch (values.count)
            {
                case 0:
                {
                    // 선택 하나도 안했을때
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleSelectionCell" forIndexPath:indexPath];
                    
                    SingleSelectionCell *customCell = (SingleSelectionCell*)cell;
                    customCell.titleLabel.text = NSLocalizedString(@"event", nil);
                    customCell.contentLabel.text = NSLocalizedString(@"all_events", nil);
                    return customCell;
                }
                    break;
                case 1:
                {
                    // 하나만 선택했을대
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleSelectionCell" forIndexPath:indexPath];
                    
                    SingleSelectionCell *customCell = (SingleSelectionCell*)cell;
                    customCell.titleLabel.text = NSLocalizedString(@"event", nil);
                    customCell.contentLabel.text = eventDec;
                    return customCell;
                }
                    break;
                default:
                {
                    // 둘이상 선택했을때
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MultiSelectionCell" forIndexPath:indexPath];
                    MultiSelectionCell *customCell = (MultiSelectionCell*)cell;
                    customCell.titleLabel.text = NSLocalizedString(@"event", nil);
                    customCell.contentLabel.text = eventDec;
                    customCell.numberLabel.text = eventCount;
                    [customCell setNumverViewWidth];
                    return customCell;
                }
                    break;
            }
        }
            break;
            
        case 3:
        {
            // User
            NSArray *values = searchQuery.user_id;
            switch (values.count)
            {
                case 0:
                {
                    // 선택 하나도 안했을때
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleSelectionCell" forIndexPath:indexPath];
                    
                    SingleSelectionCell *customCell = (SingleSelectionCell*)cell;
                    customCell.titleLabel.text = NSLocalizedString(@"user", nil);
                    customCell.contentLabel.text = NSLocalizedString(@"all_users", nil);
                    return customCell;
                }
                    break;
                case 1:
                {
                    // 하나만 선택했을대
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleSelectionCell" forIndexPath:indexPath];
                    
                    SingleSelectionCell *customCell = (SingleSelectionCell*)cell;
                    customCell.titleLabel.text = NSLocalizedString(@"user", nil);
                    customCell.contentLabel.text = userDec;
                    return customCell;
                }
                    break;
                default:
                {
                    // 둘이상 선택했을때
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MultiSelectionCell" forIndexPath:indexPath];
                    MultiSelectionCell *customCell = (MultiSelectionCell*)cell;
                    customCell.titleLabel.text = NSLocalizedString(@"user", nil);
                    customCell.contentLabel.text = userDec;
                    customCell.numberLabel.text = userCount;
                    [customCell setNumverViewWidth];
                    return customCell;
                }
                    break;
            }
        }
            
            break;
        case 4:
        {
            NSArray *values = searchQuery.device_id;
            switch (values.count)
            {
                case 0:
                {
                    // 선택 하나도 안했을때
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleSelectionCell" forIndexPath:indexPath];
                    
                    SingleSelectionCell *customCell = (SingleSelectionCell*)cell;
                    customCell.titleLabel.text = NSLocalizedString(@"device", nil);
                    customCell.contentLabel.text = NSLocalizedString(@"all_devices", nil);
                    return customCell;
                }
                    break;
                case 1:
                {
                    // 하나만 선택했을대
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleSelectionCell" forIndexPath:indexPath];
                    
                    SingleSelectionCell *customCell = (SingleSelectionCell*)cell;
                    customCell.titleLabel.text = NSLocalizedString(@"device", nil);
                    customCell.contentLabel.text = deviceDec;
                    return customCell;
                }
                    break;
                default:
                {
                    // 둘이상 선택했을때
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MultiSelectionCell" forIndexPath:indexPath];
                    MultiSelectionCell *customCell = (MultiSelectionCell*)cell;
                    customCell.titleLabel.text = NSLocalizedString(@"device", nil);
                    customCell.contentLabel.text = deviceDec;
                    customCell.numberLabel.text = deviceCount;
                    [customCell setNumverViewWidth];
                    return customCell;
                }
                    break;
            }
        }
            
            break;
            
        default:
        {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            return cell;
        }
            break;
    }
    
}


#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 41;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
#warning 2.4.1 에서 filter section 빼기 as
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SectionCell"];
    
    return cell.contentView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:     // 날짜 선택
            [self showListDatePopup:YES];
            break;
        case 1:     // 시간 선택
            [self showListDatePopup:NO];
            break;
        case 2:     // event
            if (nil != [eventProvider getEventTypes])
            {
                // 이벤트 선택 팝업 띄우기
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
                EventPopupViewController *eventPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"EventPopupViewController"];
                
                [self showPopup:eventPopupCtrl parentViewController:self parentView:self.view];
                
                [eventPopupCtrl getEventTypeBlock:^(NSArray<EventType *> *eventTypes) {
                    
                    filterEvents = eventTypes;
                    [self setEventsContent:eventTypes];
                }];
                
                
            }
            else
            {
                [self getEventMessage];
            }
            break;
            
        case 3:     // User
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            UserPopupViewController *userPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"UserPopupViewController"];
            
            [self showPopup:userPopupCtrl parentViewController:self parentView:self.view];
            
            [userPopupCtrl getUsers:^(NSArray<User *> *users) {
                filterUsers = users;
                
                [self setUserContent:users];
            }];
            
        }
            break;
        case 4:     // Device
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            DevicePopupViewController *devicePopupController = [storyboard instantiateViewControllerWithIdentifier:@"DevicePopupViewController"];
            
            devicePopupController.deviceMode = ALL_DEVICES_MODE;
            [self showPopup:devicePopupController parentViewController:self parentView:self.view];
            
            [devicePopupController getDevices:^(NSArray<SearchResultDevice *> *devices) {
                filterDevices = devices;
                
                [self setDeviceContent:devices];
            }];
            
        }
            break;
    }
}

#pragma mark - Date Time delegate


- (void)confirmTimeFilter:(NSString *)date isStartDate:(BOOL)isStartDate
{
    NSMutableArray *values = [[NSMutableArray alloc] initWithArray:searchQuery.datetime];
    
    if (isStartDate)
    {
        NSString *startStr = [values objectAtIndex:0];
        startStr = [self stringFromChanging:startStr targetTime:date];
        
        [values replaceObjectAtIndex:0 withObject:startStr];
    }
    else
    {
        NSString *expireStr = [values objectAtIndex:1];
        expireStr = [self stringFromChanging:expireStr targetTime:date];
        
        [values replaceObjectAtIndex:1 withObject:expireStr];
    }
    
    searchQuery.datetime = values;
    [filterTableView reloadData];
}


@end
