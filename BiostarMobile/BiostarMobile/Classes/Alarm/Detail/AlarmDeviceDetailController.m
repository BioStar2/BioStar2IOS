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

#import "AlarmDeviceDetailController.h"

@interface AlarmDeviceDetailController ()

@end

@implementation AlarmDeviceDetailController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.

    NSString *deviceID;
    
    if (self.detailInfo)
    {
        NSArray *args;
        switch (self.notiType)
        {
            case DEVICE_TAMPERING:
            {
                titleLabel.text = titleLabel.text = NSLocalizedString(self.detailInfo.event.device_tampering.title_loc_key, nil);
                deviceName.text = self.detailInfo.event.device_tampering.device.name;
                deviceID = self.detailInfo.event.device_tampering.device.id;
                
                args = self.detailInfo.event.device_tampering.loc_args;
                deviceDescription.text = [self getLocalizedDecription:@"notificationType.message.deviceTampering" args:args];
                
                [alarmImage setImage:[UIImage imageNamed:@"ic_event_device_03"]];
            }
                break;
            case DEVICE_REBOOT:
                
                titleLabel.text = NSLocalizedString(self.detailInfo.event.device_reboot.title_loc_key, nil);
                deviceName.text = self.detailInfo.event.device_reboot.device.name;
                deviceID = self.detailInfo.event.device_reboot.device.id;
                
                args = self.detailInfo.event.device_reboot.loc_args;
                
                deviceDescription.text = [self getLocalizedDecription:@"notificationType.message.deviceReboot" args:args];
                
                
                [alarmImage setImage:[UIImage imageNamed:@"ic_event_device_01"]];
                break;
            case DEVICE_RS485_DISCONNECT:
                
                titleLabel.text = NSLocalizedString(self.detailInfo.event.device_rs485_disconnect.title_loc_key, nil);
                deviceName.text = self.detailInfo.event.device_rs485_disconnect.device.name;
                deviceID = self.detailInfo.event.device_rs485_disconnect.device.id;
                
                args = self.detailInfo.event.device_rs485_disconnect.loc_args;
                
                deviceDescription.text = [self getLocalizedDecription:@"notificationType.message.deviceRs485Disconnect" args:args];
                
                
                [alarmImage setImage:[UIImage imageNamed:@"ic_event_device_03"]];
                break;
            case ZONE_FIRE:
                
                titleLabel.text = NSLocalizedString(self.detailInfo.event.zone_fire.title_loc_key, nil);
                deviceName.text = self.detailInfo.event.zone_fire.device.name;
                deviceID = self.detailInfo.event.zone_fire.device.id;
                
                args = self.detailInfo.event.zone_fire.loc_args;
                
                deviceDescription.text = [self getLocalizedDecription:@"notificationType.message.zoneFire" args:args];
                
                [alarmImage setImage:[UIImage imageNamed:@"ic_event_fire_alarm"]];
                break;
            case ZONE_APB:
                
                titleLabel.text = NSLocalizedString(self.detailInfo.event.zone_apb.title_loc_key, nil);
                deviceName.text = self.detailInfo.event.zone_apb.device.name;
                deviceID = self.detailInfo.event.zone_apb.device.id;
                
                args = self.detailInfo.event.zone_apb.loc_args;
                
                deviceDescription.text = [self getLocalizedDecription:@"notificationType.message.zoneApb" args:args];
                
                [alarmImage setImage:[UIImage imageNamed:@"ic_event_zone_03"]];
                break;
            default:
                break;
        }
    }
    
    deviceProvider = [[DeviceProvider alloc] init];
    
    if (nil == deviceID)
    {
        [logImageButton setHidden:YES];
        [logButton setHidden:YES];
        [logLabel setHidden:YES];
    }
    else
    {
        if ([PreferenceProvider isUpperVersion])
        {
            if ([AuthProvider hasReadPermission:DEVICE_PERMISSION])
            {
                [self getDevice:deviceID];
            }
            else
            {
                [logImageButton setHidden:YES];
                [logButton setHidden:YES];
                [logLabel setHidden:YES];
            }
        }
        else
        {
            [self getDevice:deviceID];
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
        
        NSString *content = [[NSString alloc] initWithFormat:NSLocalizedString(key, nil) arguments:data.mutableBytes];
        return content;
    }
    
    return dec;
}

- (void)getDevice:(NSString*)deviceID
{
    [self startLoading:self];
    
    [deviceProvider getDevice:deviceID deviceBlock:^(SearchResultDevice *device) {
        [self finishLoading];
        
    } onError:^(Response *error) {
        [self finishLoading];
        
        if ([error.status_code isEqualToString:@"DEVICE_NOT_FOUND"])
        {
            [logImageButton setHidden:YES];
            [logButton setHidden:YES];
            [logLabel setHidden:YES];
            
        }
        else
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
            imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
            [imagePopupCtrl setContent:error.message];
            imagePopupCtrl.type = MAIN_REQUEST_FAIL;
            [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
            
            [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
                if (isConfirm)
                {
                    [self getDevice:deviceID];
                }
            }];
        }
        
    }];
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

- (IBAction)moveToLog:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MonitoringViewController *mornitorViewController = [storyboard instantiateViewControllerWithIdentifier:@"MonitoringViewController"];
    mornitorViewController.requestType = EVENT_DOOR;
    
    SearchResultDevice *device = [[SearchResultDevice alloc] init];
    
    NSMutableArray <NSString*> *deviceIDs = [[NSMutableArray alloc] init];
    NSMutableArray <SearchResultDevice*> *devices = [[NSMutableArray alloc] init];
    
    
    switch (self.notiType)
    {
        case DEVICE_TAMPERING:
            device.id = self.detailInfo.event.device_tampering.device.id;
            device.name = self.detailInfo.event.device_tampering.device.name;
            [deviceIDs addObject:self.detailInfo.event.device_tampering.device.id];
            [devices addObject:device];
            
            break;
        case DEVICE_REBOOT:
            device.id = self.detailInfo.event.device_reboot.device.id;
            device.name = self.detailInfo.event.device_reboot.device.name;
            [deviceIDs addObject:self.detailInfo.event.device_reboot.device.id];
            [devices addObject:device];
            
            break;
        case DEVICE_RS485_DISCONNECT:
            device.id = self.detailInfo.event.device_rs485_disconnect.device.id;
            device.name = self.detailInfo.event.device_rs485_disconnect.device.name;
            [deviceIDs addObject:self.detailInfo.event.device_rs485_disconnect.device.id];
            [devices addObject:device];
            
            break;
        case ZONE_FIRE:
            device.id = self.detailInfo.event.zone_fire.device.id;
            device.name = self.detailInfo.event.zone_fire.device.name;
            [deviceIDs addObject:self.detailInfo.event.zone_fire.device.id];
            [devices addObject:device];
            
            break;
        case ZONE_APB:
            device.id = self.detailInfo.event.zone_apb.device.id;
            device.name = self.detailInfo.event.zone_apb.device.name;
            [deviceIDs addObject:self.detailInfo.event.zone_apb.device.id];
            [devices addObject:device];
            
            break;
        default:
            break;
    }
    
    
    [mornitorViewController setDeviceCondition:deviceIDs];
    [MonitorFilterViewController setFilterDevices:devices];
    
    [self pushChildViewController:mornitorViewController parentViewController:self contentView:self.view animated:YES];
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
    AlarmDoorDetailNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmDoorDetailNormalCell" forIndexPath:indexPath];
    
    NSDate *calculatedDate = [CommonUtil dateFromString:self.detailInfo.event_datetime  originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    
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



@end
