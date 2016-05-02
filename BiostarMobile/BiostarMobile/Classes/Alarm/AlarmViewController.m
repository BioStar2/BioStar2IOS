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
    titleLabel.text = NSLocalizedString(@"alarm", nil);
    isDeleteMode = NO;
    alarmArray = [[NSMutableArray alloc] init];
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
    provider.delegate = self;
    [provider getNotifications:limit offset:offset];
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

- (void)refreshAlarms
{
    offset = 0;
    [alarmArray removeAllObjects];
    [alarmTableView reloadData];
    [provider getNotifications:limit offset:offset];
    [self startLoading:self];
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
        
        for (NSMutableDictionary *alarm in alarmArray)
        {
            [alarm setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
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
    
    if (nil == alarmArray || alarmArray.count == 0)
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
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:alarmArray.count - 1 inSection:0];
        [alarmTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
        
        if (alarmArray.count == totalCount)
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
        imagePopupCtrl.delegate = self;
        imagePopupCtrl.titleContent = NSLocalizedString(@"delete_confirm_question", nil);
        imagePopupCtrl.type = WARNING;
        [imagePopupCtrl setContent:[NSString stringWithFormat:NSLocalizedString(@"selected_count %ld", nil), toDeleteArray.count]];
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
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
    
    for (NSMutableDictionary *notiInfo in alarmArray)
    {
        [notiInfo setObject:[NSNumber numberWithBool:isSelectedAll] forKey:@"selected"];
        
        if (isSelectedAll)
        {
            [toDeleteArray addObject:[notiInfo objectForKey:@"id"]];
            if ([[notiInfo objectForKey:@"status"] isEqualToString:@"UNREAD"])
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
    NSDictionary *notiInfo = [alarmArray objectAtIndex:alarmIndex];
    
    if ([[notiInfo objectForKey:@"status"] isEqualToString:@"UNREAD"])
    {
        toDeletedNewAlarmCount = 1;
        isReadAlarm = YES;
        [provider readNotification:[notiInfo objectForKey:@"id"]];
        [self startLoading:self];
    }
    else
    {
        [self moveToAlarmDetail:notiInfo];
    }
}

- (void)moveToAlarmDetail:(NSDictionary*)notiInfo
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if ([[notiInfo objectForKey:@"type"] isEqualToString:@"DOOR_OPEN_REQUEST"])
    {
        AlarmDoorDetailController __weak *alarmDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmDoorDetailController"];
        
        [alarmDetailViewController setDetailInfo:notiInfo];
        [self pushChildViewController:alarmDetailViewController parentViewController:self contentView:self.view animated:YES];
    }
    else if ([[notiInfo objectForKey:@"type"] isEqualToString:@"DOOR_FORCED_OPEN"])
    {
        AlarmForcedOpenDetailController __weak *alarmForceViewController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmForcedOpenDetailController"];
        [alarmForceViewController setDetailInfo:notiInfo];
        alarmForceViewController.alarmType = DOOR_FORCED_OPEN;
        [self pushChildViewController:alarmForceViewController parentViewController:self contentView:self.view animated:YES];
    }
    else if ([[notiInfo objectForKey:@"type"] isEqualToString:@"DOOR_HELD_OPEN"])
    {
        AlarmForcedOpenDetailController __weak *alarmForceViewController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmForcedOpenDetailController"];
        [alarmForceViewController setDetailInfo:notiInfo];
        alarmForceViewController.alarmType = DOOR_HELD_OPEN;
        [self pushChildViewController:alarmForceViewController parentViewController:self contentView:self.view animated:YES];
    }
    else if ([[notiInfo objectForKey:@"type"] isEqualToString:@"DEVICE_TAMPERING"])
    {
        AlarmDeviceDetailController __weak *alarmDeviceViewController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmDeviceDetailController"];
        [alarmDeviceViewController setDetailInfo:notiInfo];
        alarmDeviceViewController.alarmType = DEVICE_TAMPERING;
        [self pushChildViewController:alarmDeviceViewController parentViewController:self contentView:self.view animated:YES];
    }
    else if ([[notiInfo objectForKey:@"type"] isEqualToString:@"DEVICE_REBOOT"])
    {
        AlarmDeviceDetailController __weak *alarmDeviceViewController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmDeviceDetailController"];
        [alarmDeviceViewController setDetailInfo:notiInfo];
        alarmDeviceViewController.alarmType = DEVICE_REBOOT;
        [self pushChildViewController:alarmDeviceViewController parentViewController:self contentView:self.view animated:YES];
    }
    else if ([[notiInfo objectForKey:@"type"] isEqualToString:@"DEVICE_RS485_DISCONNECT"])
    {
        AlarmDeviceDetailController __weak *alarmDeviceViewController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmDeviceDetailController"];
        [alarmDeviceViewController setDetailInfo:notiInfo];
        alarmDeviceViewController.alarmType = DEVICE_RS485_DISCONNECT;
        [self pushChildViewController:alarmDeviceViewController parentViewController:self contentView:self.view animated:YES];
    }
    else if ([[notiInfo objectForKey:@"type"] isEqualToString:@"ZONE_APB"])
    {
        if ([[[notiInfo objectForKey:@"event"] objectForKey:@"zone_apb"] objectForKey:@"door"])
        {
            AlarmForcedOpenDetailController __weak *alarmForceViewController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmForcedOpenDetailController"];
            [alarmForceViewController setDetailInfo:notiInfo];
            alarmForceViewController.alarmType = ZONE_APB;
            [self pushChildViewController:alarmForceViewController parentViewController:self contentView:self.view animated:YES];
        }
        else
        {
            AlarmDeviceDetailController __weak *alarmDeviceViewController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmDeviceDetailController"];
            [alarmDeviceViewController setDetailInfo:notiInfo];
            alarmDeviceViewController.alarmType = ZONE_APB;
            [self pushChildViewController:alarmDeviceViewController parentViewController:self contentView:self.view animated:YES];
        }
    }
    else if ([[notiInfo objectForKey:@"type"] isEqualToString:@"ZONE_FIRE"])
    {
        AlarmDeviceDetailController __weak *alarmDeviceViewController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmDeviceDetailController"];
        [alarmDeviceViewController setDetailInfo:notiInfo];
        alarmDeviceViewController.alarmType = ZONE_FIRE;
        [self pushChildViewController:alarmDeviceViewController parentViewController:self contentView:self.view animated:YES];
    }
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [alarmArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlarmCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *dic = [alarmArray objectAtIndex:indexPath.row];
    [cell setAlarmCell:dic isDeleteMode:isDeleteMode];
    
    if (indexPath.row == alarmArray.count -1)
    {
        if (hasNextPage)
        {
            [provider getNotifications:limit offset:offset];
            [self startLoading:self];
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
    NSDictionary *dic = [alarmArray objectAtIndex:indexPath.row];
    [toDeleteArray addObject:[dic valueForKey:@"id"]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    TextPopupViewController *textPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"TextPopupViewController"];
    textPopupCtrl.delegate = self;
    textPopupCtrl.type = ALARM_DELETE;
    [self showPopup:textPopupCtrl parentViewController:self parentView:self.view];
    
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isDeleteMode)
    {
        NSMutableDictionary *alarmDic = [alarmArray objectAtIndex:indexPath.row];
        
        if ([[alarmDic objectForKey:@"selected"] boolValue])
        {
            [alarmDic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            
            if ([[alarmDic objectForKey:@"status"] isEqualToString:@"UNREAD"])
            {
                toDeletedNewAlarmCount--;
            }
            
            [toDeleteArray removeObject:[alarmDic valueForKey:@"id"]];
        }
        else
        {
            if ([[alarmDic objectForKey:@"status"] isEqualToString:@"UNREAD"])
            {
                toDeletedNewAlarmCount++;
            }
            
            [alarmDic setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
            [toDeleteArray addObject:[alarmDic valueForKey:@"id"]];
        }
        deleteTotalCount.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)toDeleteArray.count, (long)totalCount];
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if (toDeleteArray.count == alarmArray.count)
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


#pragma mark - PreferenceProviderDelegate

- (void)requestGetNotificationsDidFinish:(NSDictionary*)resultdic
{
    [refreshControl endRefreshing];
    [self finishLoading];
    totalCount = [[resultdic objectForKey:@"total"] integerValue];
    totalCountLabel.text = [[resultdic objectForKey:@"total"] stringValue];
    deleteTotalCount.text = [[resultdic objectForKey:@"total"] stringValue];
    
    if ([[resultdic objectForKey:@"records"] isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *alarm in [resultdic objectForKey:@"records"])
        {
            NSMutableDictionary *tempAlarm = [[NSMutableDictionary alloc] initWithDictionary:alarm];
            [tempAlarm setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            [alarmArray addObject:tempAlarm];
        }
    }
    
    // 다음 페이지 체크
    if (alarmArray.count < [[resultdic objectForKey:@"total"] integerValue])
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
}

- (void)requestReadNotificationDidFinish:(NSDictionary*)resultdic
{
    isReadAlarm = NO;
    [self finishLoading];
    // 알람 종류에 따라 각기 다른 디테일로 이동
    NSMutableDictionary *alarmDic = [alarmArray objectAtIndex:alarmIndex];
    [alarmDic setObject:@"READ" forKey:@"status"];
    NSIndexPath *path = [NSIndexPath indexPathForRow:alarmIndex inSection:0];
    [alarmTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ALARM_COUNT_UPDATE object:@{@"count" :[NSNumber numberWithInteger:toDeletedNewAlarmCount]}];
    
    [self moveToAlarmDetail:[alarmArray objectAtIndex:alarmIndex]];
    toDeletedNewAlarmCount = 0;
}

- (void)requestDeleteNotificationDidFinish:(NSDictionary*)resultdic
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ALARM_COUNT_UPDATE object:@{@"count" :[NSNumber numberWithInteger:toDeletedNewAlarmCount]}];
    [toDeleteArray removeAllObjects];
    deleteTotalCount.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)toDeleteArray.count, (long)totalCount];
    toDeletedNewAlarmCount = 0;
    
    isSelectedAll = NO;
    [selectAllButton setImage:[UIImage imageNamed:@"check_box_blank"] forState:UIControlStateNormal];
    
    [self finishLoading];
    [self refreshAlarms];
}

- (void)requestPreferenceProviderDidFail:(NSDictionary*)errDic
{
    isReadAlarm = NO;
    [refreshControl endRefreshing];
    [self finishLoading];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
    [imagePopupCtrl setContent:[errDic objectForKey:@"message"]];
    imagePopupCtrl.delegate = self;
    
    if (isDeleteMode)
    {
        imagePopupCtrl.type = REQUEST_FAIL;
    }
    else
    {
        imagePopupCtrl.type = MAIN_REQUEST_FAIL;
    }
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
}

#pragma mark - ImagePopupDelegate

- (void)confirmImagePopup
{
    if (isReadAlarm)
    {
        // 알람 읽기 실패후 재시도
        [self readAlarm:alarmIndex];
    }
    else
    {
        // 알람 삭제 API 호출 (선택된 알람 삭제)
        [self startLoading:self];
        [provider deleteNotifications:toDeleteArray];
    }
    
}

#pragma mark - TextPopupDelegate
- (void)confirmDeleteAlarm
{
    // 테이블뷰 스와이프에서 삭제
    [self startLoading:self];
    [provider deleteNotifications:toDeleteArray];
}
@end
