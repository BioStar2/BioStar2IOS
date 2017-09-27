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
        currentDoor = self.detailInfo.event.door_open_request.door;
        doorNameLabel.text = currentDoor.name;
        if ([PreferenceProvider isUpperVersion])
        {
            if (nil == currentDoor)
            {
                [doorControlButton setEnabled:NO];
            }
            else
            {
                if (![AuthProvider hasReadPermission:DOOR_PERMISSION])
                {
                    [doorControlButton setEnabled:NO];
                }
            }
            
        }
        
        
        titleLabel.text = NSBaseLocalizedString(self.detailInfo.event.door_open_request.title_loc_key, nil);
        
        NSArray *args = self.detailInfo.event.door_open_request.loc_args;
        
        if (nil != args)
        {
            NSRange range = NSMakeRange(0, [args count]);
            NSMutableData* data = [NSMutableData dataWithLength: sizeof(id) * [args count]];
            [args getObjects: (__unsafe_unretained id *)data.mutableBytes range:range];
            
            NSString *content = [[NSString alloc] initWithFormat:NSBaseLocalizedString(@"notificationType.message.doorOpenRequest", nil) arguments:data.mutableBytes];
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
        [doorControlButton setEnabled:NO];
    }
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
            [doorProvider openDoor:[currentDoor.id integerValue] onComplete:^(Response *error) {
                
                [self finishLoading];
                
                [self showSuccessPopup:NSBaseLocalizedString(@"door_is_open", nil) message:[self getToastContent]];
                
            } onError:^(Response *error) {
                
                [self finishLoading];
                
                [self showErrorPopup:error.message];
            }];
        }
            break;
        case 1:
        {
            // lock
            [doorProvider lockDoor:[currentDoor.id integerValue] onComplete:^(Response *error) {
                [self finishLoading];
                
                [self showSuccessPopup:NSBaseLocalizedString(@"manual_lock", nil) message:[self getToastContent]];
                
            } onError:^(Response *error) {
                [self finishLoading];
                [self showErrorPopup:error.message];
                
            }];
        }
            break;
        case 2:
        {
            // unlock
            [doorProvider unlockDoor:[currentDoor.id integerValue] onComplete:^(Response *error) {
                [self finishLoading];
                
                [self showSuccessPopup:NSBaseLocalizedString(@"manual_unlock", nil) message:[self getToastContent]];
                
            } onError:^(Response *error) {
                [self finishLoading];
                
                [self showErrorPopup:error.message];
            }];
            
        }
            break;
        case 3:
        {
            // release
            [doorProvider releaseDoor:[currentDoor.id integerValue] onComplete:^(Response *error) {
                [self finishLoading];
                
                [self showSuccessPopup:NSBaseLocalizedString(@"release", nil) message:[self getToastContent]];
                
            } onError:^(Response *error) {
                [self finishLoading];
                
                [self showErrorPopup:error.message];
            }];
            
        }
            break;
        case 4:
        {
            // clear APB
            [doorProvider clearAntiPassback:[currentDoor.id integerValue] onComplete:^(Response *error) {
                [self finishLoading];
                
                
                [self showSuccessPopup:NSBaseLocalizedString(@"clear_apb", nil) message:[self getToastContent]];
                
            } onError:^(Response *error) {
                [self finishLoading];
                
                [self showErrorPopup:error.message];
            }];
            
        }
            break;
        case 5:
        {
            // clear alarm
            [doorProvider clearAlarm:[currentDoor.id integerValue] onComplete:^(Response *error) {
                [self finishLoading];
                
                
                [self showSuccessPopup:NSBaseLocalizedString(@"clear_alarm", nil) message:[self getToastContent]];
                
            } onError:^(Response *error) {
                [self finishLoading];
                
                [self showErrorPopup:error.message];
            }];
            
        }
            break;
    }
}

- (void)showErrorPopup:(NSString*)errorMessage
{
    [self finishLoading];
    
   
    NSString *title = nil;
    switch (menuIndex)
    {
        case 0:
            // open
            title = NSBaseLocalizedString(@"request_open_fail", nil);
            break;
        case 1:
            // lock
            title = [NSString stringWithFormat:@"%@ %@",NSBaseLocalizedString(@"manual_lock", nil) ,NSBaseLocalizedString(@"fail", nil)];
            break;
        case 2:
            // unlock
            title = [NSString stringWithFormat:@"%@ %@",NSBaseLocalizedString(@"manual_unlock", nil) ,NSBaseLocalizedString(@"fail", nil)];
            break;
        case 3:
            // release
            title = [NSString stringWithFormat:@"%@ %@",NSBaseLocalizedString(@"release", nil) ,NSBaseLocalizedString(@"fail", nil)];
            break;
        case 4:
            // clear APB
            title = [NSString stringWithFormat:@"%@ %@",NSBaseLocalizedString(@"clear_apb", nil) ,NSBaseLocalizedString(@"fail", nil)];
            break;
        case 5:
            // clear alarm
            title = [NSString stringWithFormat:@"%@ %@",NSBaseLocalizedString(@"clear_alarm", nil) ,NSBaseLocalizedString(@"fail", nil)];
            break;
            
        default:
            break;
    }
    
//    [self.view makeToast:[self getErrorToastContent:errorMessage]
//                duration:2.0 position:CSToastPositionBottom
//                   title:title
//                   image:[UIImage imageNamed:@"toast_popup_i_02"]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    OneButtonPopupViewController *oneButtonPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonPopupViewController"];
    oneButtonPopupCtrl.type = DOOR_CONTROL;
    
    [oneButtonPopupCtrl setTitleStr:title];
    [oneButtonPopupCtrl setPopupContent:[self getErrorToastContent:errorMessage]];
    
    [self showPopup:oneButtonPopupCtrl parentViewController:self parentView:self.view];
    
}

- (void)showSuccessPopup:(NSString*)title message:(NSString*)message
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    OneButtonPopupViewController *oneButtonPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonPopupViewController"];
    oneButtonPopupCtrl.type = DOOR_CONTROL;
    
    [oneButtonPopupCtrl setTitleStr:title];
    [oneButtonPopupCtrl setPopupContent:message];
    
    [self showPopup:oneButtonPopupCtrl parentViewController:self parentView:self.view];
}

- (NSString*)getToastContent
{
    NSString *doorName = currentDoor.name;
    if (nil == doorName)
    {
        doorName = currentDoor.id;
    }
    
    NSString *timeFormat;
    
    if ([[LocalDataManager getTimeFormat] isEqualToString:@"hh:mm a"])
    {
        timeFormat = [NSString stringWithFormat:@"%@ %@",[LocalDataManager getDateFormat], @"hh:mm:ss a"];
    }
    else
    {
        timeFormat = [NSString stringWithFormat:@"%@ %@:ss",[LocalDataManager getDateFormat], [LocalDataManager getTimeFormat]];
    }
    
    NSString *dateString = [CommonUtil stringFromCurrentLocaleDateString:[[NSDate date] description] originDateFormat:@"YYYY-MM-dd HH:mm:ss z" transDateFormat:timeFormat];
    
    
    NSString *toastContent = [NSString stringWithFormat:@"%@ / %@",dateString ,doorName];
    return toastContent;
}

- (NSString*)getErrorToastContent:(NSString *)message
{
    NSString *doorName = currentDoor.name;
    if (nil == doorName)
    {
        doorName = currentDoor.id;
    }
    
    NSString *timeFormat;
    
    if ([[LocalDataManager getTimeFormat] isEqualToString:@"hh:mm a"])
    {
        timeFormat = [NSString stringWithFormat:@"%@ %@",[LocalDataManager getDateFormat], @"hh:mm:ss a"];
    }
    else
    {
        timeFormat = [NSString stringWithFormat:@"%@ %@:ss",[LocalDataManager getDateFormat], [LocalDataManager getTimeFormat]];
    }
    
    NSString *dateString = [CommonUtil stringFromCurrentLocaleDateString:[[NSDate date] description] originDateFormat:@"YYYY-MM-dd HH:mm:ss z" transDateFormat:timeFormat];
    
    
    NSString *toastContent = [NSString stringWithFormat:@"%@\n%@\n%@", doorName, dateString, message];
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
            
            if ([[LocalDataManager getTimeFormat] isEqualToString:@"hh:mm a"])
            {
                timeFormat = [NSString stringWithFormat:@"%@ %@",[LocalDataManager getDateFormat], @"hh:mm:ss a"];
            }
            else
            {
                timeFormat = [NSString stringWithFormat:@"%@ %@:ss",[LocalDataManager getDateFormat], [LocalDataManager getTimeFormat]];
            }
            
            NSString *content = [CommonUtil stringFromCurrentLocaleDateString:[calculatedDate description]
                                                             originDateFormat:@"YYYY-MM-dd HH:mm:ss z"
                                                              transDateFormat:timeFormat];
            
            [cell setContent:NSBaseLocalizedString(@"notification_time", nil) content:content];

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
            [cell setContent:NSBaseLocalizedString(@"user", nil) content:content];
            return cell;
        }
            break;
        case 2:
        {
            // 전화번호
            if (nil == phoneNumber || [phoneNumber isEqualToString:@""])
            {
                AlarmDoorDetailNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmDoorDetailNormalCell" forIndexPath:indexPath];
                [cell setContent:NSBaseLocalizedString(@"telephone", nil) content:NSBaseLocalizedString(@"none", nil)];
                return cell;
            }
            else
            {
                AlarmDoorDetailAcclCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmDoorDetailAcclCell" forIndexPath:indexPath];
                NSString *content = phoneNumber;
                [cell setContent:NSBaseLocalizedString(@"telephone", nil) content:content];
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
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNumber]] options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @NO} completionHandler:^(BOOL success) {
                
            }];
            
        }
    }
    
}


@end
