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

#import "ListSubInfoPopupViewController.h"

@interface ListSubInfoPopupViewController ()

@end

@implementation ListSubInfoPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    contentListArray = [[NSMutableArray alloc] init];
    contentDic = [[NSMutableDictionary alloc] init];
    selectedInfoArray = [[NSMutableArray alloc] init];
    
    [containerView setHidden:YES];
    hasNextPage = NO;
    
    offset = 0;
    limit = 50;
    
    multiSelect = NO;
    isSelectedAll = NO;
    isSearchable = NO;
    isForSearch = NO;
    isForSingleSearch = NO;
    
    listTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    switch (_type)
    {
        case USER_GROUP:
            titleLabel.text = NSLocalizedString(@"select_user_group", nil);
            userProvider = [[UserProvider alloc] init];
            userProvider.delegate = self;
            [userProvider getUserGroups];
            [self startLoading:self];
            break;
            
        case DEVICE_FINGERPRINT:
            titleLabel.text = NSLocalizedString(@"select_device_orginal", nil);
            deviceProvider = [[DeviceProvider alloc] init];
            deviceProvider.delegate = self;
            [deviceProvider getDevices:query limit:10000 offset:offset mode:FINGERPRINT_MODE];
            [self startLoading:self];
            break;
            
        case DEVICE_CARD:
            titleLabel.text = NSLocalizedString(@"registeration_option_card_reader", nil);
            deviceProvider = [[DeviceProvider alloc] init];
            deviceProvider.delegate = self;
            [deviceProvider getDevices:query limit:10000 offset:offset mode:CARD_MODE];
            [self startLoading:self];
            
            break;
            
        case DEVICE_SELECT:
            multiSelect = YES;
            isSearchable = YES;
            titleLabel.text = NSLocalizedString(@"select_device_orginal", nil);
            deviceProvider = [[DeviceProvider alloc] init];
            deviceProvider.delegate = self;
            [deviceProvider getDevices:nil limit:10000 offset:offset];
            [self startLoading:self];
            
            break;
            
        case ASSIGN_CARD:
        case EXCHANGE_CARD:
            isForSingleSearch = YES;
            titleLabel.text = NSLocalizedString(@"registeration_option_assign_card", nil);
            deviceProvider = [[DeviceProvider alloc] init];
            deviceProvider.delegate = self;
            [deviceProvider getCards:nil limit:limit offset:offset];
            [self startLoading:self];
            break;
            
        case EXCHANGE_ACCESS_GROUP:
            accessProvider = [[AccessGroupProvider alloc] init];
            accessProvider.delegate = self;
            [accessProvider getAccessGroups];
            [self startLoading:self];
            break;
            
        case ADD_ACCESS_GROUP:
            titleLabel.text = NSLocalizedString(@"select_access_group", nil);
            multiSelect = YES;
            accessProvider = [[AccessGroupProvider alloc] init];
            accessProvider.delegate = self;
            [accessProvider getAccessGroups];
            [self startLoading:self];
            break;
            
        case EVENT_SELECT:
            eventArray = [[NSMutableArray alloc] init];
            titleLabel.text = NSLocalizedString(@"select_event", nil);
            multiSelect = YES;
            isSearchable = YES;
            break;
            
        case USER_SELECT:
            titleLabel.text = NSLocalizedString(@"select_user_original", nil);
            userProvider = [[UserProvider alloc] init];
            userProvider.delegate = self;
            [userProvider getUsersOffset:offset limit:limit groupID:@"1" query:nil];
            multiSelect = YES;
            isSearchable = YES;
            [self startLoading:self];
            break;
            
        case DOOR_CONTROL:
        {
            titleLabel.text = NSLocalizedString(@"door_control", nil);
            NSMutableDictionary *openDic = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *lockDic = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *unLockDic = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *APBdic = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *alarmDic = [[NSMutableDictionary alloc] init];
            
            [openDic setObject:NSLocalizedString(@"open", nil) forKey:@"name"];
            [openDic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            [contentListArray addObject:openDic];
            
            [lockDic setObject:NSLocalizedString(@"lock", nil) forKey:@"name"];
            [lockDic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            [contentListArray addObject:lockDic];
            
            [unLockDic setObject:NSLocalizedString(@"unlock", nil) forKey:@"name"];
            [unLockDic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            [contentListArray addObject:unLockDic];
            
            [APBdic setObject:NSLocalizedString(@"clear_apb", nil) forKey:@"name"];
            [APBdic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            [contentListArray addObject:APBdic];
            
            [alarmDic setObject:NSLocalizedString(@"clear_alarm", nil) forKey:@"name"];
            [alarmDic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            [contentListArray addObject:alarmDic];
            
            singleSelectTotalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)contentListArray.count];
            [self adjustHeight:contentListArray.count];
            
        }
            break;
        case TIME_ZONE:
            selectedIndex = NOT_SELECTED;
            titleLabel.text = NSLocalizedString(@"timezone", nil);
            singleSelectTotalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)contentListArray.count];
            
            multiSelect = NO;
            break;
        case TIME_FORMAT:
            selectedIndex = NOT_SELECTED;
            titleLabel.text = NSLocalizedString(@"time_format", nil);
            singleSelectTotalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)contentListArray.count];
            
            multiSelect = NO;
            break;
        case DATE_FORMAT:
            selectedIndex = NOT_SELECTED;
            titleLabel.text = NSLocalizedString(@"date_format", nil);
            singleSelectTotalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)contentListArray.count];
            
            multiSelect = NO;
            break;
        default:
            break;
    }
    
    if (multiSelect)
    {
        [textView setHidden:YES];
        [multiSelectView setHidden:NO];
        [singleSelectView setHidden:YES];
        if (isSearchable)
        {
            [multiSelectSearchView setHidden:NO];
        }
        else
        {
            // 액세스 그룹 팝업만 여기에 해당함
            [singleSelectView setHidden:NO];
            [singleSearchButton setHidden:YES];
            [multiSelectView setHidden:YES];
            [multiSelectSearchView setHidden:YES];
        }
    }
    else
    {
        [multiSelectView setHidden:YES];
        [singleSelectView setHidden:NO];
        [multiSelectSearchView setHidden:YES];
        
        if (isForSingleSearch)
        {
            [singleSearchButton setHidden:NO];
        }
        else
        {
            [singleSearchButton setHidden:YES];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [super popupViewDidAppear:contentView];
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

- (void)setContentList:(NSArray*)array
{
    
    for (NSDictionary *info in array)
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:info];
        [dic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        
        [contentListArray addObject:dic];
    }
    
    if (_type == EVENT_SELECT)
    {
        [eventArray addObjectsFromArray:contentListArray];
    }
    
    [listTableView reloadData];
    [self adjustHeight:contentListArray.count];
    
    totalCount = array.count;
    searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)selectedInfoArray.count, (unsigned long)totalCount];

}

- (IBAction)showSearchTextFieldView:(id)sender
{
    [textView setHidden:NO];
    [searchTextField resignFirstResponder];
}

- (IBAction)showSingleSearchView:(id)sender
{
    [singleSearchView setHidden:NO];
    [singleSearchTextField becomeFirstResponder];
}

- (IBAction)cancelSearch:(id)sender
{
    [self.view endEditing:YES];
    [textView setHidden:YES];
}

- (IBAction)cancelSingleSearch:(id)sender
{
    [self.view endEditing:YES];
    [singleSearchView setHidden:YES];
}

- (IBAction)selectAll:(id)sender
{
    UIButton *button = (UIButton*)sender;
    isSelectedAll = !isSelectedAll;
    [selectedInfoArray removeAllObjects];
    
    if (isSelectedAll)
    {
        for (NSMutableDictionary *info in contentListArray)
        {
            [info setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
        }
        [selectedInfoArray addObjectsFromArray:contentListArray];
        [button setImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
        multiSelectTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)selectedInfoArray.count,(unsigned long)contentListArray.count];
        searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)selectedInfoArray.count, (unsigned long)totalCount];
    }
    else
    {
        for (NSMutableDictionary *info in contentListArray)
        {
            [info setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        }
        [selectedInfoArray removeAllObjects];
        [button setImage:[UIImage imageNamed:@"check_box_blank"] forState:UIControlStateNormal];
        multiSelectTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)selectedInfoArray.count,(unsigned long)contentListArray.count];
        searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)selectedInfoArray.count, (unsigned long)totalCount];
    }
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < contentListArray.count; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPaths addObject:indexPath];
    }
    
    [listTableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)adjustHeight:(NSInteger)count
{
    if (count < 4)
    {
        containerHeightConstraint.constant = LIST_SUB_POPUP_MINIMUM_HEIGHT;
    }
    singleSelectTotalCountLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
    multiSelectTotalCountLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
    [containerView setHidden:NO];
    [self showPopupAnimation:containerView];
}

- (IBAction)cancelCurrentPopup:(id)sender
{
    [self closePopup:self parentViewController:self.parentViewController];
}

- (IBAction)confirmCurrentPopup:(id)sender
{
    switch (_type)
    {
        case USER_GROUP:
            if ([self.delegate respondsToSelector:@selector(confirmUserGroup:)])
            {
                if ([contentDic count] > 0)
                {
                    [self.delegate confirmUserGroup:contentDic];
                }
            }
            break;
            
        case DEVICE_FINGERPRINT:
            if ([self.delegate respondsToSelector:@selector(confirmDeviceForFingerprint:)])
            {
                if ([contentDic count] > 0)
                {
                    [self.delegate confirmDeviceForFingerprint:contentDic];
                }
            }
            break;
        case DEVICE_CARD:
            if ([self.delegate respondsToSelector:@selector(confirmDeviceForRegisterCard:)])
            {
                if ([contentDic count] > 0)
                {
                    [self.delegate confirmDeviceForRegisterCard:contentDic];
                }
                
            }
            break;
        case ASSIGN_CARD:
            if (multiSelect)
            {
                if ([self.delegate respondsToSelector:@selector(confirmCardsInfo:)])
                {
                    if ([selectedInfoArray count] > 0)
                        [self.delegate confirmCardsInfo:selectedInfoArray];
                }
            }
            else
            {
                if ([self.delegate respondsToSelector:@selector(confirmCardInfo:)])
                {
                    if ([contentDic count] > 0)
                        [self.delegate confirmCardInfo:contentDic];
                }
            }
            break;
        case EXCHANGE_CARD:
            if ([self.delegate respondsToSelector:@selector(confirmExchangeCard:)])
            {
                if ([contentDic count] > 0)
                    [self.delegate confirmExchangeCard:contentDic];
            }
            break;
        case EXCHANGE_ACCESS_GROUP:
            if ([self.delegate respondsToSelector:@selector(confirmExchangeAccessGroup:)])
            {
                if ([contentDic count] > 0)
                    [self.delegate confirmExchangeAccessGroup:contentDic];
            }
            break;
        case ADD_ACCESS_GROUP:
            if ([self.delegate respondsToSelector:@selector(confirmAddAccessGroup:)])
            {
                if ([selectedInfoArray count] > 0)
                    [self.delegate confirmAddAccessGroup:selectedInfoArray];
            }
            break;
        case EVENT_SELECT:
            if ([self.delegate respondsToSelector:@selector(confirmFilterEvents:)])
            {
                if ([selectedInfoArray count] > 0)
                    [self.delegate confirmFilterEvents:selectedInfoArray];
            }
            break;
        case USER_SELECT:
            if ([self.delegate respondsToSelector:@selector(confirmFilterUsers:)])
            {
                if ([selectedInfoArray count] > 0)
                    [self.delegate confirmFilterUsers:selectedInfoArray];
            }
            break;
        case DEVICE_SELECT:
            if ([self.delegate respondsToSelector:@selector(confirmFilterDevices:)])
            {
                if ([selectedInfoArray count] > 0)
                    [self.delegate confirmFilterDevices:selectedInfoArray];
            }
            break;
        case DOOR_CONTROL:
            if ([self.delegate respondsToSelector:@selector(confirmDoorControl:)])
            {
                if ([contentDic count] < 1)
                {
                    selectedIndex = NOT_SELECTED;
                }
                [self.delegate confirmDoorControl:selectedIndex];
            }
            break;
        case TIME_ZONE:
            if ([self.delegate respondsToSelector:@selector(confirmTimezone:)])
            {
                [self.delegate confirmTimezone:selectedIndex];
            }
            break;
        case TIME_FORMAT:
            if ([self.delegate respondsToSelector:@selector(confirmTimeFormat:)])
            {
                if ([contentDic count] > 0)
                {
                    [self.delegate confirmTimeFormat:contentDic];
                }
                
            }
            break;
        case DATE_FORMAT:
            if ([self.delegate respondsToSelector:@selector(confirmDateFormat:)])
            {
                if ([contentDic count] > 0)
                {
                    [self.delegate confirmDateFormat:contentDic];
                }
                
            }
            break;
        default:
            break;
    }
    
    [self closePopup:self parentViewController:self.parentViewController];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [contentListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RadioCell" forIndexPath:indexPath];
    RadioCell *customCell = (RadioCell*)cell;
    
    NSDictionary *currentDic = [contentListArray objectAtIndex:indexPath.row];
    
    [customCell checkSelected:[[currentDic objectForKey:@"selected"] boolValue]];
    
    switch (_type)
    {
        case ASSIGN_CARD:
        case EXCHANGE_CARD:
            customCell.titleLabel.text = [currentDic objectForKey:@"card_id"];
            if (indexPath.row == contentListArray.count -1)
            {
                if (hasNextPage)
                {
                    [userProvider getUsersOffset:offset limit:limit groupID:@"1" query:query];
                    [self startLoading:self];
                }
            }
            break;
        case USER_SELECT:
        {
            NSString *name = [currentDic objectForKey:@"name"];
            NSString *ID = [currentDic objectForKey:@"user_id"];
            if (nil == name || [name isEqualToString:@""])
            {
                name = ID;
            }
            NSString *description = [NSString stringWithFormat:@"%@ / %@",ID, name];
            customCell.titleLabel.text = description;
            
            if (indexPath.row == contentListArray.count -1)
            {
                if (hasNextPage)
                {
                    [userProvider getUsersOffset:offset limit:limit groupID:@"1" query:query];
                    [self startLoading:self];
                }
            }
        }
            break;
        case USER_GROUP:
        case DEVICE_FINGERPRINT:
        case DEVICE_CARD:
        case EXCHANGE_ACCESS_GROUP:
        case ADD_ACCESS_GROUP:
        case EVENT_SELECT:
        case DOOR_CONTROL:
        case DEVICE_SELECT:
        case TIME_ZONE:
            customCell.titleLabel.text = [currentDic objectForKey:@"name"];
            break;
        case TIME_FORMAT:
        case DATE_FORMAT:
            customCell.titleLabel.text = [[currentDic objectForKey:@"name"] lowercaseString];
            break;
        default:
            break;
    }
    
    return customCell;
}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = indexPath.row;
    
    if (multiSelect)
    {
        NSMutableDictionary *currentDic = [contentListArray objectAtIndex:indexPath.row];
        
        if ([[currentDic objectForKey:@"selected"] boolValue])
        {
            [currentDic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            [selectedInfoArray removeObject:currentDic];
        }
        else
        {
            [currentDic setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
            [selectedInfoArray addObject:currentDic];
        }
        
        multiSelectTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)selectedInfoArray.count,(unsigned long)contentListArray.count];
        searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)selectedInfoArray.count, (unsigned long)totalCount];
        singleSelectTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)selectedInfoArray.count, (unsigned long)totalCount];
        // select all 판단
        if (selectedInfoArray.count == totalCount)
        {
            // 전체선택
            [multiSearchSelectAllButton setImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
        }
        else
        {
            [multiSearchSelectAllButton setImage:[UIImage imageNamed:@"check_box_blank"] forState:UIControlStateNormal];
        }
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

    }
    else
    {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *currentDic = [contentListArray objectAtIndex:indexPath.row];
        
        NSInteger index = 0;
        
        for (NSMutableDictionary *content in contentListArray)
        {
            [content setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            
            [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
            index++;
            
        }
        
        [currentDic setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
        
        [contentDic setDictionary:[contentListArray objectAtIndex:indexPath.row]];
        
        [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - UserProviderDelegate

- (void)requestDidFinishGetUserGroups:(NSArray*)groups
{
    [self finishLoading];
    
    if ([groups isKindOfClass:[NSArray class]])
    {
        [self adjustHeight:groups.count];
        
        NSMutableArray *newGroup = [[NSMutableArray alloc] init];
        
        for (NSDictionary *group in groups)
        {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:group];
            [dic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            
            [newGroup addObject:dic];
        }
        
        singleSelectTotalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)groups.count];
        [contentListArray addObjectsFromArray:newGroup];
    }
    else
    {
        [self adjustHeight:0];
        singleSelectTotalCountLabel.text = @"0";
    }
    
    [listTableView reloadData];
    
}

- (void)requestDidFinishGettingUsersInfo:(NSArray*)userArray totclCount:(NSInteger)count
{
    [self finishLoading];
    
    if (isForSearch)
    {
        [multiSearchSelectAllButton setImage:[UIImage imageNamed:@"check_box_blank"] forState:UIControlStateNormal];
        [selectedInfoArray removeAllObjects];
        [contentListArray removeAllObjects];
        isForSearch = NO;
    }
    else
    {
        // 최초로 불러 올때만 팝업 사이즈 조절및 애니메이션 적용
        if (contentListArray.count == 0)
            [self adjustHeight:count];
    }
    
    totalCount = count;
    searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)selectedInfoArray.count, (unsigned long)totalCount];
    if (count == 0)
    {
        [contentListArray removeAllObjects];
    }
    else
    {
        // 선택 위해 뮤터블 딕션어리로 교체
        if ([userArray isKindOfClass:[NSArray class]])
        {
            for (NSDictionary *user in userArray)
            {
                NSMutableDictionary *tempUser = [[NSMutableDictionary alloc] initWithDictionary:user];
                [tempUser setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
                [contentListArray addObject:tempUser];
            }
        }
        
    }
    
    if (totalCount > contentListArray.count)
    {
        offset += limit;
        hasNextPage = YES;
    }
    else
    {
        hasNextPage = NO;
    }
    
    [listTableView reloadData];
}

- (void)requestUserProviderDidFail:(NSDictionary*)errDic
{
    // 팝업에서 API 호출후 실패날 경우 
    [self finishLoading];
    if ([self.delegate respondsToSelector:@selector(cancelListSubInfoPopupWithError:)])
    {
        [self.delegate cancelListSubInfoPopupWithError:errDic];
    }
    [self closePopup:self parentViewController:self.parentViewController];
}

#pragma mark - DeviceProviderDelegate

- (void)requestDeviceProviderDidFail:(NSDictionary*)errDic
{
    [self finishLoading];
    if ([self.delegate respondsToSelector:@selector(cancelListSubInfoPopupWithError:)])
    {
        [self.delegate cancelListSubInfoPopupWithError:errDic];
    }
    [self closePopup:self parentViewController:self.parentViewController];
}

- (void)requestGetCardsDidFinish:(NSDictionary *)cardColletion
{
    [self finishLoading];
    
    if (isForSearch)
    {
        isForSearch = NO;
        [contentListArray removeAllObjects];
    }
    else
    {
        if (contentListArray.count == 0)
            [self adjustHeight:contentListArray.count];
    }
    
    NSArray *rows = [cardColletion objectForKey:@"records"];
    // 최초로 불러 올때만 팝업 사이즈 조절및 애니메이션 적용
    if ([rows isKindOfClass:[NSArray class]])
    {
        [self adjustHeight:rows.count];
        NSMutableArray *newCardCollection = [[NSMutableArray alloc] init];
        
        for (NSDictionary *card in rows)
        {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:card];
            [dic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            
            [newCardCollection addObject:dic];
        }
        
        [contentListArray addObjectsFromArray:newCardCollection];
    }
    
    totalCount = [[cardColletion objectForKey:@"total"] integerValue];
    
    [listTableView reloadData];
    
    if (totalCount > limit)
    {
        hasNextPage = YES;
        offset += limit;
    }
    else
    {
        hasNextPage = NO;
    }

    singleSelectTotalCountLabel.text = [NSString stringWithFormat:@"%ld", (long)totalCount];
}

- (void)requestGetDevicesDidFinish:(NSArray*)devices totalCount:(NSInteger)total
{
    [self finishLoading];
    if (isForSearch)
    {
        isForSearch = NO;
        [selectedInfoArray removeAllObjects];
        [contentListArray removeAllObjects];
    }
    totalCount = total;
    multiSelectTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)selectedInfoArray.count,(unsigned long)contentListArray.count];
    searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)selectedInfoArray.count, (unsigned long)totalCount];
    
    [self adjustHeight:devices.count];
    NSMutableArray *newDevices = [[NSMutableArray alloc] init];
    
    for (NSDictionary *device in devices)
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:device];
        [dic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        
        [newDevices addObject:dic];
    }
    
    [contentListArray addObjectsFromArray:newDevices];

    
    [listTableView reloadData];
}

#pragma mark - AccessGroupProviderDelegate

- (void)requestGetAccessGroupsDidFinish:(NSDictionary*)accessGroupCollection
{
    [self finishLoading];
    NSArray *groups = [accessGroupCollection objectForKey:@"records"];
    
    totalCount = [[accessGroupCollection objectForKey:@"total"] integerValue];
    
    NSMutableArray *newAccessCollection = [[NSMutableArray alloc] init];
    
    if ([groups isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *card in groups)
        {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:card];
            [dic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            
            [newAccessCollection addObject:dic];
        }
        
        [contentListArray addObjectsFromArray:newAccessCollection];
    }
    
    [listTableView reloadData];
    
    [self adjustHeight:contentListArray.count];
    
    singleSelectTotalCountLabel.text = [NSString stringWithFormat:@"%ld", (long)totalCount];
}

- (void)requestAccessGroupProviderDidFail:(NSDictionary*)errDic
{
    [self finishLoading];
    if ([self.delegate respondsToSelector:@selector(cancelListSubInfoPopupWithError:)])
    {
        [self.delegate cancelListSubInfoPopupWithError:errDic];
    }
    [self closePopup:self parentViewController:self.parentViewController];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    isForSearch = YES;
    query = textField.text;
    offset = 0;
    if (_type == USER_GROUP)
    {
        [userProvider getUsersOffset:offset limit:limit groupID:@"1" query:query];
        [self startLoading:self];
        
    }
    else if (_type == DEVICE_SELECT)
    {
        [deviceProvider getDevices:query limit:10000 offset:offset];
        [self startLoading:self];
    }
    else if (_type == EVENT_SELECT)
    {
        NSMutableArray *searchArray = [[NSMutableArray alloc] init];
        
        for (NSMutableDictionary *event in eventArray)
        {
            [event setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];

            NSString *name = [event objectForKey:@"name"];
            query = [query uppercaseString];
            
            NSRange range;
            range = [name rangeOfString:query];
            
            if (range.location != NSNotFound)
            {
                [searchArray addObject:event];
            }
        }
        [selectedInfoArray removeAllObjects];
        [contentListArray removeAllObjects];
        [contentListArray addObjectsFromArray:searchArray];
        [listTableView reloadData];
        
        totalCount = contentListArray.count;
        
        searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)selectedInfoArray.count, (unsigned long)totalCount];
       
    }
    else if (_type == USER_SELECT)
    {
        [userProvider getUsersOffset:offset limit:limit groupID:@"1" query:query];
        [self startLoading:self];
    }
    else if (_type == ASSIGN_CARD || _type == EXCHANGE_CARD)
    {
        [deviceProvider getCards:query limit:limit offset:offset];
        [self startLoading:self];
    }
    
    
    
    [textField resignFirstResponder];
    return YES;
}

@end
