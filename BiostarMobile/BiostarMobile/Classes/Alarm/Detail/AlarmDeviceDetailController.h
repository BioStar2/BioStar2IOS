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

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "AlarmDoorDetailNormalCell.h"
#import "MonitoringViewController.h"


@interface AlarmDeviceDetailController : BaseViewController 
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *deviceName;
    __weak IBOutlet UILabel *deviceDescription;
    __weak IBOutlet UITableView *detailTableView;
    __weak IBOutlet UIImageView *alarmImage;
    
}

@property (strong, nonatomic) GetNotification *detailInfo;
@property (assign, nonatomic) NotificationType notiType;

- (IBAction)moveToBack:(id)sender;
- (NSString*)getLocalizedDecription:(NSString*)key args:(NSArray*)args;
@end
