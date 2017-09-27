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

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    titleLabel.text = NSBaseLocalizedString(@"preference", nil);
    [self setSharedViewController:self];
    provider = [[PreferenceProvider alloc] init];
    hasNewVersion = NO;
    
    self.BLEisOn = [LocalDataManager getUserMlbileCredentialStatus];
    self.BLEdistance = [LocalDataManager getBLEDistance];
    
    self.justTurnOnUsage = [LocalDataManager getJustTurnOnUsage];
    
    [self getPreferencd];
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

- (void)getPreferencd
{
    [self startLoading:self];
    
    [provider getPreferenceWithCompleteHandler:^(Setting *setting) {
        
        self.setting = setting;
        [self getAppVersions];
        
    } onError:^(Response *error) {
        [self finishLoading];
        
        // 재시도 할것인지에 대한 팝업 띄워주기
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        //imagePopupCtrl.delegate = self;
        imagePopupCtrl.type = REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self getPreferencd];
            }
            else
            {
                [self moveToBack:nil];
            }
        }];
    }];
    
    
    
}

- (void)getAppVersions
{
    [provider getAppVersionsWithCompleteHandler:^(AppVersionInfo *versionInfo) {
        [self finishLoading];
        
        // 단말 버전 서버 버전 비교
        NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString* deviceVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
        
        if ([versionInfo.latest_version compare:deviceVersion options:NSNumericSearch] == NSOrderedDescending)
        {
            // actualVersion is lower than the requiredVersion
            hasNewVersion = YES;
        }
        
        [settingTableView reloadData];
    } onError:^(Response *error) {
        
        [self finishLoading];
        // 재시도 할것인지에 대한 팝업 띄워주기
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        //imagePopupCtrl.delegate = self;
        imagePopupCtrl.type = REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self getAppVersions];
            }
        }];

    }];
    
}

- (IBAction)moveToBack:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SETTING_WILL_CLOSE object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NEED_TO_GET_MOBILE_CREDENTIAL object:nil];
    [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
}

- (IBAction)switchDidChangedValue:(UISwitch *)sender
{
    NotificationSetting* notiSetting = [self.setting.notifications objectAtIndex:sender.tag];
    notiSetting.subscribed = sender.isOn;    
}

- (IBAction)saveSettingData:(id)sender
{
    [self startLoading:self];
    
    __weak typeof(self) weakSelf = self;
    
    [provider setPreferenceProvider:self.setting CompleteHandler:^(Response *error) {
        
        [weakSelf finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        OneButtonPopupViewController *successPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonPopupViewController"];
        successPopupCtrl.type = SETTING;
        [weakSelf showPopup:successPopupCtrl parentViewController:weakSelf parentView:weakSelf.view];
        
        [successPopupCtrl getResponse:^(OneButtonPopupType type) {
            if (type == SETTING) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SETTING_DID_UPDATE object:nil];
                [weakSelf moveToBack:nil];
            }
        }];

        // 성공일때만 BLE 셋팅도 같이 저장하기
        [LocalDataManager setBLEDistance:weakSelf.BLEdistance];
        [LocalDataManager setUseMobileCredential:weakSelf.BLEisOn];
        [LocalDataManager setJustTurnOnUsage:weakSelf.justTurnOnUsage];
        
    } onError:^(Response *error) {
        // 재시도 할것인지에 대한 팝업 띄워주기
        
        [weakSelf finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        //imagePopupCtrl.delegate = self;
        imagePopupCtrl.type = REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [weakSelf showPopup:imagePopupCtrl parentViewController:weakSelf parentView:weakSelf.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [weakSelf saveSettingData:nil];
            }
        }];
    }];
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    if ([PreferenceProvider isSupportMobileCredentialAndFaceTemplate])
    {
        if (![AuthProvider hasReadPermission:MONITORING_PERMISSION])
        {
            return 4;
        }
        else
        {
            return 5;
        }
    }
    else
    {
        if (![AuthProvider hasReadPermission:MONITORING_PERMISSION])
        {
            return 3;
        }
        else
        {
            return 4;
        }
    }
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger rowCount = 0;
    if ([PreferenceProvider isSupportMobileCredentialAndFaceTemplate])
    {
        switch (section)
        {
            case 0:
                rowCount = 1;
                break;
                
            case 1:
                rowCount = 1;
                break;
                
            case 2:
                rowCount = 2;
                break;
                
            case 3:
                // BLE setting
                if (self.BLEisOn)
                {
                    rowCount = 2;
                }
                else
                {
                    rowCount = 1;
                }
                
                break;
            
            case 4:
                rowCount = self.setting.notifications.count;
                break;
                
                
            default:
                break;
        }
    }
    else
    {
        switch (section)
        {
            case 0:
                rowCount = 1;
                break;
                
            case 1:
                rowCount = 1;
                break;
                
            case 2:
                rowCount = 2;
                break;
                
            case 3:
                rowCount = self.setting.notifications.count;
                break;
                
                
            default:
                break;
        }
    }
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section)
    {
        case 0:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VersionCell" forIndexPath:indexPath];
            VersionCell *customCell = (VersionCell*)cell;
            
            NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
            NSString* version = [infoDict objectForKey:@"CFBundleShortVersionString"];
            
            NSString* buildversion = [infoDict objectForKey:@"CFBundleVersion"];
            
            NSString *totalVersion = [NSString stringWithFormat:@"%@.%@",version ,buildversion];
            
            customCell.titleLabel.text = totalVersion;
            
            if (hasNewVersion)
            {
                [customCell.badge setHidden:NO];
                [customCell.accImage setHidden:NO];
            }
            else
            {
                [customCell.badge setHidden:YES];
                [customCell.accImage setHidden:YES];
            }
            return customCell;
            break;
        }
            
        case 1:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimezoneCell" forIndexPath:indexPath];
            TimezoneCell *customCell = (TimezoneCell*)cell;
            NSLocale *locale = [NSLocale currentLocale];
            NSTimeZone *zone = [NSTimeZone localTimeZone];
            customCell.titleLabel.text = [zone localizedName:NSTimeZoneNameStyleStandard locale:locale];
            return customCell;
            break;
        }
            
        case 2:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DateTimeCell" forIndexPath:indexPath];
            DateTimeCell *customCell = (DateTimeCell*)cell;
            if (indexPath.row == 0)
            {
                customCell.titleLabel.text = NSBaseLocalizedString(@"date", nil);
                customCell.valueLabel.text = [self.setting.date_format lowercaseString];
            }
            else
            {
                customCell.titleLabel.text = NSBaseLocalizedString(@"time", nil);
                customCell.valueLabel.text = [self.setting.time_format lowercaseString];
            }
            return customCell;
            break;
        }
            
        case 3:
        {
            // BLE setting cell
            if ([PreferenceProvider isSupportMobileCredentialAndFaceTemplate])
            {
                if (indexPath.row == 0)
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BLESettingCell" forIndexPath:indexPath];
                    BLESettingCell *customCell = (BLESettingCell*)cell;
                    customCell.delegate = self;
                    [customCell setBLEUsage:self.BLEisOn];
                    
                    return customCell;
                }
                else if(indexPath.row == 1)
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BLEDistanceCell" forIndexPath:indexPath];
                    BLEDistanceCell *customCell = (BLEDistanceCell*)cell;
                    customCell.delegate = self;
                    [customCell setDistanceLevel:10 withDiscance:self.BLEdistance];
                    
                    return customCell;
                }
                else
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BLESwtichCell" forIndexPath:indexPath];
                    BLESwtichCell *customCell = (BLESwtichCell*)cell;
                    customCell.delegate = self;
                    [customCell setBLESwitchCellContent:@"Just Turn On" usage:self.justTurnOnUsage];
                    
                    return customCell;
                }
                
            }
            else
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
                SwitchCell *customCell = (SwitchCell*)cell;
                
                [customCell setSwitchCellContent:self.setting.notifications[indexPath.row] index:indexPath.row];
                
                return customCell;
            }
            
            break;
        }
        case 4:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
            SwitchCell *customCell = (SwitchCell*)cell;
            
            [customCell setSwitchCellContent:self.setting.notifications[indexPath.row] index:indexPath.row];
            
            return customCell;
            break;
        }
        default:
        {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            
            return cell;
            break;
        }
    }
}


#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 41;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SectionCell"];
    SectionCell *customCell = (SectionCell*)cell;
    
    switch (section)
    {
        case 0:
            customCell.sectionTitle.text = NSBaseLocalizedString(@"version_mobile", nil);
            break;
            
        case 1:
            customCell.sectionTitle.text = NSBaseLocalizedString(@"timezone", nil);
            break;
            
        case 2:
            customCell.sectionTitle.text = [NSString stringWithFormat:@"%@/%@ %@",NSBaseLocalizedString(@"date", nil) ,NSBaseLocalizedString(@"time", nil) ,NSBaseLocalizedString(@"format", nil)];
            break;
            
        case 3:
            if ([PreferenceProvider isSupportMobileCredentialAndFaceTemplate])
            {
                customCell.sectionTitle.text = NSBaseLocalizedString(@"mobile_card", nil);
            }
            else
            {
                customCell.sectionTitle.text = NSBaseLocalizedString(@"notification", nil);
            }
            
            break;
            
        case 4:
            customCell.sectionTitle.text = NSBaseLocalizedString(@"notification", nil);
            break;
            
        default:
            break;
    }
    
    return customCell.contentView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
            // 앱 업데이트
        {
            if (hasNewVersion)
            {
                // 앱스토어 링크
                NSString *appName = [NSString stringWithString:[[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]];
                NSURL *appStoreURL = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.com/app/%@",[appName stringByReplacingOccurrencesOfString:@" " withString:@""]]];
                [[UIApplication sharedApplication] openURL:appStoreURL options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @NO} completionHandler:^(BOOL success) {
                    
                }];
            }
        }
            break;
        case 2:
            if (indexPath.row == 0)
            {
                // 날짜
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
                DateTimeFormatPopupViewController *dateTimeFormatPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"DateTimeFormatPopupViewController"];
                dateTimeFormatPopupCtrl.type = DATE_FORMAT;
                [self showPopup:dateTimeFormatPopupCtrl parentViewController:self parentView:self.view];
                [dateTimeFormatPopupCtrl setDateFormats:[PreferenceProvider getDataFormatList]];
                
                [dateTimeFormatPopupCtrl getDateFormatResponse:^(DateFormat *dateformat) {
                    self.setting.date_format = dateformat.date_format;
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
                    [settingTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                }];
            }
            else
            {
                // 시간
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
                DateTimeFormatPopupViewController *dateTimeFormatPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"DateTimeFormatPopupViewController"];
                dateTimeFormatPopupCtrl.type = TIME_FORMAT;
                [self showPopup:dateTimeFormatPopupCtrl parentViewController:self parentView:self.view];
                [dateTimeFormatPopupCtrl setTimeFormats:[PreferenceProvider getTimeFormatList]];
                
                
                [dateTimeFormatPopupCtrl getTimeFormatResponse:^(TimeFormat *timeformat) {
                    self.setting.time_format = timeformat.time_format;
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:2];
                    [settingTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                }];
            }
            break;
        default:
            break;
    }

}


#pragma mark - BLESwitchCellDelegate

- (void)useStatusHasChanged:(UITableViewCell*)cell
{
    BLESwtichCell *customCell = (BLESwtichCell*)cell;
    self.justTurnOnUsage = customCell.settingSwitch.isOn;
    
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:3];
    
    [settingTableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - BLESettingCellDelegate

- (void)distanceHasChanged:(NSUInteger)distance
{
    self.BLEdistance = distance;
}

- (void)BLEuseStatusHasChanged:(BOOL)isOn
{
    self.BLEisOn = isOn;
    
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:3];
    
    [settingTableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
}


@end
