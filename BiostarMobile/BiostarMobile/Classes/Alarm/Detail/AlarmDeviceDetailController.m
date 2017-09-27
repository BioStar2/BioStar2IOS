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
                titleLabel.text = titleLabel.text = NSBaseLocalizedString(self.detailInfo.event.device_tampering.title_loc_key, nil);
                deviceName.text = self.detailInfo.event.device_tampering.device.name;
                deviceID = self.detailInfo.event.device_tampering.device.id;
                
                args = self.detailInfo.event.device_tampering.loc_args;
                deviceDescription.text = [self getLocalizedDecription:@"notificationType.message.deviceTampering" args:args];
                
                [alarmImage setImage:[UIImage imageNamed:@"ic_event_device_03"]];
            }
                break;
            case DEVICE_REBOOT:
                
                titleLabel.text = NSBaseLocalizedString(self.detailInfo.event.device_reboot.title_loc_key, nil);
                deviceName.text = self.detailInfo.event.device_reboot.device.name;
                deviceID = self.detailInfo.event.device_reboot.device.id;
                
                args = self.detailInfo.event.device_reboot.loc_args;
                
                deviceDescription.text = [self getLocalizedDecription:@"notificationType.message.deviceReboot" args:args];
                
                
                [alarmImage setImage:[UIImage imageNamed:@"ic_event_device_01"]];
                break;
            case DEVICE_RS485_DISCONNECT:
                
                titleLabel.text = NSBaseLocalizedString(self.detailInfo.event.device_rs485_disconnect.title_loc_key, nil);
                deviceName.text = self.detailInfo.event.device_rs485_disconnect.device.name;
                deviceID = self.detailInfo.event.device_rs485_disconnect.device.id;
                
                args = self.detailInfo.event.device_rs485_disconnect.loc_args;
                
                deviceDescription.text = [self getLocalizedDecription:@"notificationType.message.deviceRs485Disconnect" args:args];
                
                
                [alarmImage setImage:[UIImage imageNamed:@"ic_event_device_03"]];
                break;
            case ZONE_FIRE:
                
                titleLabel.text = NSBaseLocalizedString(self.detailInfo.event.zone_fire.title_loc_key, nil);
                deviceName.text = self.detailInfo.event.zone_fire.device.name;
                deviceID = self.detailInfo.event.zone_fire.device.id;
                
                args = self.detailInfo.event.zone_fire.loc_args;
                
                deviceDescription.text = [self getLocalizedDecription:@"notificationType.message.zoneFire" args:args];
                
                [alarmImage setImage:[UIImage imageNamed:@"ic_event_fire_alarm"]];
                break;
            case ZONE_APB:
                
                titleLabel.text = NSBaseLocalizedString(self.detailInfo.event.zone_apb.title_loc_key, nil);
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
