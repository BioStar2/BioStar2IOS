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
    
    _preferenceDic = [[NSMutableDictionary alloc] init];
    _notifications = [[NSMutableArray alloc] init];
    
    provider = [[PreferenceProvider alloc] init];
    provider.delegate = self;
    [provider getPreferenceProvider];
    
    [self startLoading:self];
    hasNewVersion = NO;
    
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

- (IBAction)switchDidChangedValue:(UISwitch *)sender
{
    NSMutableDictionary *notification = [[NSMutableDictionary alloc] initWithDictionary:[_notifications objectAtIndex:sender.tag]];
    [notification setObject:[NSNumber numberWithBool:sender.isOn] forKey:@"subscribed"];
    
    [_notifications replaceObjectAtIndex:sender.tag withObject:notification];
    
}

- (IBAction)saveSettingData:(id)sender
{
    [_preferenceDic setObject:_notifications forKey:@"notifications"];
    [provider setPreferenceProvider:_preferenceDic];
    [self startLoading:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (![AuthProvider hasWritePermission:@"DOOR"])
    {
        return 3;
    }
    else
    {
        return 4;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger rowCount = 0;
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
            rowCount = _notifications.count;
            break;
            
            
        default:
            break;
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
            customCell.titleLabel.text = [NSString stringWithFormat:@"V.%@", version];
            
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
                customCell.titleLabel.text = NSLocalizedString(@"date", nil);
                customCell.valueLabel.text = [[_preferenceDic objectForKey:@"date_format"] lowercaseString];
            }
            else
            {
                customCell.titleLabel.text = NSLocalizedString(@"time", nil);
                customCell.valueLabel.text = [[_preferenceDic objectForKey:@"time_format"] lowercaseString];
            }
            return customCell;
            break;
        }
            
        case 3:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
            SwitchCell *customCell = (SwitchCell*)cell;
            
            [customCell setSwitchCellContent:_notifications index:indexPath.row];
            
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
            customCell.sectionTitle.text = NSLocalizedString(@"version_mobile", nil);
            break;
            
        case 1:
            customCell.sectionTitle.text = NSLocalizedString(@"timezone", nil);
            break;
            
        case 2:
            customCell.sectionTitle.text = NSLocalizedString(@"date_time_format", nil);
            break;
            
        case 3:
            customCell.sectionTitle.text = NSLocalizedString(@"notification", nil);
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
                [[UIApplication sharedApplication] openURL:appStoreURL];
            }
        }
            break;
        case 2:
            if (indexPath.row == 0)
            {
                // 날짜
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
                ListSubInfoPopupViewController *listSubInfoPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListSubInfoPopupViewController"];
                listSubInfoPopupCtrl.delegate = self;
                listSubInfoPopupCtrl.type = DATE_FORMAT;
                [self showPopup:listSubInfoPopupCtrl parentViewController:self parentView:self.view];
                [listSubInfoPopupCtrl setContentList:[PreferenceProvider getDataFormatList]];
            }
            else
            {
                // 시간
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
                ListSubInfoPopupViewController *listSubInfoPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListSubInfoPopupViewController"];
                listSubInfoPopupCtrl.delegate = self;
                listSubInfoPopupCtrl.type = TIME_FORMAT;
                [self showPopup:listSubInfoPopupCtrl parentViewController:self parentView:self.view];
                [listSubInfoPopupCtrl setContentList:[PreferenceProvider getTimeFormatList]];
            }
            break;
        default:
            break;
    }

}

#pragma mark - PreferenceProviderDelegate

- (void)requestGetPreferenceDidFinish:(NSDictionary*)preferenceDic
{
    [_preferenceDic setDictionary:preferenceDic];
    [_notifications addObjectsFromArray:[preferenceDic objectForKey:@"notifications"]];
    
    
    [provider getAppVersions];
}

- (void)requestSetPreferenceDidFinish:(NSDictionary*)resultdic
{
    [self finishLoading];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    OneButtonPopupViewController *successPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonPopupViewController"];
    successPopupCtrl.delegate = self;
    successPopupCtrl.type = SETTING;
    [self showPopup:successPopupCtrl parentViewController:self parentView:self.view];
}

- (void)requestAppVersionDidFinish:(NSDictionary*)resultdic
{
    [self finishLoading];
    
    // 단말 버전 서버 버전 비교
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* deviceVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSString* serverVersion = [resultdic objectForKey:@"latest_version"];
    
    if ([serverVersion compare:deviceVersion options:NSNumericSearch] == NSOrderedDescending)
    {
        // actualVersion is lower than the requiredVersion
        hasNewVersion = YES;
    }
    
    [settingTableView reloadData];
}

- (void)requestPreferenceProviderDidFail:(NSDictionary*)errDic
{
    [self finishLoading];
    
    // 재시도 할것인지에 대한 팝업 띄워주기
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.delegate = self;
    imagePopupCtrl.type = REQUEST_FAIL;
    imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
    [imagePopupCtrl setContent:[errDic objectForKey:@"message"]];
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
}

#pragma mark - ListSubInfoPopupDelegate

- (void)confirmTimezone:(NSInteger)index
{
    if (index != NOT_SELECTED)
    {
        [_preferenceDic setObject:[NSNumber numberWithInteger:index] forKey:@"time_zone"];
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    [settingTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)confirmTimeFormat:(NSDictionary*)dic
{
    [_preferenceDic setObject:[dic objectForKey:@"name"] forKey:@"time_format"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:2];
    [settingTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)confirmDateFormat:(NSDictionary*)dic
{
    [_preferenceDic setObject:[dic objectForKey:@"name"] forKey:@"date_format"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    [settingTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - OneButtonPopupDelegate

- (void)didComplete
{
    [self moveToBack:nil];
}

#pragma mark - ImagePopupDelegate

- (void)confirmImagePopup
{
    [self saveSettingData:nil];
}
@end