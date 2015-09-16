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

NSArray *filterUsers = nil;
NSArray *filterDevices = nil;
NSArray *filterEvents = nil;
BOOL needToResetFilter = NO;

@interface MonitorFilterViewController ()

@end

@implementation MonitorFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    if (nil == _condition)
    {
        _condition = [[NSMutableDictionary alloc] init];
    }
    eventProvider = [[EventProvider alloc] init];
    eventProvider.delegate = self;
    
    isForDate = NO;
    [self setDefaultValue];
}

+ (void)setFilterDevices:(NSArray*)devices
{
    filterDevices = devices;
}

+ (void)setFilterUsers:(NSArray*)users
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
    if ([self.delegate respondsToSelector:@selector(saveFilter)])
    {
        [self.delegate saveFilter];
    }
    
    [self popChildViewController:self parentViewController:self.parentViewController animated:NO];
}

- (IBAction)searchEventByFilter:(id)sender
{
    if (![self verifyPeriod])
    {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(searchEvent)])
    {
        [self.delegate searchEvent];
    }
    [self popChildViewController:self parentViewController:self.parentViewController animated:NO];
}

- (NSDictionary *)getFilterConditions
{
    return _condition;
}

- (BOOL)verifyPeriod
{
    
    
    NSArray *values = [_condition objectForKey:@"datetime"];
    
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

- (void)setCondition:(NSMutableDictionary *)condition
{
    if (condition)
    {
        if (_condition)
        {
            [_condition setDictionary:condition];
        }
        else
        {
            _condition = [[NSMutableDictionary alloc] initWithDictionary:condition];
        }
    }
    
    if (nil != [_condition objectForKey:@"device_id"])
    {
        if (filterDevices)
        {
            [self setDeviceContent:filterDevices];
        }
    }
    
    if (nil != [_condition objectForKey:@"user_id"])
    {
        if (filterUsers)
        {
            [self setUserContent:filterUsers];
        }
    }
    
    if (nil != [_condition objectForKey:@"event_type_code"])
    {
        if (filterEvents)
        {
            [self setEventsContent:filterEvents];
        }
    }
    
    
    
//    if (filterDevices)
//    {
//        [self setDeviceContent:filterDevices];
//    }
//    
//    if (filterEvents)
//    {
//        [self setEventsContent:filterEvents];
//    }
//    
//    if (filterUsers)
//    {
//        [self setUserContent:filterUsers];
//    }
    
}

- (void)setDefaultValue
{
    if ([_condition objectForKey:@"datetime"])
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
    
    [_condition setObject:@[startDateString, expireDateString] forKey:@"datetime"];
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
    datePickerPopup.delegate = self;
    
    NSArray *values = [_condition objectForKey:@"datetime"];
    
    if (sender.tag == 0)
    {
        datePickerPopup.isStartDate = YES;   
        NSString *startStr = [values objectAtIndex:0];
        
        NSDate *startDate = [CommonUtil localDateFromString:startStr originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
        [datePickerPopup setIsLocalTime:YES];
        [datePickerPopup setDate:startDate];
        
    }
    else
    {
        datePickerPopup.isStartDate = NO;
        
        NSString *expireStr = [values objectAtIndex:1];
        NSDate *expireDate = [CommonUtil dateFromString:expireStr originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
        [datePickerPopup setIsLocalTime:YES];
        [datePickerPopup setDate:expireDate];
        
    }
}

- (IBAction)showTimePicker:(UIButton *)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    
    TimePickerPopupViewController *timePickerPopup = [storyboard instantiateViewControllerWithIdentifier:@"TimePickerPopupViewController"];
    [self showPopup:timePickerPopup parentViewController:self parentView:self.view];
    timePickerPopup.delegate = self;
    
    NSArray *values = [_condition objectForKey:@"datetime"];
    
    if (sender.tag == 0)
    {
        timePickerPopup.isStartDate = YES;
        
        NSString *startStr = [values objectAtIndex:0];
        
        NSDate *startDate = [CommonUtil localDateFromString:startStr originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
        [timePickerPopup setDate:startDate];
    }
    else
    {
        timePickerPopup.isStartDate = NO;
        
        NSString *expireStr = [values objectAtIndex:1];
        NSDate *expireDate = [CommonUtil localDateFromString:expireStr originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
        [timePickerPopup setDate:expireDate];
    }
}

- (IBAction)resetCondition:(id)sender
{
    if (filterDevices)
    {
        filterDevices = nil;
    }
    
    if (filterEvents)
    {
        filterEvents = nil;
    }
    
    if (filterUsers)
    {
        filterUsers = nil;
    }
    
    [_condition removeAllObjects];
    [self setDefaultValue];
    if ([self.delegate respondsToSelector:@selector(saveFilter)])
    {
        [self.delegate saveFilter];
    }
}

- (void)setEventsContent:(NSArray *)events
{
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for (NSDictionary *event in events)
    {
        [values addObject:[NSString stringWithFormat:@"%ld", (long)[[event objectForKey:@"code"] integerValue]]];
    }
    [_condition setObject:values forKey:@"event_type_code"];
    
    switch (events.count)
    {
        case 0:
            
            break;
        case 1:
            eventDec = [[events objectAtIndex:0] objectForKey:@"name"];
            break;
            
        default:
            eventDec = [NSString stringWithFormat:@"%@ +", [[events objectAtIndex:0] objectForKey:@"name"]];
            NSInteger value = events.count - 1;
            eventCount = [NSString stringWithFormat:@"%lu", (long)value];
            break;
    }
    
    [filterTableView reloadData];
}

- (void)setUserContent:(NSArray *)users
{
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for (NSDictionary *user in users)
    {
        [values addObject:[user objectForKey:@"user_id"]];
    }
    [_condition setObject:values forKey:@"user_id"];
    
    if (users.count == 1)
    {
        
    }
    
    
    switch (users.count)
    {
        case 0:
            break;
        case 1:
            if (nil == [[users objectAtIndex:0] objectForKey:@"name"] || [[[users objectAtIndex:0] objectForKey:@"name"] isEqualToString:@""])
            {
                userDec = [[users objectAtIndex:0] objectForKey:@"user_id"];
            }
            else
            {
                userDec = [[users objectAtIndex:0] objectForKey:@"name"];
            }
            
            break;
            
        default:
            if (nil == [[users objectAtIndex:0] objectForKey:@"name"] || [[[users objectAtIndex:0] objectForKey:@"name"] isEqualToString:@""])
            {
                userDec = [NSString stringWithFormat:@"%@ +", [[users objectAtIndex:0] objectForKey:@"user_id"]];
            }
            else
            {
                userDec = [NSString stringWithFormat:@"%@ +", [[users objectAtIndex:0] objectForKey:@"name"]];
            }
            
            NSInteger value = users.count - 1;
            userCount = [NSString stringWithFormat:@"%lu", (long)value];
            break;
    }
    
    [filterTableView reloadData];
}

- (void)setDeviceContent:(NSArray *)devices
{
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for (NSDictionary *device in devices)
    {
        [values addObject:[NSString stringWithFormat:@"%ld", (long)[[device objectForKey:@"id"] integerValue]]];
    }
    
    [_condition setObject:values forKey:@"device_id"];
    
    switch (devices.count)
    {
        case 0:
            
            break;
        case 1:
            deviceDec = [[devices objectAtIndex:0] objectForKey:@"name"];
            break;
            
        default:
            deviceDec = [NSString stringWithFormat:@"%@ +", [[devices objectAtIndex:0] objectForKey:@"name"]];
            NSInteger value = devices.count - 1;
            deviceCount = [NSString stringWithFormat:@"%lu", (long)value];
            break;
    }
    
    [filterTableView reloadData];
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
            
            NSArray *values = [_condition objectForKey:@"datetime"];
            NSString *startStr = [values objectAtIndex:0];
            NSString *expireStr = [values objectAtIndex:1];
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
            
            NSArray *values = [_condition objectForKey:@"datetime"];
            NSString *startStr = [values objectAtIndex:0];
            NSString *expireStr = [values objectAtIndex:1];
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
            NSArray *values = [_condition objectForKey:@"event_type_code"];
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
            NSArray *values = [_condition objectForKey:@"user_id"];
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
            NSArray *values = [_condition objectForKey:@"device_id"];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SectionCell"];
    
    return cell.contentView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            // 날짜 선택
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ListPopupViewController *listPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListPopupViewController"];
            listPopupCtrl.delegate = self;
            listPopupCtrl.isRadioStyle = YES;
            listPopupCtrl.type = PEROID;
            [self showPopup:listPopupCtrl parentViewController:self parentView:self.view];
            [listPopupCtrl addOptions:@[NSLocalizedString(@"start_date", nil),
                                        NSLocalizedString(@"end_date", nil)]];
            isForDate = YES;
        }
            break;
        case 1:
        {
            // 시간 선택
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ListPopupViewController *listPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListPopupViewController"];
            listPopupCtrl.delegate = self;
            listPopupCtrl.isRadioStyle = YES;
            listPopupCtrl.type = PEROID;
            [self showPopup:listPopupCtrl parentViewController:self parentView:self.view];
            [listPopupCtrl addOptions:@[NSLocalizedString(@"start_time", nil),
                                        NSLocalizedString(@"end_time", nil)]];
            
            isForDate = NO;
        }
            break;
        case 2:
            // event
            eventMessages = [eventProvider getEventMessages];
            if (nil != eventMessages)
            {
                // 이벤트 선택 팝업 띄우기
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
                ListSubInfoPopupViewController *listSubInfoPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListSubInfoPopupViewController"];
                listSubInfoPopupCtrl.delegate = self;
                listSubInfoPopupCtrl.type = EVENT_SELECT;
                [self showPopup:listSubInfoPopupCtrl parentViewController:self parentView:self.view];
                [listSubInfoPopupCtrl setContentList:eventMessages];
            }
            else
            {
                [eventProvider getEventMessage];
                [self startLoading:self];
            }
            break;
            
        case 3:
            // User
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ListSubInfoPopupViewController *listPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListSubInfoPopupViewController"];
            listPopupCtrl.delegate = self;
            listPopupCtrl.type = USER_SELECT;
            [self showPopup:listPopupCtrl parentViewController:self parentView:self.view];
            
        }
            break;
        case 4:
            // Device
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ListSubInfoPopupViewController *listSubInfoPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListSubInfoPopupViewController"];
            listSubInfoPopupCtrl.delegate = self;
            listSubInfoPopupCtrl.type = DEVICE_SELECT;
            [self showPopup:listSubInfoPopupCtrl parentViewController:self parentView:self.view];
            
        }
            break;
    }
}

#pragma mark - Date Time delegate

- (void)confirmDateFilter:(NSString*)date isStartDate:(BOOL)isStartDate
{
    NSMutableArray *values = [[NSMutableArray alloc] initWithArray:[_condition objectForKey:@"datetime"]];
    
    if (isStartDate)
    {
        // 변경된 년 월 일 만 교체 한 뒤, 서버 시간으로 바꾼 후 dictionary 데이터 교체
        NSString *startStr = [values objectAtIndex:0];
        startStr = [self stringFromChanging:startStr targetDate:date];
        [values replaceObjectAtIndex:0 withObject:startStr];
    }
    else
    {
        NSString *expireStr = [values objectAtIndex:1];
        expireStr = [self stringFromChanging:expireStr targetDate:date];
        
        [values replaceObjectAtIndex:1 withObject:expireStr];
    }
    
    [_condition setObject:values forKey:@"datetime"];
    [filterTableView reloadData];
}

- (void)confirmTimeFilter:(NSString *)date isStartDate:(BOOL)isStartDate
{
    NSMutableArray *values = [[NSMutableArray alloc] initWithArray:[_condition objectForKey:@"datetime"]];
    
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
    
    [_condition setObject:values forKey:@"datetime"];
    [filterTableView reloadData];
}

#pragma mark - ListPopupViewControllerDelegate

- (void)didSelectDateOption:(NSInteger)optionIndex
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = optionIndex;
    if (isForDate)
    {
        
        [self showDatePicker:button];
    }
    else
    {
        [self showTimePicker:button];
    }
}

#pragma mark - ListSubInfoPopupDelegate


- (void)confirmFilterEvents:(NSArray*)events
{
    filterEvents = events;
    
    [self setEventsContent:events];
}

- (void)confirmFilterUsers:(NSArray*)users
{
    filterUsers = users;
    
    [self setUserContent:users];
}

- (void)confirmFilterDevices:(NSArray*)devices
{
    filterDevices = devices;
    
    [self setDeviceContent:devices];
}

#pragma mark - EventProviderDelegate

- (void)requestGetEventMessageDidFinish:(NSArray *)eventTypes
{
    eventMessages = [eventProvider getEventMessages];
    [self finishLoading];
    // 이벤트 선택 팝업 띄워주기 
}

- (void)requestEventProviderDidFail:(NSDictionary*)errDic
{
    [self finishLoading];
}
@end
