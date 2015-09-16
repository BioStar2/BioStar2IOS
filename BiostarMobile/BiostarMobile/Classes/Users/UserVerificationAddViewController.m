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

#import "UserVerificationAddViewController.h"

@interface UserVerificationAddViewController ()

@end

@implementation UserVerificationAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    infoDic = [[NSMutableDictionary alloc] init];
    fingerPrintDic = [[NSMutableDictionary alloc] init];
    fingerPrintScanCount = 0;
    // Do any additional setup after loading the view.
    toDeleteArray = [[NSMutableArray alloc] init];
    isSelectedAll = NO;
    isForSwitchIndex = NO;
    isForAPIRetry = NO;
    
    switch (_type)
    {
        case FINGERPRINT:
            titleLabel.text = NSLocalizedString(@"fingerprint", nil);
            break;
        case CARD:
            titleLabel.text = NSLocalizedString(@"card", nil);
            break;
        case ACCESS_GROUPS:
            titleLabel.text = NSLocalizedString(@"access_group", nil);
            break;
        case OPERATOR:
            titleLabel.text = NSLocalizedString(@"permission_setting", nil);
            break;
        
    }
    
    if (_isProfileMode)
    {
        [editButtonView setHidden:YES];
        [doneButtonView setHidden:YES];
    }
    
    totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)verificationInfos.count];
    
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

- (void)setOperators:(NSArray*)operators
{
    NSMutableArray *tempOperators = [[NSMutableArray alloc] init];
    for (NSDictionary *operator in operators)
    {
        NSMutableDictionary *tempVerification = [[NSMutableDictionary alloc] initWithDictionary:operator];
        [tempVerification setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        [tempOperators addObject:tempVerification];
    }
    
    if (verificationInfos)
    {
        [verificationInfos removeAllObjects];
        [verificationInfos addObjectsFromArray:tempOperators];
    }
    else
    {
        verificationInfos = [[NSMutableArray alloc] initWithArray:tempOperators];
    }
    
    
    [contentTableView reloadData];
}

- (void)setAccessGroup:(NSArray*)accessGroup withUserGroup:(NSArray*)userGroup
{
    NSMutableArray *tempInfos = [[NSMutableArray alloc] init];
    
    
    for (NSDictionary *info in userGroup)
    {
        NSMutableDictionary *tempVerification = [[NSMutableDictionary alloc] initWithDictionary:info];
        [tempVerification setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        [tempVerification setObject:@"access_groups_in_user_group" forKey:@"type"];
        [tempInfos addObject:tempVerification];
    }
    
    for (NSDictionary *info in accessGroup)
    {
        NSMutableDictionary *tempVerification = [[NSMutableDictionary alloc] initWithDictionary:info];
        [tempVerification setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        [tempVerification setObject:@"access_groups" forKey:@"type"];
        [tempInfos addObject:tempVerification];
    }
    
    if (verificationInfos)
    {
        [verificationInfos removeAllObjects];
        verificationInfos = nil;
    }
    verificationInfos = [[NSMutableArray alloc] initWithArray:tempInfos];
    
    [contentTableView reloadData];
}

- (void)setVerificationInfo:(NSArray*)infos
{
    
    NSMutableArray *tempInfos = [[NSMutableArray alloc] init];
    
    NSInteger index = 0;
    maxFingerprintIndex = 0;
    for (NSDictionary *info in infos)
    {
        NSMutableDictionary *tempVerification = [[NSMutableDictionary alloc] initWithDictionary:info];
        [tempVerification setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        [tempInfos addObject:tempVerification];
        NSInteger tempFingerprintIndex = [[info objectForKey:@"finger_index"] integerValue];
        if (maxFingerprintIndex < tempFingerprintIndex)
        {
            maxFingerprintIndex = tempFingerprintIndex;
        }
        index++;
    }
    if (verificationInfos)
    {
        [verificationInfos removeAllObjects];
        verificationInfos = nil;
    }
    verificationInfos = [[NSMutableArray alloc] initWithArray:tempInfos];
    
    [contentTableView reloadData];
    
}

- (IBAction)addVerification:(id)sender
{
    switch (_type)
    {
        case FINGERPRINT:
        {
            if (nil == verificationInfos || [verificationInfos count] == 0)
            {
                scanIndex = 0;
            }
            else
            {
                scanIndex = verificationInfos.count;
            }
            
            if ([verificationInfos count] == 10)
            {
                // 10 개 초과 등록 안됨
                [self.view makeToast:NSLocalizedString(@"max_size", nil)
                            duration:2.0
                            position:CSToastPositionBottom
                               image:[UIImage imageNamed:@"toast_popup_i_03"]];
                
                return;
            }
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ListSubInfoPopupViewController *listSubInfoPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListSubInfoPopupViewController"];
            listSubInfoPopupCtrl.delegate = self;
            listSubInfoPopupCtrl.type = DEVICE_FINGERPRINT;
            [self showPopup:listSubInfoPopupCtrl parentViewController:self parentView:self.view];
            break;
        }
        case CARD:
        {
            if ([verificationInfos count] == 8)
            {
                // 8 개 초과 등록 안됨
                [self.view makeToast:NSLocalizedString(@"max_size", nil)
                            duration:2.0
                            position:CSToastPositionBottom
                               image:[UIImage imageNamed:@"toast_popup_i_03"]];
                return;
            }
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ListPopupViewController *listPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListPopupViewController"];
            listPopupCtrl.delegate = self;
            listPopupCtrl.isRadioStyle = YES;
            listPopupCtrl.type = CARD_OPTION;
            
            [self showPopup:listPopupCtrl parentViewController:self parentView:self.view];
            [listPopupCtrl addOptions:@[NSLocalizedString(@"registeration_option_card_reader", nil) ,NSLocalizedString(@"registeration_option_assign_card", nil)]];
            break;
        }
        case ACCESS_GROUPS:
        {
            if ([verificationInfos count] == 16)
            {
                // 8 개 초과 등록 안됨
                [self.view makeToast:NSLocalizedString(@"max_size", nil)
                            duration:2.0
                            position:CSToastPositionBottom
                               image:[UIImage imageNamed:@"toast_popup_i_03"]];
                return;
            }
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ListSubInfoPopupViewController *listSubInfoPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListSubInfoPopupViewController"];
            listSubInfoPopupCtrl.delegate = self;
            listSubInfoPopupCtrl.type = ADD_ACCESS_GROUP;
            [self showPopup:listSubInfoPopupCtrl parentViewController:self parentView:self.view];
            break;
        }
        case OPERATOR:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ListPopupViewController *listPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListPopupViewController"];
            listPopupCtrl.delegate = self;
            listPopupCtrl.isRadioStyle = YES;
            listPopupCtrl.type = PERMISSON;
            
            [self showPopup:listPopupCtrl parentViewController:self parentView:self.view];
        }
            break;
    }
}

- (IBAction)moveToBack:(id)sender
{
    if (totalCountView.hidden)
    {
        [toDeleteArray removeAllObjects];
        for (NSMutableDictionary *info in verificationInfos)
        {
            [info setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            
        }
        [selectAllButton setImage:[UIImage imageNamed:@"check_box_blank"] forState:UIControlStateNormal];
        totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)verificationInfos.count];
        [contentTableView reloadData];
        isSelectedAll = NO;
        
    
        [editButtonView setHidden:NO];
        [doneButtonView setHidden:YES];
        [totalCountView setHidden:NO];
        [verificationSelectView setHidden:YES];
        totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)verificationInfos.count];
        return;
    }
    [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
}

- (IBAction)deleteVerification:(id)sender
{
    totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)verificationInfos.count];
    [editButtonView setHidden:YES];
    [doneButtonView setHidden:NO];
    [totalCountView setHidden:YES];
    [verificationSelectView setHidden:NO];
    [contentTableView reloadData];
}

- (IBAction)done:(id)sender
{
    if (toDeleteArray.count > 0)
    {
        isForAPIRetry = NO;
        // delete popup display
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.delegate = self;
        imagePopupCtrl.type = WARNING;
        imagePopupCtrl.titleContent = NSLocalizedString(@"delete_confirm_question", nil);
        [imagePopupCtrl setContent:[NSString stringWithFormat:NSLocalizedString(@"selected_count %ld", nil), (unsigned long)toDeleteArray.count]];
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

- (IBAction)selectAll:(UIButton *)sender
{
    [toDeleteArray removeAllObjects];
    
    if (!isSelectedAll)
    {
        if (_type == ACCESS_GROUPS)
        {
            for (NSMutableDictionary *info in verificationInfos)
            {
                if (nil != [info objectForKey:@"included_by_user_group"])
                {
                    if(![[info objectForKey:@"included_by_user_group"] isEqualToString:@"YES"])
                    {
                        [info setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
                        [toDeleteArray addObject:info];
                    }
                }
                else
                {
                    [info setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
                    [toDeleteArray addObject:info];
                }
                
            }
        }
        else
        {
            for (NSMutableDictionary *info in verificationInfos)
            {
                [info setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
                [toDeleteArray addObject:info];
            }
        }
        
        [sender setImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
        totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)verificationInfos.count];
    }
    else
    {
        for (NSMutableDictionary *info in verificationInfos)
        {
            [info setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            
        }
        [sender setImage:[UIImage imageNamed:@"check_box_blank"] forState:UIControlStateNormal];
        totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)verificationInfos.count];
    }
    
    [contentTableView reloadData];
    isSelectedAll = !isSelectedAll;
    
}

- (void)showScanPopup:(VerificationType)type
{
    switch (_type)
    {
        case FINGERPRINT:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ScanPopupViewController *scanPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ScanPopupViewController"];
            scanPopupCtrl.scanType = FINGERPRINT_SCAN;
            scanPopupCtrl.scanCount = fingerPrintScanCount;
            [scanPopupCtrl setFingerPrintDic:fingerPrintDic];
            [scanPopupCtrl setScanIndex:scanIndex];
            [scanPopupCtrl setTemplateIndex:maxFingerprintIndex + 1];
            [scanPopupCtrl setDeviceID:[infoDic objectForKey:@"id"]];
            [self showPopup:scanPopupCtrl parentViewController:self parentView:self.view];
            scanPopupCtrl.delegate = self;
        }
            break;
            
        case CARD:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ScanPopupViewController *scanPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ScanPopupViewController"];
            scanPopupCtrl.scanType = CARD_SCAN;
            [scanPopupCtrl setDeviceID:[infoDic objectForKey:@"id"]];
            [self showPopup:scanPopupCtrl parentViewController:self parentView:self.view];
            scanPopupCtrl.delegate = self;
        }
            break;
        default:
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
    return [verificationInfos count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VerificationCell" forIndexPath:indexPath];
    VerificationCell *customCell = (VerificationCell*)cell;
    NSDictionary *dic = [verificationInfos objectAtIndex:indexPath.row];
    switch (_type)
    {
        case CARD:
            customCell.titleLabel.text = [NSString stringWithFormat:@"%ld", (long)[[dic objectForKey:@"card_id"] integerValue]];
            if (totalCountView.hidden)
            {
                [customCell.accImage setHidden:YES];
            }
            else
            {
                [customCell.accImage setHidden:NO];
            }
            [customCell setCardAndFingerprintCell:dic];
            break;
        case FINGERPRINT:
        {
            NSInteger value = indexPath.row + 1;
            NSString *description;
            
            if (value == 1)
                description = [NSString stringWithFormat:NSLocalizedString(@"1st_fingerprint", nil), (long)value];
            else if (value == 2)
                description = [NSString stringWithFormat:NSLocalizedString(@"2nd_fingerprint", nil), (long)value];
            else if (value == 3)
                description = [NSString stringWithFormat:NSLocalizedString(@"3rd_fingerprint", nil), (long)value];
            else
                description = [NSString stringWithFormat:NSLocalizedString(@"%ldth_fingerprint", nil), (long)value];
            
            customCell.titleLabel.text = description;
            if (totalCountView.hidden)
            {
                [customCell.accImage setHidden:YES];
            }
            else
            {
                [customCell.accImage setHidden:NO];
            }
            [customCell setCardAndFingerprintCell:dic];
            break;
        }
            
        case ACCESS_GROUPS:

            [customCell setCellDictionary:dic];
            
            break;
        case OPERATOR:
        {
            [customCell setCellDictionary:dic];
            customCell.titleLabel.text = [dic objectForKey:@"description"];
        }
            break;
        
    }
    
    
    
    return customCell;
    
}


#pragma mark - Table View Delegate



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isProfileMode)
    {
        return;
    }
    
    switch (_type)
    {
        case FINGERPRINT:
            if (totalCountView.hidden)
            {
                // 지문 삭제 모드
                NSMutableDictionary *verification = [verificationInfos objectAtIndex:indexPath.row];
                
                if ([[verification objectForKey:@"selected"] boolValue])
                {
                    [verification setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
                    [toDeleteArray removeObject:verification];
                }
                else
                {
                    [verification setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
                    [toDeleteArray addObject:verification];
                }
                
                if (verificationInfos.count == toDeleteArray.count)
                {
                    isSelectedAll = YES;
                    [selectAllButton setImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
                }
                else
                {
                    isSelectedAll = NO;
                    [selectAllButton setImage:[UIImage imageNamed:@"check_box_blank"] forState:UIControlStateNormal];
                }
                
                totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)verificationInfos.count];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else
            {
                // 지문 교체 모드
                isForSwitchIndex = YES;
                toBeSwitchedIndex = indexPath.row;
                scanIndex = indexPath.row;
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
                ListSubInfoPopupViewController *listSubInfoPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListSubInfoPopupViewController"];
                listSubInfoPopupCtrl.delegate = self;
                listSubInfoPopupCtrl.type = DEVICE_FINGERPRINT;
                [self showPopup:listSubInfoPopupCtrl parentViewController:self parentView:self.view];
            }
            break;
        
        case CARD:
            if (totalCountView.hidden)
            {
                // 카드 삭제 모드
                NSMutableDictionary *verification = [verificationInfos objectAtIndex:indexPath.row];
                
                if ([[verification objectForKey:@"selected"] boolValue])
                {
                    [verification setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
                    [toDeleteArray removeObject:verification];
                }
                else
                {
                    [verification setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
                    [toDeleteArray addObject:verification];
                }
                
                if (verificationInfos.count == toDeleteArray.count)
                {
                    isSelectedAll = YES;
                    [selectAllButton setImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
                }
                else
                {
                    isSelectedAll = NO;
                    [selectAllButton setImage:[UIImage imageNamed:@"check_box_blank"] forState:UIControlStateNormal];
                }
                
                totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)verificationInfos.count];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else
            {
                // 카드 교체
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
                ListSubInfoPopupViewController *listSubInfoPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListSubInfoPopupViewController"];
                listSubInfoPopupCtrl.delegate = self;
                listSubInfoPopupCtrl.type = EXCHANGE_CARD;
                [self showPopup:listSubInfoPopupCtrl parentViewController:self parentView:self.view];
                toBeSwitchedIndex = indexPath.row;
            }
            break;
        case ACCESS_GROUPS:
            if (totalCountView.hidden)
            {
                NSMutableDictionary *verification = [verificationInfos objectAtIndex:indexPath.row];
                // Access 삭제 모드
                if (nil != [verification objectForKey:@"included_by_user_group"])
                {
                    if([[verification objectForKey:@"included_by_user_group"] isEqualToString:@"YES"])
                    {
                        // 편집 불가한 항목 상속받은 유저 그룹
                        [self.view makeToast:NSLocalizedString(@"inherited_not_change", nil)
                                    duration:2.0 position:CSToastPositionBottom
                                       title:NSLocalizedString(@"inherited", nil)
                                       image:[UIImage imageNamed:@"toast_popup_i_05"]];
                        return;
                    }
                }
                
                
                if ([[verification objectForKey:@"selected"] boolValue])
                {
                    [verification setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
                    [toDeleteArray removeObject:verification];
                }
                else
                {
                    [verification setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
                    [toDeleteArray addObject:verification];
                }
                
                if (verificationInfos.count == toDeleteArray.count)
                {
                    isSelectedAll = YES;
                    [selectAllButton setImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
                }
                else
                {
                    isSelectedAll = NO;
                    [selectAllButton setImage:[UIImage imageNamed:@"check_box_blank"] forState:UIControlStateNormal];
                }
                
                totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)verificationInfos.count];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else
            {
                NSDictionary *verification = [verificationInfos objectAtIndex:indexPath.row];
                if (nil != [verification objectForKey:@"included_by_user_group"])
                {
                    if([[verification objectForKey:@"included_by_user_group"] isEqualToString:@"YES"])
                    {
                        [self.view makeToast:NSLocalizedString(@"inherited_not_change", nil)
                                    duration:2.0 position:CSToastPositionBottom
                                       title:NSLocalizedString(@"inherited", nil)
                                       image:[UIImage imageNamed:@"toast_popup_i_05"]];
                    }
                    else
                    {
                        // Access 교체
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
                        ListSubInfoPopupViewController *listSubInfoPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListSubInfoPopupViewController"];
                        listSubInfoPopupCtrl.delegate = self;
                        listSubInfoPopupCtrl.type = EXCHANGE_ACCESS_GROUP;
                        [self showPopup:listSubInfoPopupCtrl parentViewController:self parentView:self.view];
                        toBeSwitchedIndex = indexPath.row;
                    }
                }
                else
                {
                    // Access 교체
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
                    ListSubInfoPopupViewController *listSubInfoPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListSubInfoPopupViewController"];
                    listSubInfoPopupCtrl.delegate = self;
                    listSubInfoPopupCtrl.type = EXCHANGE_ACCESS_GROUP;
                    [self showPopup:listSubInfoPopupCtrl parentViewController:self parentView:self.view];
                    toBeSwitchedIndex = indexPath.row;
                }
                
            }
            break;
        case OPERATOR: 
        {
            if (totalCountView.hidden)
            {
                // 삭제 모드
                NSMutableDictionary *verification = [verificationInfos objectAtIndex:indexPath.row];
                
                if ([[verification objectForKey:@"selected"] boolValue])
                {
                    [verification setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
                    [toDeleteArray removeObject:verification];
                }
                else
                {
                    [verification setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
                    [toDeleteArray addObject:verification];
                }
                
                if (verificationInfos.count == toDeleteArray.count)
                {
                    isSelectedAll = YES;
                    [selectAllButton setImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
                }
                else
                {
                    isSelectedAll = NO;
                    [selectAllButton setImage:[UIImage imageNamed:@"check_box_blank"] forState:UIControlStateNormal];
                }
                
                totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)verificationInfos.count];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else
            {
                isForSwitchIndex = YES;
                toBeSwitchedIndex = indexPath.row;
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
                ListPopupViewController *listPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListPopupViewController"];
                listPopupCtrl.delegate = self;
                listPopupCtrl.isRadioStyle = YES;
                listPopupCtrl.type = PERMISSON;
                
                [self showPopup:listPopupCtrl parentViewController:self parentView:self.view];
            }
        }
            break;
    }
    
}

#pragma mark - ListPopupViewControllerDelegate

- (void)didSelectContent:(NSDictionary*)dic
{
    BOOL isFoundSameItem = NO;
    for (NSDictionary *operator in verificationInfos)
    {
        NSString *code = [operator objectForKey:@"code"];
        if ([code isEqualToString:[dic objectForKey:@"code"]])
        {
            isFoundSameItem = YES;
            break;
        }
    }
    
    if (isFoundSameItem)
    {
        [self.view makeToast:NSLocalizedString(@"already_assigned", nil)
                    duration:2.0
                    position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_03"]];
    }
    else
    {
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
        [tempDic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        if (isForSwitchIndex)
        {
            [verificationInfos replaceObjectAtIndex:toBeSwitchedIndex withObject:tempDic];
        }
        else
        {
            [verificationInfos addObject:tempDic];
        }
        [contentTableView reloadData];
    }
    
    if ([self.delegate respondsToSelector:@selector(operatorValueDidChange:)])
    {
        [self.delegate operatorValueDidChange:verificationInfos];
    }
    
    totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)verificationInfos.count];
}

- (void)didSelectCardOption:(NSInteger)optionIndex
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ListSubInfoPopupViewController *listSubInfoPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListSubInfoPopupViewController"];
    listSubInfoPopupCtrl.delegate = self;
    
    switch (optionIndex)
    {
        case 0:
            listSubInfoPopupCtrl.type = DEVICE_CARD;
            break;
        case 1:
            listSubInfoPopupCtrl.type = ASSIGN_CARD;
            break;
        
    }
    
    [self showPopup:listSubInfoPopupCtrl parentViewController:self parentView:self.view];
    
}


- (void)didSelectCard:(NSDictionary*)cardInfo
{
    // 카드 정보 현재 테이블뷰에 디스플레이 시키기.
    NSMutableDictionary *mutableCardInfo = [[NSMutableDictionary alloc] initWithDictionary:cardInfo];
    [mutableCardInfo setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
    [verificationInfos addObject:mutableCardInfo];
    [contentTableView reloadData];
}

- (void)cancelListPopupWithError:(NSDictionary*)errDic
{
    
    // 재시도 할것인지에 대한 팝업 띄워주기
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.delegate = self;
    imagePopupCtrl.type = REQUEST_FAIL;
    imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
    [imagePopupCtrl setContent:[errDic objectForKey:@"message"]];
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
}

#pragma mark - ScanPopupViewControllerDelegate


- (void)fingerprintScanDidSuccess:(NSDictionary*)fingerprintTemplate
{
    [fingerPrintDic setDictionary:fingerprintTemplate];
    
    [fingerPrintDic setObject:[NSNumber numberWithBool:NO] forKey:@"is_prepare_for_duress"];
    
    
    if (isForSwitchIndex)
    {
        [verificationInfos replaceObjectAtIndex:toBeSwitchedIndex withObject:fingerPrintDic];
        isForSwitchIndex = NO;
    }
    else
    {
        NSMutableDictionary *mutableFingerprint = [[NSMutableDictionary alloc] initWithDictionary:fingerPrintDic];
        [mutableFingerprint setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        [verificationInfos addObject:mutableFingerprint];
        
    }
    
    NSArray *tempArray = [[NSArray alloc] initWithArray:verificationInfos];
    
    [self setVerificationInfo:tempArray];
    
    if ([self.delegate respondsToSelector:@selector(fingerprintDidAdd:)])
    {
        [self.delegate fingerprintDidAdd:verificationInfos];
    }
    
    totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)verificationInfos.count];
}

- (void)fingerprintScanDidFail:(NSDictionary*)result currentFingerPrintDic:(NSMutableDictionary*)fingerdic currentScanCount:(NSInteger)scanCount
{
    fingerPrintScanCount = scanCount;
    [fingerPrintDic setDictionary:fingerdic];
    
    // 재시도 할것인지에 대한 팝업 띄워주기
    isForAPIRetry = YES;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.delegate = self;
    imagePopupCtrl.type = MAIN_REQUEST_FAIL;
    imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
    [imagePopupCtrl setContent:[result objectForKey:@"message"]];
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
}

- (void)fingerVerificationDidComplete:(BOOL)result
{
    fingerPrintScanCount = 0;
    
    if (!result)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        OneButtonPopupViewController *successPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonPopupViewController"];
        successPopupCtrl.type = FINGERPRINT_VERIFICATION_FAIL;
        [self showPopup:successPopupCtrl parentViewController:self parentView:self.view];
    }
}

// 카드 스캔후 레지스트 api 호출후 정상적일때 호출되는 부분
- (void)cardRegistDidSuccess:(NSDictionary*)cardInfo
{
    
    if ([[cardInfo objectForKey:@"unassigned"] boolValue])
    {
        BOOL hasSameCard = NO;
        
        for (NSDictionary *card in verificationInfos)
        {
            if ([[card objectForKey:@"card_id"] integerValue] == [[cardInfo objectForKey:@"card_id"] integerValue]) {
                hasSameCard = YES;
                break;
            }
        }
        
        if (!hasSameCard)
        {
            NSMutableDictionary *mutableCardInfo = [[NSMutableDictionary alloc] initWithDictionary:cardInfo];
            [mutableCardInfo setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            [verificationInfos addObject:mutableCardInfo];
            [contentTableView reloadData];
            
            totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)verificationInfos.count];
            
            if ([self.delegate respondsToSelector:@selector(cardDidAdd:)])
            {
                [self.delegate cardDidAdd:verificationInfos];
            }
        }
        else
        {
            [self.view makeToast:NSLocalizedString(@"already_assigned", nil)
                        duration:2.0
                        position:CSToastPositionBottom
                           image:[UIImage imageNamed:@"toast_popup_i_03"]];
        }
        
    }
    else
    {
        [self.view makeToast:NSLocalizedString(@"already_assigned", nil)
                    duration:2.0
                    position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_03"]];
    }
    
}

- (void)cardRegistDidFail:(NSDictionary*)result
{
    [self.view makeToast:[result objectForKey:@"message"]
                duration:2.0
                position:CSToastPositionBottom
                   image:[UIImage imageNamed:@"toast_popup_i_03"]];
}

- (void)cardScanDidFail:(NSDictionary*)result
{
    isForAPIRetry = YES;
    // 재시도 할것인지에 대한 팝업 띄워주기
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.delegate = self;
    imagePopupCtrl.type = REQUEST_FAIL;
    imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
    [imagePopupCtrl setContent:[result objectForKey:@"message"]];
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
}


#pragma mark - ListSubInfoPopupDelegate

- (void)confirmDeviceForRegisterCard:(NSDictionary*)dic
{
    // 카드 추가하는 팝업 띄우기
    if (nil != dic)
    {
        [infoDic setDictionary:dic];
        [self showScanPopup:_type];

    }
}

- (void)confirmDeviceForFingerprint:(NSDictionary*)dic
{
    if (nil != dic)
    {
        [infoDic setDictionary:dic];
        // 지문스캔 하라는 팝업띄우기
        [self showScanPopup:_type];
    }
}

- (void)confirmCardInfo:(NSDictionary*)dic
{
    NSMutableDictionary *mutableCardInfo = [[NSMutableDictionary alloc] initWithDictionary:dic];
    [mutableCardInfo setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
    [verificationInfos addObject:mutableCardInfo];
    [contentTableView reloadData];
    totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)verificationInfos.count];
    
    if ([self.delegate respondsToSelector:@selector(cardDidAdd:)])
    {
        [self.delegate cardDidAdd:verificationInfos];
    }
}

- (void)confirmCardsInfo:(NSMutableArray*)cardInfo
{
    for (NSDictionary *card in cardInfo)
    {
        NSMutableDictionary *mutableCardInfo = [[NSMutableDictionary alloc] initWithDictionary:card];
        [mutableCardInfo setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        [verificationInfos addObject:mutableCardInfo];
    }
    
    [contentTableView reloadData];
    totalCount.text = [NSString stringWithFormat:@"%ld", (unsigned long)verificationInfos.count];
    
    if ([self.delegate respondsToSelector:@selector(cardDidAdd:)])
    {
        [self.delegate cardDidAdd:verificationInfos];
    }
}

- (void)confirmExchangeCard:(NSDictionary*)dic
{
    [verificationInfos replaceObjectAtIndex:toBeSwitchedIndex withObject:dic];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:toBeSwitchedIndex inSection:0];
    [contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if ([self.delegate respondsToSelector:@selector(cardDidAdd:)])
    {
        [self.delegate cardDidAdd:verificationInfos];
    }
}

- (void)confirmExchangeAccessGroup:(NSDictionary *)dic
{
    // 선택된 그룹이 기존 그룹에 있는지 체크
    NSString *exchangeName = [dic objectForKey:@"name"];
    
    for (NSDictionary *currentDic in verificationInfos)
    {
        NSString *currentName = [currentDic objectForKey:@"name"];
        
        if ([currentName isEqualToString:exchangeName])
        {
            NSString *message = [NSString stringWithFormat:@"Already Assigned\n%@", currentName];
            [self.view makeToast:message
                        duration:2.0
                        position:CSToastPositionBottom
                           image:[UIImage imageNamed:@"toast_popup_i_06"]];
            return;
        }
    }
    
    // 삭제 모드를 위한 셋팅
    NSMutableDictionary *tempVerification = [[NSMutableDictionary alloc] initWithDictionary:dic];
    [tempVerification setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
    [tempVerification setObject:@"access_groups" forKey:@"type"];
    
    [verificationInfos replaceObjectAtIndex:toBeSwitchedIndex withObject:tempVerification];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:toBeSwitchedIndex inSection:0];
    [contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if ([self.delegate respondsToSelector:@selector(accessGroupDidChange:)])
    {
        NSMutableArray *accessGroups = [[NSMutableArray alloc] initWithArray:verificationInfos];
        if ([verificationInfos count] > 1)
        {
            // 첫번째 편집 불가한 항목 빼기
            [accessGroups removeObjectAtIndex:0];
        }
        [self.delegate accessGroupDidChange:accessGroups];
    }
}

- (void)confirmAddAccessGroup:(NSArray *)groups
{
    NSMutableArray *tempGroups = [[NSMutableArray alloc] init];
    for (NSDictionary *info in groups)
    {
        NSMutableDictionary *tempVerification = [[NSMutableDictionary alloc] initWithDictionary:info];
        [tempVerification setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        [tempVerification setObject:@"access_groups" forKey:@"type"];
        [tempGroups addObject:tempVerification];
    }
    
    // 선택된 그룹이 기존 그룹에 있는지 체크
    NSMutableArray *toBeAddGroups = [[NSMutableArray alloc] initWithArray:tempGroups];
    
    for (NSInteger i = 0; i < verificationInfos.count; i++)
    {
        NSDictionary *currentDic = [verificationInfos objectAtIndex:i];
        NSString *currentName = [currentDic objectForKey:@"name"];
        
        for (NSInteger j = 0; j < tempGroups.count; j++)
        {
            NSDictionary *selectedDic = [groups objectAtIndex:j];
            NSString *selectedName = [selectedDic objectForKey:@"name"];
            
            if ([currentName isEqualToString:selectedName])     //원래 속해 있던 그룹과 같을때
            {
                NSString *message = [NSString stringWithFormat:@"Already Assigned\n%@", currentName];
                [self.view makeToast:message
                            duration:2.0
                            position:CSToastPositionBottom
                               image:[UIImage imageNamed:@"toast_popup_i_06"]];
                [toBeAddGroups removeObject:[tempGroups objectAtIndex:j]];
            }
        }
    }
    
    [verificationInfos addObjectsFromArray:toBeAddGroups];
    
    if (verificationInfos.count > 16)
    {
        NSRange range;
        range.location = 16;
        range.length = verificationInfos.count - 16;
        [verificationInfos removeObjectsInRange:range];
        
        [self.view makeToast:NSLocalizedString(@"max_size", nil)
                    duration:2.0
                    position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_03"]];
    }
    
    totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)verificationInfos.count];
    
    [contentTableView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(accessGroupDidChange:)])
    {
        [self.delegate accessGroupDidChange:verificationInfos];
    }
    
}

- (void)cancelListSubInfoPopupWithError:(NSDictionary*)errDic
{
    isForAPIRetry = YES;
    // 재시도 할것인지에 대한 팝업 띄워주기
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.delegate = self;
    imagePopupCtrl.type = REQUEST_FAIL;
    imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
    [imagePopupCtrl setContent:[errDic objectForKey:@"message"]];
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
}


#pragma mark - ImagePopupDelegate

- (void)confirmImagePopup
{
    if (isForAPIRetry)
    {
        //[self addVerification:nil];
        switch (_type)
        {
            case FINGERPRINT:
            case CARD:
                [self showScanPopup:_type];
                break;
            case ACCESS_GROUPS:
            {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
                ListSubInfoPopupViewController *listSubInfoPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListSubInfoPopupViewController"];
                listSubInfoPopupCtrl.delegate = self;
                listSubInfoPopupCtrl.type = ADD_ACCESS_GROUP;
                [self showPopup:listSubInfoPopupCtrl parentViewController:self parentView:self.view];
            }
                break;
            default:
                break;
        }
    }
    else
    {
        // 기존 인증방식과 액세스 그룹중에서 삭제 알럿창 확인 선택된 셀 삭제
        [verificationInfos removeObjectsInArray:toDeleteArray];
        [toDeleteArray removeAllObjects];
        [contentTableView reloadData];
        
        totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)verificationInfos.count];
        
        switch (_type)
        {
            case FINGERPRINT:
                if ([self.delegate respondsToSelector:@selector(fingerprintDidAdd:)])
                {
                    [self.delegate fingerprintDidAdd:verificationInfos];
                }
                break;
                
            case CARD:
                if ([self.delegate respondsToSelector:@selector(cardDidAdd:)])
                {
                    [self.delegate cardDidAdd:verificationInfos];
                }
                break;
            case ACCESS_GROUPS:
                if ([self.delegate respondsToSelector:@selector(accessGroupDidChange:)])
                {
                    [self.delegate accessGroupDidChange:verificationInfos];
                }
                break;
            case OPERATOR:
                if ([self.delegate respondsToSelector:@selector(operatorValueDidChange:)])
                {
                    [self.delegate operatorValueDidChange:verificationInfos];
                }
                break;
            default:
                break;
        }
    }
}

- (void)cancelImagePopup
{
    fingerPrintScanCount = 0;
    [fingerPrintDic removeAllObjects];
}
@end
