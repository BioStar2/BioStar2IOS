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
    menuIndex = NOT_SELECTED;
    
    [self setSharedViewController:self];
    
    openTimeArray = [[NSMutableArray alloc] init];
    
    if (self.detailInfo)
    {
        NSArray *args;
        switch (self.notiType)
        {
            case DOOR_FORCED_OPEN:
            {
                // 출입문 열림 시간 가져오기
                currentDoor = self.detailInfo.event.door_forced_open.door;
                
                titleLabel.text = NSBaseLocalizedString(self.detailInfo.event.door_forced_open.title_loc_key, nil);
                doorNameLabel.text = self.detailInfo.event.door_forced_open.door.name;
                
                args = self.detailInfo.event.door_forced_open.loc_args;
                
                doorDescription.text = [self getLocalizedDecription:@"notificationType.message.doorForcedOpen" args:args];
                
                [alarmImage setImage:[UIImage imageNamed:@"ic_event_door_02"]];
            }
                break;
            case ZONE_APB:
            {

                currentDoor = self.detailInfo.event.zone_apb.door;
                
                titleLabel.text = NSBaseLocalizedString(self.detailInfo.event.zone_apb.title_loc_key, nil);
                doorNameLabel.text = self.detailInfo.event.zone_apb.door.name;
                
                args = self.detailInfo.event.zone_apb.loc_args;
                
                doorDescription.text = [self getLocalizedDecription:@"notificationType.message.zoneApb" args:args];
                
                if (self.detailInfo.event.zone_apb.door)
                {
                    [alarmImage setImage:[UIImage imageNamed:@"ic_event_door_03"]];
                }
                else
                {
                    [alarmImage setImage:[UIImage imageNamed:@"ic_event_zone_03"]];
                }
                
            }
                break;
            case DOOR_HELD_OPEN:
            {
                currentDoor = self.detailInfo.event.door_held_open.door;
                
                titleLabel.text = NSBaseLocalizedString(self.detailInfo.event.door_held_open.title_loc_key, nil);
                doorNameLabel.text = self.detailInfo.event.door_held_open.door.name;
                
                args = self.detailInfo.event.door_held_open.loc_args;
                
                doorDescription.text = [self getLocalizedDecription:@"notificationType.message.doorHeldOpen" args:args];
                
                [alarmImage setImage:[UIImage imageNamed:@"ic_event_door_03"]];
            }
                break;
            default:
                break;
        }
        
        if ([PreferenceProvider isUpperVersion])
        {
            if ([AuthProvider hasWritePermission:DOOR_PERMISSION])
            {
                [doorControlButton setEnabled:YES];
            }
            else
            {
                if ([AuthProvider hasReadPermission:DOOR_PERMISSION] && [AuthProvider hasWritePermission:MONITORING_PERMISSION])
                {
                    [doorControlButton setEnabled:YES];
                }
                else
                {
                    [doorControlButton setEnabled:NO];
                }
                
            }
            
            if (![AuthProvider hasReadPermission:DOOR_PERMISSION])
            {
                [doorControlButton setEnabled:NO];
            }
        }
    }
}

- (NSString*)getLocalizedDecription:(NSString*)key args:(NSArray*)args
{
    NSString *dec;
    
    if (nil != args)
    {
        NSRange range = NSMakeRange(0, [args count]);
        NSMutableData* data = [NSMutableData dataWithLength: sizeof(id) * [args count]];
        [args getObjects: (__unsafe_unretained id *)data.mutableBytes range:range];
        
        NSString *content = [[NSString alloc] initWithFormat:NSBaseLocalizedString(key, nil) arguments:data.mutableBytes];
        return content;
    }
    
    return dec;
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



- (NSString*)getToastContent
{
    NSString *doorName = currentDoor.name;
    if ([doorName isEqualToString:@""] || nil == doorName)
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
    if ([doorName isEqualToString:@""] || nil == doorName)
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


@end
