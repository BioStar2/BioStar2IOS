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

#import "AlarmViewController.h"

@interface AlarmViewController ()

@end

@implementation AlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setSharedViewController:self];
    titleLabel.text = NSLocalizedString(@"alarm", nil);
    totalDecLabel.text = NSLocalizedString(@"total", nil);
    selectTotalDecLabel.text = NSLocalizedString(@"total", nil);
    
    isDeleteMode = NO;
    notifications = [[NSMutableArray alloc] init];
    toDeleteArray = [[NSMutableArray alloc] init];
    hasNextPage = NO;
    canScrollTop = NO;
    isSelectedAll = NO;
    isReadAlarm = NO;
    limit = 50;
    offset = 0;
    toDeletedNewAlarmCount = 0;
    secondYPosition = 0.0f;
    refreshControl = [[UIRefreshControl alloc] init];
    //refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"refresh Alarms"];
    [alarmTableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshAlarms) forControlEvents:UIControlEventValueChanged];
    
    scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
    
    provider = [[PreferenceProvider alloc] init];
    [self getNotifications:limit offset:offset];
    
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

- (void)getNotifications:(NSInteger)notiLimit offset:(NSInteger)notiOffset
{
    [self startLoading:self];
    
    [provider getNotifications:notiLimit offset:notiOffset resultBlock:^(NotificationSearchResult *result) {
        [self finishLoading];
        
        [refreshControl endRefreshing];
        [self finishLoading];
        totalCount = result.total;
        totalCountLabel.text = [NSString stringWithFormat:@"%ld", (long)result.total];
        deleteTotalCount.text = [NSString stringWithFormat:@"%ld", (long)result.total];
        
        [notifications addObjectsFromArray:result.records];
        
        // 다음 페이지 체크
        if (notifications.count < result.total)
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
        [alarmTableView reloadData];
        
    } onError:^(Response *error) {
        [self finishLoading];
        
        isReadAlarm = NO;
        [refreshControl endRefreshing];
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        if (isDeleteMode)
        {
            imagePopupCtrl.type = REQUEST_FAIL;
        }
        else
        {
            imagePopupCtrl.type = MAIN_REQUEST_FAIL;
        }
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self getNotifications:notiLimit offset:notiOffset];
            }
        }];
    }];
    
    
}

- (void)readNotification:(NSString*)notiID
{
    [self startLoading:self];
    
    [provider readNotification:notiID onComplete:^(Response *error) {
        [self finishLoading];
        
        isReadAlarm = NO;
        // 알람 종류에 따라 각기 다른 디테일로 이동
        GetNotification *notification = [notifications objectAtIndex:alarmIndex];
        notification.status = @"READ";
        NSIndexPath *path = [NSIndexPath indexPathForRow:alarmIndex inSection:0];
        [alarmTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ALARM_COUNT_UPDATE object:@{@"count" :[NSNumber numberWithInteger:toDeletedNewAlarmCount]}];
        
        [self moveToAlarmDetail:[notifications objectAtIndex:alarmIndex]];
        toDeletedNewAlarmCount = 0;
        
    } onError:^(Response *error) {
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self readNotification:notiID];
            }
        }];
    }];
    
}

- (void)deleteNotifications:(NSArray*)notiIDs
{
    [self startLoading:self];
    
    [provider deleteNotifications:toDeleteArray onComplete:^(Response *error) {
        [self finishLoading];
        [[NSNotificationCenter defaultCenter] postNotificationName:ALARM_COUNT_UPDATE object:@{@"count" :[NSNumber numberWithInteger:toDeletedNewAlarmCount]}];
        [toDeleteArray removeAllObjects];
        deleteTotalCount.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)toDeleteArray.count, (long)totalCount];
        toDeletedNewAlarmCount = 0;
        
        isSelectedAll = NO;
        [selectAllButton setImage:[UIImage imageNamed:@"check_box_blank"] forState:UIControlStateNormal];
        
        [self finishLoading];
        [self refreshAlarms];
    } onError:^(Response *error) {
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self deleteNotifications:notiIDs];
            }
        }];
    }];
    
}

- (void)refreshAlarms
{
    offset = 0;
    [notifications removeAllObjects];
    [alarmTableView reloadData];
    [self getNotifications:limit offset:offset];
}

- (IBAction)moveToBack:(id)sender
{
    if (isDeleteMode)
    {
        toDeletedNewAlarmCount = 0;
        titleLabel.text = NSLocalizedString(@"alarm", nil);
        [deleteButton setHidden:NO];
        [doneButton setHidden:YES];
        [deleteTotalCountView setHidden:YES];
        isDeleteMode = NO;
        [toDeleteArray removeAllObjects];
        
        for (GetNotification *noti in notifications)
        {
            noti.isSelected = NO;
        }
        
        [alarmTableView reloadData];
    }
    else
    {
        [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
    }

}

- (IBAction)changeToDeleteMode:(id)sender
{
    titleLabel.text = NSLocalizedString(@"delete_alarm", nil);
    deleteTotalCount.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)toDeleteArray.count, (long)totalCount];
    [deleteButton setHidden:YES];
    [doneButton setHidden:NO];
    [deleteTotalCountView setHidden:NO];
    isDeleteMode = YES;
    [alarmTableView reloadData];
}


- (IBAction)scrollTopOrBottom:(id)sender {
    
    if (nil == notifications || notifications.count == 0)
    {
        return;
    }
    
    if (canScrollTop)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [alarmTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
        canScrollTop = NO;
    }
    else
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:notifications.count - 1 inSection:0];
        [alarmTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
        
        if (notifications.count == totalCount)
        {
            canScrollTop = YES;
            scrollButton.transform = CGAffineTransformMakeRotation(0);
        }
    }

}

- (IBAction)deleteAlarm:(id)sender
{
    if (toDeleteArray.count > 0)
    {
        //삭제 팝업 노출
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        //imagePopupCtrl.delegate = self;
        imagePopupCtrl.titleContent = NSLocalizedString(@"delete_confirm_question", nil);
        imagePopupCtrl.type = WARNING;
        [imagePopupCtrl setContent:[NSString stringWithFormat:NSLocalizedString(@"selected_count %ld", nil), toDeleteArray.count]];
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self deleteNotifications:toDeleteArray];
            }
        }];
    }
    else
    {
        [self.view makeToast:NSLocalizedString(@"selected_none", nil)
                    duration:2.0
                    position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_03"]];
    }
    
}

- (IBAction)selectAll:(id)sender
{
    isSelectedAll = !isSelectedAll;
    [toDeleteArray removeAllObjects];
    
    for (GetNotification *notiInfo in notifications)
    {
        notiInfo.isSelected = isSelectedAll;
        
        
        if (isSelectedAll)
        {
            [toDeleteArray addObject:notiInfo.id];
            if ([notiInfo.status isEqualToString:@"UNREAD"])
            {
                toDeletedNewAlarmCount++;
            }
        }
    }
    
    if (isSelectedAll)
    {
        [selectAllButton setImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
    }
    else
    {
        [selectAllButton setImage:[UIImage imageNamed:@"check_box_blank"] forState:UIControlStateNormal];
        [toDeleteArray removeAllObjects];
        toDeletedNewAlarmCount = 0;
    }
    
    deleteTotalCount.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)toDeleteArray.count, (long)totalCount];
    [alarmTableView reloadData];
}

- (void)readAlarm:(NSInteger)index
{
    alarmIndex = index;
    GetNotification *notiInfo = [notifications objectAtIndex:alarmIndex];
    
    if ([notiInfo.status isEqualToString:@"UNREAD"])
    {
        toDeletedNewAlarmCount = 1;
        isReadAlarm = YES;
        [self readNotification:notiInfo.id];
    }
    else
    {
        [self moveToAlarmDetail:notiInfo];
    }
}

- (void)moveToAlarmDetail:(GetNotification*)notiInfo
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    NotificationType notiType = [notiInfo.type notificationTypeEnumFromString];
    
    switch (notiType) {
        case DOOR_OPEN_REQUEST:
        {
            AlarmDoorDetailController __weak *alarmDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmDoorDetailController"];
            
            [alarmDetailViewController setDetailInfo:notiInfo];
            [self pushChildViewController:alarmDetailViewController parentViewController:self contentView:self.view animated:YES];
        }
            break;
            
        case DOOR_FORCED_OPEN:
        {
            AlarmForcedOpenDetailController __weak *alarmForceViewController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmForcedOpenDetailController"];
            [alarmForceViewController setDetailInfo:notiInfo];
            alarmForceViewController.notiType = notiType;
            [self pushChildViewController:alarmForceViewController parentViewController:self contentView:self.view animated:YES];
        }
            break;
            
        case DOOR_HELD_OPEN:
        {
            AlarmForcedOpenDetailController __weak *alarmForceViewController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmForcedOpenDetailController"];
            [alarmForceViewController setDetailInfo:notiInfo];
            alarmForceViewController.notiType = notiType;
            [self pushChildViewController:alarmForceViewController parentViewController:self contentView:self.view animated:YES];
        }
            break;
            
        case DEVICE_TAMPERING:
        {
            AlarmDeviceDetailController __weak *alarmDeviceViewController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmDeviceDetailController"];
            [alarmDeviceViewController setDetailInfo:notiInfo];
            alarmDeviceViewController.notiType = notiType;
            [self pushChildViewController:alarmDeviceViewController parentViewController:self contentView:self.view animated:YES];
        }
            break;
            
        case DEVICE_REBOOT:
        {
            AlarmDeviceDetailController __weak *alarmDeviceViewController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmDeviceDetailController"];
            [alarmDeviceViewController setDetailInfo:notiInfo];
            alarmDeviceViewController.notiType = notiType;
            [self pushChildViewController:alarmDeviceViewController parentViewController:self contentView:self.view animated:YES];
        }
            break;
            
        case DEVICE_RS485_DISCONNECT:
        {
            AlarmDeviceDetailController __weak *alarmDeviceViewController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmDeviceDetailController"];
            [alarmDeviceViewController setDetailInfo:notiInfo];
            alarmDeviceViewController.notiType = notiType;
            [self pushChildViewController:alarmDeviceViewController parentViewController:self contentView:self.view animated:YES];
        }
            break;
            
        case ZONE_APB:
        {
            if (notiInfo.event.zone_apb.door)
            {
                AlarmForcedOpenDetailController __weak *alarmForceViewController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmForcedOpenDetailController"];
                [alarmForceViewController setDetailInfo:notiInfo];
                alarmForceViewController.notiType = notiType;
                [self pushChildViewController:alarmForceViewController parentViewController:self contentView:self.view animated:YES];
            }
            else
            {
                AlarmDeviceDetailController __weak *alarmDeviceViewController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmDeviceDetailController"];
                [alarmDeviceViewController setDetailInfo:notiInfo];
                alarmDeviceViewController.notiType = notiType;
                [self pushChildViewController:alarmDeviceViewController parentViewController:self contentView:self.view animated:YES];
            }
        }
            break;
            
        case ZONE_FIRE:
        {
            AlarmDeviceDetailController __weak *alarmDeviceViewController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmDeviceDetailController"];
            [alarmDeviceViewController setDetailInfo:notiInfo];
            alarmDeviceViewController.notiType = notiType;
            [self pushChildViewController:alarmDeviceViewController parentViewController:self contentView:self.view animated:YES];
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
    return [notifications count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlarmCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmCell" forIndexPath:indexPath];
    
    // Configure the cell...
    GetNotification *notification = [notifications objectAtIndex:indexPath.row];
    [cell setAlarmCell:notification isDeleteMode:isDeleteMode];
    
    if (indexPath.row == notifications.count -1)
    {
        if (hasNextPage)
        {
            [self getNotifications:limit offset:offset];
        }
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    GetNotification *notification = [notifications objectAtIndex:indexPath.row];
    [toDeleteArray addObject:notification.id];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    TextPopupViewController *textPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"TextPopupViewController"];
    
    textPopupCtrl.type = ALARM_DELETE;
    [self showPopup:textPopupCtrl parentViewController:self parentView:self.view];
    
    [textPopupCtrl getResponse:^(TextPopupType type, BOOL isConfirm) {
        if (isConfirm)
        {
            [self deleteNotifications:toDeleteArray];
        }
    }];
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isDeleteMode)
    {
        GetNotification *notification = [notifications objectAtIndex:indexPath.row];
        
        if (notification.isSelected)
        {
            notification.isSelected = NO;
            if ([notification.status isEqualToString:@"UNREAD"])
            {
                toDeletedNewAlarmCount--;
            }
            
            [toDeleteArray removeObject:notification.id];
        }
        else
        {
            if ([notification.status isEqualToString:@"UNREAD"])
            {
                toDeletedNewAlarmCount++;
            }
            
            notification.isSelected = YES;
            [toDeleteArray addObject:notification.id];
        }
        deleteTotalCount.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)toDeleteArray.count, (long)totalCount];
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if (toDeleteArray.count == notifications.count)
        {
            isSelectedAll = YES;
            [selectAllButton setImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
        }
        else
        {
            isSelectedAll = NO;
            [selectAllButton setImage:[UIImage imageNamed:@"check_box_blank"] forState:UIControlStateNormal];
        }
        
    }
    else
    {
        [self readAlarm:indexPath.row];
    }
    
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
            canScrollTop = NO;
    }
    else
    {
        // 스크롤 아래로
        if (decelerate)
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
    
    if (scrollView.contentOffset.y > scrollView.contentSize.height - alarmTableView.frame.size.height) {
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
    
    
    if (scrollView.contentOffset.y > scrollView.contentSize.height - alarmTableView.frame.size.height) {
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
