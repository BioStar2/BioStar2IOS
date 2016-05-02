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
    rowCount = 0;
    // Do any additional setup after loading the view.
    if (self.detailInfo)
    {
        switch (self.alarmType)
        {
            case DEVICE_TAMPERING:
                [self setAlarmInfo:@"device_tampering"];
                [alarmImage setImage:[UIImage imageNamed:@"ic_event_device_03"]];
                break;
            case DEVICE_REBOOT:
                [self setAlarmInfo:@"device_reboot"];
                [alarmImage setImage:[UIImage imageNamed:@"ic_event_device_01"]];
                break;
            case DEVICE_RS485_DISCONNECT:
                [self setAlarmInfo:@"device_rs485_disconnect"];
                [alarmImage setImage:[UIImage imageNamed:@"ic_event_device_03"]];
                break;
            case ZONE_FIRE:
                [self setAlarmInfo:@"zone_fire"];
                [alarmImage setImage:[UIImage imageNamed:@"ic_event_fire_alarm"]];
                break;
            case ZONE_APB:
                [self setAlarmInfo:@"zone_apb"];
                [alarmImage setImage:[UIImage imageNamed:@"ic_event_zone_02"]];
                break;
            default:
                break;
        }
        
        [self startLoading:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setAlarmInfo:(NSString*)alarmname
{
    eventKey = alarmname;
    titleLabel.text = [[[self.detailInfo objectForKey:@"event"] objectForKey:alarmname] objectForKey:@"title"];
    deviceName.text = [[[[self.detailInfo objectForKey:@"event"] objectForKey:alarmname] objectForKey:@"device"] objectForKey:@"name"];
    deviceDescription.text = [[[self.detailInfo objectForKey:@"event"] objectForKey:alarmname] objectForKey:@"message"];
    rowCount = 1;
    
    deviceProvider = [[DeviceProvider alloc] init];
    deviceProvider.delegate = self;
    NSString *deviceID = [[[[self.detailInfo objectForKey:@"event"] objectForKey:alarmname] objectForKey:@"device"] objectForKey:@"id"];
    [deviceProvider getDevice:deviceID];
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
    
    
    NSMutableArray *deviceIDs = [[NSMutableArray alloc] init];
    NSMutableArray *devices = [[NSMutableArray alloc] init];
    
    [deviceIDs addObject:[[[[self.detailInfo objectForKey:@"event"] objectForKey:eventKey] objectForKey:@"device"] objectForKey:@"id"]];
    [devices addObject:[[[self.detailInfo objectForKey:@"event"] objectForKey:eventKey] objectForKey:@"device"]];
    
    
    NSDictionary *deviceCondition = @{@"device_id" : deviceIDs};
    [mornitorViewController setDeviceCondition:deviceCondition];
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
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlarmDoorDetailNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmDoorDetailNormalCell" forIndexPath:indexPath];
    
    NSDate *calculatedDate = [CommonUtil dateFromString:[self.detailInfo objectForKey:@"event_datetime"]  originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    
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


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - DeviceProviderDelegate

- (void)requestGetDeviceDidFinish:(NSDictionary*)dic
{
    [self finishLoading];
}


- (void)requestDeviceProviderDidFail:(NSDictionary*)errDic
{
    [self finishLoading];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
    [imagePopupCtrl setContent:[errDic objectForKey:@"message"]];
    imagePopupCtrl.delegate = self;
    imagePopupCtrl.type = MAIN_REQUEST_FAIL;
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
}

#pragma mark = ImagePopupDelegate

- (void)confirmImagePopup
{
    [deviceProvider getDevices:[[[[self.detailInfo objectForKey:@"event"] objectForKey:@"device_tampering"] objectForKey:@"device"] objectForKey:@"id"] limit:10000 offset:0];
    
    [self startLoading:self];
}

- (void)cancelImagePopup
{
    //[self moveToBack:nil];
    [logImageButton setHidden:YES];
    [logButton setHidden:YES];
    [logLabel setHidden:YES];
}
@end
