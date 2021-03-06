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

- (void)checkAllSelected:(NSInteger)allCount selectedCount:(NSInteger)selectedCount;

@end

@implementation UserVerificationAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setSharedViewController:self];
    
    fingerPrintScanCount = 0;
    toDeleteArray = [[NSMutableArray alloc] init];
    isSelectedAll = NO;
    isForSwitchIndex = NO;
    scanQuality = 80;
    faceScanQuality = 4;
    userProvider = [[UserProvider alloc] init];
    totalDecLabel.text = NSBaseLocalizedString(@"total", nil);
    switch (_type)
    {
        case FINGERPRINT:
            titleLabel.text = NSBaseLocalizedString(@"fingerprint", nil);
            if ([PreferenceProvider isUpperVersion])
            {
                if (nil == fingerPrintTemplates || fingerPrintTemplates.count == 0)
                {
                    [self getUserFingerprintTemplates];
                }
                else
                {
                    totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)fingerPrintTemplates.count];
                }
                
            }
            else
            {
                totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)fingerPrintTemplates.count];
            }
            
            break;
        case ACCESS_GROUPS:
            titleLabel.text = NSBaseLocalizedString(@"access_group", nil);
            totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)userAccessGroups.count];
            break;
        case CARD:
            titleLabel.text = NSBaseLocalizedString(@"card", nil);
            totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)userCards.count];
            break;
        case FACETEMPLATE:
            titleLabel.text = NSBaseLocalizedString(@"face", nil);
            [self getUserFaceTemplates];
            break;
    }
    
    if (_isProfileMode)
    {
        [editButtonView setHidden:YES];
        [doneButtonView setHidden:YES];
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


- (void)setAccessGroup:(NSArray*)accessGroups withUserGroup:(NSArray*)userGroups
{
    userAccessGroups = [[NSMutableArray alloc] init];
    [userAccessGroups addObjectsFromArray:accessGroups];
    [userAccessGroups addObjectsFromArray:userGroups];
    [contentTableView reloadData];
}

- (void)setFingerPrintTemplates:(NSArray<FingerprintTemplate*>*)templates
{
    fingerPrintTemplates = [[NSMutableArray alloc] init];
    [fingerPrintTemplates addObjectsFromArray:templates];
    [contentTableView reloadData];
}

- (void)setCards:(NSArray<Card*>*)cards
{
    userCards = [[NSMutableArray alloc] init];
    [userCards addObjectsFromArray:cards];
    [contentTableView reloadData];
}

- (void)setUserInfo:(User*)user
{
    currentUser = user;
}

- (IBAction)addVerification:(id)sender
{
    switch (_type)
    {
        case FINGERPRINT:
        {
            if ([fingerPrintTemplates count] >= 10)
            {
                // 10 개 초과 등록 안됨
                [self.view makeToast:NSBaseLocalizedString(@"max_size", nil)
                            duration:2.0
                            position:CSToastPositionBottom
                               image:[UIImage imageNamed:@"toast_popup_i_03"]];
                
                return;
            }
            
            if (nil == fingerPrintTemplates || [fingerPrintTemplates count] == 0)
            {
                scanIndex = 0;
            }
            else
            {
                scanIndex = fingerPrintTemplates.count;
            }
            
            [self addFingerprint];
            
            break;
        }
        case ACCESS_GROUPS:
        {
            if ([userAccessGroups count] >= 16)
            {
                // 16 개 초과 등록 안됨
                [self.view makeToast:NSBaseLocalizedString(@"max_size", nil)
                            duration:2.0
                            position:CSToastPositionBottom
                               image:[UIImage imageNamed:@"toast_popup_i_03"]];
                return;
            }
            [self addAccessGroup];
            
            break;
        }
        case CARD:
        {
            if ([userCards count] >= 8)
            {
                // 8 개 초과 등록 안됨
                [self.view makeToast:NSBaseLocalizedString(@"max_size", nil)
                            duration:2.0
                            position:CSToastPositionBottom
                               image:[UIImage imageNamed:@"toast_popup_i_03"]];
                return;
            }
            [self addCard];
            
            break;
        }
        case FACETEMPLATE:
            if ([faceTemplates count] >= 5)
            {
                [self.view makeToast:NSBaseLocalizedString(@"max_size", nil)
                            duration:2.0
                            position:CSToastPositionBottom
                               image:[UIImage imageNamed:@"toast_popup_i_03"]];
                return;
            }
            
            [self addFaceTemplate];
            break;
    }
}

- (IBAction)moveToBack:(id)sender
{
    if (totalCountView.hidden)
    {
        switch (_type)
        {
            case FINGERPRINT:
                titleLabel.text = NSBaseLocalizedString(@"fingerprint", nil);
                for (FingerprintTemplate *info in fingerPrintTemplates)
                {
                    info.isSelected = NO;
                    
                }
                totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)fingerPrintTemplates.count];
                totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)fingerPrintTemplates.count];
                break;
            case ACCESS_GROUPS:
                titleLabel.text = NSBaseLocalizedString(@"access_group", nil);
                for (UserItemAccessGroup *info in userAccessGroups)
                {
                    info.isSelected = NO;
                    
                }
                totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)userAccessGroups.count];
                totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)userAccessGroups.count];
                break;
                
            case CARD:
                titleLabel.text = NSBaseLocalizedString(@"card", nil);
                for (Card *card in userCards)
                {
                    card.isSelected = NO;
                    
                }
                totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)userCards.count];
                totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)userCards.count];
                break;
            case FACETEMPLATE:
                titleLabel.text = NSBaseLocalizedString(@"face", nil);
                for (FaceTemplate *template in faceTemplates)
                {
                    template.isSelected = NO;
                    
                }
                totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)faceTemplates.count];
                totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)faceTemplates.count];
                break;
        }

        [toDeleteArray removeAllObjects];
        [selectAllButton setImage:[UIImage imageNamed:@"check_box_blank"] forState:UIControlStateNormal];
        [contentTableView reloadData];
        isSelectedAll = NO;
        
        [editButtonView setHidden:NO];
        [doneButtonView setHidden:YES];
        [totalCountView setHidden:NO];
        [verificationSelectView setHidden:YES];
        
        return;
    }
    [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
}

- (IBAction)deleteVerification:(id)sender
{
    switch (_type)
    {
        case FINGERPRINT:
            titleLabel.text = NSBaseLocalizedString(@"delete_fingerprint", nil);
            totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)fingerPrintTemplates.count];
            break;
        case ACCESS_GROUPS:
            titleLabel.text = NSBaseLocalizedString(@"access_group", nil);
            totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)userAccessGroups.count];
            break;
        case CARD:
            titleLabel.text = NSBaseLocalizedString(@"delete_card", nil);
            totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)userCards.count];
            break;
        case FACETEMPLATE:
            titleLabel.text = NSBaseLocalizedString(@"delete", nil);
            totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)faceTemplates.count];
            break;
    }

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
        // delete popup display
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = WARNING;
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"delete_confirm_question", nil);
        
        
        
        [imagePopupCtrl setContent:[NSString stringWithFormat:@"%@ %ld", NSBaseLocalizedString(@"selected_count", nil), (unsigned long)toDeleteArray.count]];
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
           
            if (isConfirm)
            {
                switch (_type)
                {
                    case FINGERPRINT:
                        [self deleteFingerprintTemplates];
                        break;
                        
                    case ACCESS_GROUPS:
                        [userAccessGroups removeObjectsInArray:toDeleteArray];
                        [toDeleteArray removeAllObjects];
                        totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)userAccessGroups.count];
                        if ([self.delegate respondsToSelector:@selector(accessGroupDidChange:)])
                        {
                            [self.delegate accessGroupDidChange:userAccessGroups];
                        }
                        
                        [contentTableView reloadData];
                        break;
                        
                    case CARD:
                        [userCards removeObjectsInArray:toDeleteArray];
                        totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)userCards.count];
                        if ([self.delegate respondsToSelector:@selector(cardWasChanged:)])
                        {
                            [self.delegate cardWasChanged:userCards];
                        }
                        [toDeleteArray removeAllObjects];
                        [contentTableView reloadData];
                        break;
                    case FACETEMPLATE:
                        [self deleteFaceTemplates];
                        break;
                }
                
                
            }
        }];
        
    }
    else
    {
        [self.view makeToast:NSBaseLocalizedString(@"selected_none", nil)
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
        switch (_type)
        {
            case FINGERPRINT:
                for (FingerprintTemplate *template in fingerPrintTemplates)
                {
                    template.isSelected = YES;
                    [toDeleteArray addObject:template];
                }
                totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)fingerPrintTemplates.count];
                break;
                
            case ACCESS_GROUPS:
                for (UserItemAccessGroup *accessGroup in userAccessGroups)
                {
                    if (nil != accessGroup.included_by_user_group)
                    {
                        if(![accessGroup.included_by_user_group isEqualToString:@"YES"])
                        {
                            accessGroup.isSelected = YES;
                            [toDeleteArray addObject:accessGroup];
                        }
                    }
                    else
                    {
                        accessGroup.isSelected = YES;
                        [toDeleteArray addObject:accessGroup];
                    }
                }
                totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)userAccessGroups.count];
                break;
                
            case CARD:
                for (Card *card in userCards)
                {
                    card.isSelected = YES;
                    [toDeleteArray addObject:card];
                }
                totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)userCards.count];
                break;
            case FACETEMPLATE:
                
                for (FaceTemplate *template in faceTemplates)
                {
                    template.isSelected = YES;
                    [toDeleteArray addObject:template];
                }
                totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)faceTemplates.count];
                
                break;
        }
        [sender setImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
    }
    else
    {
        switch (_type)
        {
            case FINGERPRINT:
                for (FingerprintTemplate *template in fingerPrintTemplates)
                {
                    template.isSelected = NO;
                }
                totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)fingerPrintTemplates.count];
                break;
            
            case ACCESS_GROUPS:
                for (UserItemAccessGroup *accessGroup in userAccessGroups)
                {
                    if (nil != accessGroup.included_by_user_group)
                    {
                        if(![accessGroup.included_by_user_group isEqualToString:@"YES"])
                        {
                            accessGroup.isSelected = NO;
                        }
                    }
                    else
                    {
                        accessGroup.isSelected = NO;
                    }
                }
                totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)userAccessGroups.count];
                break;
                
            case CARD:
                for (Card *card in userCards)
                {
                    card.isSelected = NO;
                }
                totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)userCards.count];
                break;
                
            case FACETEMPLATE:
                
                for (FaceTemplate *template in faceTemplates)
                {
                    template.isSelected = NO;
                }
                totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)faceTemplates.count];
                
                break;
                
        }
        
        [sender setImage:[UIImage imageNamed:@"check_box_blank"] forState:UIControlStateNormal];
    }
    
    [contentTableView reloadData];
    isSelectedAll = !isSelectedAll;
    
}




- (void)getUserFingerprintTemplates
{
    if (_isProfileMode)
    {
        if (currentUser.fingerprint_templates && currentUser.fingerprint_templates.count > 0)
        {
            fingerPrintTemplates = [[NSMutableArray alloc] initWithArray:currentUser.fingerprint_templates];
        }
        
        [contentTableView reloadData];
    }
    else
    {
        [self startLoading:self];
        
        [userProvider getUserFingerprints:currentUser.user_id resultBlock:^(NSArray<FingerprintTemplate *> *result) {
            
            [self finishLoading];
            
            if (nil == fingerPrintTemplates)
            {
                fingerPrintTemplates = [[NSMutableArray alloc] initWithArray:result];
            }
            else
            {
                [fingerPrintTemplates removeAllObjects];
                [fingerPrintTemplates addObjectsFromArray:result];
            }
            
            
            totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)fingerPrintTemplates.count];
            
            [contentTableView reloadData];
            
        } onErrorBlock:^(Response *error) {
            
            [self finishLoading];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
            imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
            [imagePopupCtrl setContent:error.message];
            imagePopupCtrl.type = MAIN_REQUEST_FAIL;
            [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
            
            [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
                if (isConfirm)
                {
                    [self getUserFingerprintTemplates];
                }
                else
                {
                    [self moveToBack:nil];
                }
                
            }];
            
        }];
    }
}

- (void)getUserFaceTemplates
{
    if (_isProfileMode)
    {
        if (currentUser.face_templates && currentUser.face_templates.count > 0)
        {
            faceTemplates = [[NSMutableArray alloc] initWithArray:currentUser.face_templates];
        }
        [contentTableView reloadData];
    }
    else
    {
        [self startLoading:self];
        
        [userProvider getUserFaceTemplate:currentUser.user_id resultBlock:^(UserFaceTemplateList *result) {
            
            [self finishLoading];
            
            if (nil == faceTemplates)
            {
                faceTemplates = [[NSMutableArray alloc] initWithArray:result.face_template_list];
            }
            else
            {
                [faceTemplates removeAllObjects];
                [faceTemplates addObjectsFromArray:result.face_template_list];
            }
            
            
            totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)faceTemplates.count];
            
            [contentTableView reloadData];
            
        } onErrorBlock:^(Response *error) {
            
            [self finishLoading];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
            imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
            [imagePopupCtrl setContent:error.message];
            imagePopupCtrl.type = MAIN_REQUEST_FAIL;
            [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
            
            [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
                if (isConfirm)
                {
                    [self getUserFaceTemplates];
                }
                else
                {
                    [self moveToBack:nil];
                }
                
            }];
            
        }];
    }
    
}

- (void)deleteFingerprintTemplates
{
    if ([PreferenceProvider isUpperVersion])
    {
        [self startLoading:self];
        
        NSMutableArray *tempFingerprintTemplates = [[NSMutableArray alloc] initWithArray:fingerPrintTemplates];
        [tempFingerprintTemplates removeObjectsInArray:toDeleteArray];
        
        UserFingerprintRecords *record = [UserFingerprintRecords new];
        record.fingerprint_template_list = tempFingerprintTemplates;
        
        [userProvider updateUserFingerprints:record userID:currentUser.user_id resultBlock:^(Response *response) {
            
            [self finishLoading];
            [toDeleteArray removeAllObjects];
            [fingerPrintTemplates removeAllObjects];
            [fingerPrintTemplates addObjectsFromArray:tempFingerprintTemplates];
            
            totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)fingerPrintTemplates.count];
            
            if ([self.delegate respondsToSelector:@selector(fingerprintWasChanged:)])
            {
                [self.delegate fingerprintWasChanged:fingerPrintTemplates];
            }
            
            [contentTableView reloadData];
            
        } onErrorBlock:^(Response *error) {
            
            [self finishLoading];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
            imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
            [imagePopupCtrl setContent:error.message];
            imagePopupCtrl.type = MAIN_REQUEST_FAIL;
            [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
            
            [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
                if (isConfirm)
                {
                    [self deleteFingerprintTemplates];
                }
                
            }];
            
        }];
    }
    else
    {
        [fingerPrintTemplates removeObjectsInArray:toDeleteArray];
        totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)fingerPrintTemplates.count];
        
        if ([self.delegate respondsToSelector:@selector(fingerprintWasChanged:)])
        {
            [self.delegate fingerprintWasChanged:fingerPrintTemplates];
        }
        
        [contentTableView reloadData];
    }
    
}

- (void)deleteFaceTemplates
{
    [self startLoading:self];
    
    NSMutableArray <FaceTemplate*>*tempTemplates = [[NSMutableArray alloc] initWithArray:faceTemplates];
    
    [tempTemplates removeObjectsInArray:toDeleteArray];
    
    UserFaceTemplateList *templateList = [UserFaceTemplateList new];
    templateList.face_template_list = tempTemplates;
    
    [userProvider updateUserFaceTemplate:templateList userID:currentUser.user_id resultBlock:^(Response *response) {
        
        [self finishLoading];
        
        [faceTemplates removeObjectsInArray:toDeleteArray];
        [toDeleteArray removeAllObjects];
        
        totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)faceTemplates.count];
        
        if ([self.delegate respondsToSelector:@selector(faceTemplatesWasChanged:)])
        {
            [self.delegate faceTemplatesWasChanged:faceTemplates];
        }
        
        totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)faceTemplates.count];
        [contentTableView reloadData];
        
        
    } onErrorBlock:^(Response *error) {
        
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        imagePopupCtrl.type = MAIN_REQUEST_FAIL;
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self deleteFaceTemplates];
            }
            
        }];
        
    }];
    
}

- (void)updateFingerprintTemplages:(FingerprintTemplate*)fingerprintTemplate
{
    if ([PreferenceProvider isUpperVersion])
    {
        [self startLoading:self];
        
        UserFingerprintRecords *templateList = [UserFingerprintRecords new];
        
        NSMutableArray <FingerprintTemplate*>*tempTemplates = [[NSMutableArray alloc] initWithArray:fingerPrintTemplates];
        
        if (isForSwitchIndex)
        {
            [tempTemplates replaceObjectAtIndex:toBeSwitchedIndex withObject:fingerprintTemplate];
        }
        else
        {
            [tempTemplates addObject:fingerprintTemplate];
        }
        
        templateList.fingerprint_template_list = tempTemplates;
        
        [userProvider updateUserFingerprints:templateList userID:currentUser.user_id resultBlock:^(Response *response) {
            
            [self finishLoading];
            
            userFingerPrintTemplate = fingerprintTemplate;
            userFingerPrintTemplate.is_prepare_for_duress = NO;
            
            
            if (isForSwitchIndex)
            {
                [fingerPrintTemplates replaceObjectAtIndex:toBeSwitchedIndex withObject:userFingerPrintTemplate];
            }
            else
            {
                [fingerPrintTemplates addObject:userFingerPrintTemplate];
            }
            
            isForSwitchIndex = NO;
            
            if ([self.delegate respondsToSelector:@selector(fingerprintWasChanged:)])
            {
                [self.delegate fingerprintWasChanged:fingerPrintTemplates];
            }
            totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)fingerPrintTemplates.count];
            [contentTableView reloadData];
            
        } onErrorBlock:^(Response *error) {
            
            [self finishLoading];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
            imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
            [imagePopupCtrl setContent:error.message];
            imagePopupCtrl.type = MAIN_REQUEST_FAIL;
            [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
            
            [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
                if (isConfirm)
                {
                    [self updateFingerprintTemplages:fingerprintTemplate];
                }
                
            }];
            
        }];
    }
    else
    {
        userFingerPrintTemplate = fingerprintTemplate;
        userFingerPrintTemplate.is_prepare_for_duress = NO;
        
        if (isForSwitchIndex)
        {
            [fingerPrintTemplates replaceObjectAtIndex:toBeSwitchedIndex withObject:userFingerPrintTemplate];
            isForSwitchIndex = NO;
        }
        else
        {
            [fingerPrintTemplates addObject:userFingerPrintTemplate];
        }
        
        if ([self.delegate respondsToSelector:@selector(fingerprintWasChanged:)])
        {
            [self.delegate fingerprintWasChanged:fingerPrintTemplates];
        }
        totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)fingerPrintTemplates.count];
        [contentTableView reloadData];
    }
    
}

- (void)updateFaceTemplates:(FaceTemplate*)faceTemplate
{
    [self startLoading:self];
    
    NSMutableArray <FaceTemplate*>*tempTemplates = [[NSMutableArray alloc] initWithArray:faceTemplates];
    
    if (isForSwitchIndex)
    {
        [tempTemplates replaceObjectAtIndex:toBeSwitchedIndex withObject:faceTemplate];
    }
    else
    {
        // 추가 일때는 id 항목 빼야 함
        [tempTemplates addObject:faceTemplate];
    }
    
    UserFaceTemplateList *templateList = [UserFaceTemplateList new];
    templateList.face_template_list = tempTemplates;
    
    [userProvider updateUserFaceTemplate:templateList userID:currentUser.user_id resultBlock:^(Response *response) {
        
        [self finishLoading];
        
        if (isForSwitchIndex)
        {
            [faceTemplates replaceObjectAtIndex:toBeSwitchedIndex withObject:faceTemplate];
        }
        else
        {
            [faceTemplates addObject:faceTemplate];
        }
        
        isForSwitchIndex = NO;
        
        if ([self.delegate respondsToSelector:@selector(faceTemplatesWasChanged:)])
        {
            [self.delegate faceTemplatesWasChanged:faceTemplates];
        }
        
        totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)faceTemplates.count];
        [contentTableView reloadData];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        FaceScanSuccessPopupViewController *successPopupController = [storyboard instantiateViewControllerWithIdentifier:@"FaceScanSuccessPopupViewController"];
        
        [successPopupController setCurrentUserID:currentUser.user_id];
        [successPopupController setPhoto:faceTemplate.raw_image];
        [successPopupController setIndex:scanIndex];
        [self showPopup:successPopupController parentViewController:self parentView:self.view];
        
        
        
    } onErrorBlock:^(Response *error) {
        
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        imagePopupCtrl.type = MAIN_REQUEST_FAIL;
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self updateFaceTemplates:faceTemplate];
            }
            
        }];
        
    }];
    
    
}

- (void)addFingerprint
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    DevicePopupViewController *devicePopupController = [storyboard instantiateViewControllerWithIdentifier:@"DevicePopupViewController"];
    
    devicePopupController.deviceMode = FINGERPRINT_MODE;
    [self showPopup:devicePopupController parentViewController:self parentView:self.view];
    [devicePopupController getDevice:^(SearchResultDevice *device) {
        selectedDevice = device;
        [self showFingerprintScanPopup];
        
    }];
    
}

- (void)addFaceTemplate
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    DevicePopupViewController *devicePopupController = [storyboard instantiateViewControllerWithIdentifier:@"DevicePopupViewController"];
    
    devicePopupController.deviceMode = FACE_TEMPLATE;
    [self showPopup:devicePopupController parentViewController:self parentView:self.view];
    [devicePopupController getDevice:^(SearchResultDevice *device) {
        selectedDevice = device;
        [self showFaceScanPopup];
        
    }];
    
    [devicePopupController getCancelBlock:^{
        isForSwitchIndex = NO;
    }];
}




- (void)replaceAccessGroup:(NSIndexPath*)indexPath
{
    toBeSwitchedIndex = indexPath.row;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    AccessGroupPopupViewController *accessGroupPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"AccessGroupPopupViewController"];
    
    accessGroupPopupCtrl.type = EXCHANGE_ACCESS_GROUP;
    [self showPopup:accessGroupPopupCtrl parentViewController:self parentView:self.view];
    [accessGroupPopupCtrl setUserAccessGroups:userAccessGroups];
    
    [accessGroupPopupCtrl getAccessGroupBlock:^(AccessGroupItem *accessGroup) {
        //삭제 모드를 위한 셋팅
        accessGroup.isSelected = NO;
        [userAccessGroups replaceObjectAtIndex:indexPath.row withObject:accessGroup];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:toBeSwitchedIndex inSection:0];
        [contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if ([self.delegate respondsToSelector:@selector(accessGroupDidChange:)])
        {
            [self.delegate accessGroupDidChange:userAccessGroups];
        }
    }];
}


- (void)addCard
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ListPopupViewController *listPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListPopupViewController"];
    listPopupCtrl.type = CARD_OPTION;
    
    [self showPopup:listPopupCtrl parentViewController:self parentView:self.view];
    [listPopupCtrl addOptions:@[NSBaseLocalizedString(@"registeration_option_card_reader", nil) ,NSBaseLocalizedString(@"registeration_option_assign_card", nil)]];
    
    [listPopupCtrl getIndexResponseBlock:^(NSInteger index) {
        
        if (index == 0)
        {
            // 스캔할 디바이스 선택
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            DevicePopupViewController *devicePopupController = [storyboard instantiateViewControllerWithIdentifier:@"DevicePopupViewController"];
            
            devicePopupController.deviceMode = CARD_MODE;
            [self showPopup:devicePopupController parentViewController:self parentView:self.view];
            [devicePopupController getDevice:^(SearchResultDevice *device) {
                selectedDevice = device;
                
                // 카드 스캔 팝업 띄우기
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
                ScanCardPopupViewController *scanCardPopupController = [storyboard instantiateViewControllerWithIdentifier:@"ScanCardPopupViewController"];
                
                [scanCardPopupController setDeviceID:selectedDevice.id];
                [self showPopup:scanCardPopupController parentViewController:self parentView:self.view];
                
                [scanCardPopupController getScanCard:^(Card *scanCard) {
                    
                    BOOL hasEqualCard = [self hasEqualCard:scanCard];
                    
                    if (hasEqualCard)
                    {
                        [self.view makeToast:NSBaseLocalizedString(@"already_assigned", nil)
                                    duration:2.0
                                    position:CSToastPositionBottom
                                       image:[UIImage imageNamed:@"toast_popup_i_03"]];
                        return;
                    }
                    
                    [userCards addObject:scanCard];
                    [contentTableView reloadData];
                    totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)userCards.count];
                    
                    if ([self.delegate respondsToSelector:@selector(cardWasChanged:)])
                    {
                        [self.delegate cardWasChanged:userCards];
                    }
                }];
                
            }];
        }
        else
        {
            // 카드 assign
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            CardPopupViewController *cardPopupController = [storyboard instantiateViewControllerWithIdentifier:@"CardPopupViewController"];
            [cardPopupController setCardType:CSN_CARD_MODE];
            [self showPopup:cardPopupController parentViewController:self parentView:self.view];
            
            [cardPopupController getCardBlock:^(Card *card) {
                
                BOOL hasEqualCard = [self hasEqualCard:card];
                
                if (hasEqualCard)
                {
                    [self.view makeToast:NSBaseLocalizedString(@"already_assigned", nil)
                                duration:2.0
                                position:CSToastPositionBottom
                                   image:[UIImage imageNamed:@"toast_popup_i_03"]];
                    return;
                }
                
                card.isSelected = NO;
                [userCards addObject:card];
                [contentTableView reloadData];
                totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)userCards.count];
                if ([self.delegate respondsToSelector:@selector(cardWasChanged:)])
                {
                    [self.delegate cardWasChanged:userCards];
                }
            }];
        }
        
        
    }];
}


- (void)replaceFingerprint:(NSIndexPath*)indexPath
{
    isForSwitchIndex = YES;
    toBeSwitchedIndex = indexPath.row;
    scanIndex = indexPath.row;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    DevicePopupViewController *devicePopupController = [storyboard instantiateViewControllerWithIdentifier:@"DevicePopupViewController"];
    
    devicePopupController.deviceMode = FINGERPRINT_MODE;
    [self showPopup:devicePopupController parentViewController:self parentView:self.view];
    [devicePopupController getDevice:^(SearchResultDevice *device) {
        selectedDevice = device;
        [self showFingerprintScanPopup];
    }];
}

- (void)replaceCard:(NSIndexPath*)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    CardPopupViewController *cardPopupController = [storyboard instantiateViewControllerWithIdentifier:@"CardPopupViewController"];
    
    [self showPopup:cardPopupController parentViewController:self parentView:self.view];
    [cardPopupController setCardType:CSN_CARD_MODE];
    [cardPopupController getCardBlock:^(Card *card) {
        
        card.isSelected = NO;
        [userCards replaceObjectAtIndex:indexPath.row withObject:card];
        
        if ([self.delegate respondsToSelector:@selector(cardWasChanged:)])
        {
            [self.delegate cardWasChanged:userCards];
        }
    }];
    
}

- (void)replaceFaceTemplate:(NSIndexPath*)indexPath
{
    isForSwitchIndex = YES;
    toBeSwitchedIndex = indexPath.row;
    scanIndex = indexPath.row;
    
    [self addFaceTemplate];
}

- (void)addAccessGroup
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    AccessGroupPopupViewController *accessGroupPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"AccessGroupPopupViewController"];
    
    accessGroupPopupCtrl.type = ADD_ACCESS_GROUP;
    [self showPopup:accessGroupPopupCtrl parentViewController:self parentView:self.view];
    [accessGroupPopupCtrl setUserAccessGroups:userAccessGroups];
    [accessGroupPopupCtrl getAccessGroupsBlock:^(NSArray<AccessGroupItem *> *accessGroups) {
        
        [userAccessGroups addObjectsFromArray:accessGroups];
        
        totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)userAccessGroups.count];
        
        [contentTableView reloadData];
        
        if ([self.delegate respondsToSelector:@selector(accessGroupDidChange:)])
        {
            [self.delegate accessGroupDidChange:userAccessGroups];
        }
    }];
}


- (void)showFaceScanPopup
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    FaceScanPopupViewController *scanPopupController = [storyboard instantiateViewControllerWithIdentifier:@"FaceScanPopupViewController"];
    
    if (!isForSwitchIndex)
    {
        if (nil == faceTemplates || [faceTemplates count] == 0)
        {
            scanIndex = 0;
        }
        else
        {
            scanIndex = faceTemplates.count;
        }
    }
    
    [scanPopupController setScanIndex:scanIndex];
    [scanPopupController setDeviceID:selectedDevice.id];
    [scanPopupController setScanQuality:faceScanQuality];
    [self showPopup:scanPopupController parentViewController:self parentView:self.view];
    
    [scanPopupController getFaceTemplate:^(FaceTemplate *scanedFaceTemplate) {
        
        [self updateFaceTemplates:scanedFaceTemplate];
        
    }];
    
    [scanPopupController getErrorBlock:^(Response *error) {
        
        // low quality failed
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = LOW_QUALITY;
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            
            if (isConfirm)
            {
                // 재스캔 방식 팝업
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
                ListPopupViewController *listPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListPopupViewController"];
                listPopupCtrl.type = PEROID;
                [self showPopup:listPopupCtrl parentViewController:self parentView:self.view];
                
                NSString *defaultDec = NSBaseLocalizedString(@"rescan_default", nil);
                defaultDec = [defaultDec stringByReplacingOccurrencesOfString:@"80" withString:@"4"];
                
                [listPopupCtrl addOptions:@[defaultDec,
                                            NSBaseLocalizedString(@"rescan_change", nil)]];
                
                [listPopupCtrl getIndexResponseBlock:^(NSInteger index) {
                    
                    if (index == 0)
                    {
                        faceScanQuality = 4;
                        [self showFaceScanPopup];
                    }
                    else
                    {
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
                        ScanQualityPopupViewController *qualityPopup = [storyboard instantiateViewControllerWithIdentifier:@"ScanQualityPopupViewController"];
                        qualityPopup.scanType = FACE_SCAN;
                        [self showPopup:qualityPopup parentViewController:self parentView:self.view];
                        
                        [qualityPopup getResponse:^(NSUInteger quality) {
                            
                            faceScanQuality = quality;
                            
                            [self showFaceScanPopup];
                        }];
                        
                    }
                }];
            }
        }];
        
    }];
    
}

- (void)showFingerprintScanPopup
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ScanPopupViewController *scanPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ScanPopupViewController"];
    [scanPopupCtrl setFingerprint:fingerPrintResult];
    [scanPopupCtrl setScanIndex:scanIndex];
    [scanPopupCtrl setTemplateIndex:maxFingerprintIndex + 1];
    [scanPopupCtrl setDeviceID:selectedDevice.id];
    [scanPopupCtrl setScanQuality:scanQuality];
    [self showPopup:scanPopupCtrl parentViewController:self parentView:self.view];
    
    // 지문 스캔 2회 후 verity 실패 팝업에서 cancel 눌렀을 경우
    [scanPopupCtrl getBoolResponse:^(BOOL result) {
        fingerPrintResult = nil;
        fingerPrintScanCount = 0;
    }];
    
    // 지문등록 정상적으로 끝났을때
    [scanPopupCtrl getFingerPrintTemplate:^(FingerprintTemplate *fingerprintTemplate) {
        
        fingerPrintResult = nil;
        fingerPrintScanCount = 0;
        
        [self updateFingerprintTemplages:fingerprintTemplate];
        
        
    }];
    
    // 지문 스캔중 실패 했을 때
    [scanPopupCtrl getLowQualityBlock:^(FingerprintTemplate *fingerprintTemplate, NSString *errorMessage) {
    
        fingerPrintResult = fingerprintTemplate;
        
        // low quality failed
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = LOW_QUALITY;
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:errorMessage];
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            
            if (isConfirm)
            {
                // 재스캔 방식 팝업
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
                ListPopupViewController *listPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListPopupViewController"];
                listPopupCtrl.type = PEROID;
                [self showPopup:listPopupCtrl parentViewController:self parentView:self.view];
                
                [listPopupCtrl addOptions:@[NSBaseLocalizedString(@"rescan_default", nil),
                                            NSBaseLocalizedString(@"rescan_change", nil)]];
                
                [listPopupCtrl getIndexResponseBlock:^(NSInteger index) {
                   
                    if (index == 0)
                    {
                        scanQuality = 80;
                        [self showFingerprintScanPopup];
                    }
                    else
                    {
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
                        ScanQualityPopupViewController *qualityPopup = [storyboard instantiateViewControllerWithIdentifier:@"ScanQualityPopupViewController"];
                        qualityPopup.scanType = FINGERPRINT_SCAN;
                        [self showPopup:qualityPopup parentViewController:self parentView:self.view];
                        
                        [qualityPopup getResponse:^(NSUInteger quality) {
                            
                            scanQuality = quality;
                            
                            [self showFingerprintScanPopup];
                        }];
                        
                        [qualityPopup getCancelResponse:^{
                            fingerPrintResult = nil;
                            fingerPrintScanCount = 0;
                        }];
                    }
                }];
                
                [listPopupCtrl getCancelBlock:^{
                    fingerPrintResult = nil;
                    fingerPrintScanCount = 0;
                }];

            }
            else
            {
                fingerPrintResult = nil;
                fingerPrintScanCount = 0;
            }
        }];
    }];

}


- (BOOL)hasEqualCard:(Card*)card
{
    BOOL hasEqualCard = NO;
    
    for (Card *assignedCard in userCards)
    {
        if ([card.card_id isEqualToString:assignedCard.card_id])
        {
            hasEqualCard = YES;
            break;
        }
    }
    
    return hasEqualCard;
}


- (void)checkAllSelected:(NSInteger)allCount selectedCount:(NSInteger)selectedCount
{
    if (allCount == selectedCount)
    {
        isSelectedAll = YES;
        [selectAllButton setImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
    }
    else
    {
        if (_type == ACCESS_GROUPS)
        {
            NSUInteger unAddableCount = 0;
            for (UserItemAccessGroup *accessGroup in userAccessGroups)
            {
                if([accessGroup.included_by_user_group isEqualToString:@"YES"] || [accessGroup.included_by_user_group isEqualToString:@"BOTH"])
                {
                    // 편집 불가한 항목 상속받은 유저 그룹
                    unAddableCount++;
                }
            }
            
            if (allCount - selectedCount == unAddableCount)
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
            isSelectedAll = NO;
            [selectAllButton setImage:[UIImage imageNamed:@"check_box_blank"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - NotificationCenter method


- (void)scanQualityHasChanged:(NSNotification*)userInfo
{
    scanQuality = [[userInfo.object objectForKey:QUALITY] unsignedIntegerValue];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (_type)
    {
        case FINGERPRINT:
            return [fingerPrintTemplates count];
            break;
        case ACCESS_GROUPS:
            return [userAccessGroups count];
            break;
        case CARD:
            return [userCards count];
            break;
        case FACETEMPLATE:
            return [faceTemplates count];
            break;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VerificationCell" forIndexPath:indexPath];
    VerificationCell *customCell = (VerificationCell*)cell;
    
    switch (_type)
    {
        case FINGERPRINT:
        {
            NSInteger value = indexPath.row + 1;
            NSString *description;
            
            if (value == 1)
                description = [NSString stringWithFormat:@"%ld%@ %@",(long)value ,NSBaseLocalizedString(@"st", nil) ,NSBaseLocalizedString(@"fingerprint", nil)];
            else if (value == 2)
                description = [NSString stringWithFormat:@"%ld%@ %@",(long)value ,NSBaseLocalizedString(@"nd", nil) ,NSBaseLocalizedString(@"fingerprint", nil)];
            else if (value == 3)
                description = [NSString stringWithFormat:@"%ld%@ %@",(long)value ,NSBaseLocalizedString(@"rd", nil) ,NSBaseLocalizedString(@"fingerprint", nil)];
            else
                description = [NSString stringWithFormat:@"%ld%@ %@",(long)value ,NSBaseLocalizedString(@"th", nil) ,NSBaseLocalizedString(@"fingerprint", nil)];
            
            customCell.titleLabel.text = description;
            
            if (self.isProfileMode)
            {
                [customCell.accImage setHidden:YES];
            }
            else
            {
                [customCell.accImage setHidden:NO];
                FingerprintTemplate *template = [fingerPrintTemplates objectAtIndex:indexPath.row];
                [customCell setCheckSeleted:template.isSelected];
            }
            
            break;
        }
            
        case ACCESS_GROUPS:
        {
            UserItemAccessGroup *accessGroup = [userAccessGroups objectAtIndex:indexPath.row];
            [customCell setAccessGroup:accessGroup isEditMode:totalCountView.hidden];
        }
            break;
        case CARD:
            
            customCell.titleLabel.text = userCards[indexPath.row].card_id;
            if (totalCountView.hidden)
            {
                [customCell.accImage setHidden:YES];
            }
            else
            {
                [customCell.accImage setHidden:NO];
            }
            [customCell setCheckSeleted:userCards[indexPath.row].isSelected];
            break;
        case FACETEMPLATE:
        {
            NSInteger value = indexPath.row + 1;
            NSString *description;
            
            if (value == 1)
                description = [NSString stringWithFormat:@"%ld%@ %@",
                               (long)value, NSBaseLocalizedString(@"st", nil), NSBaseLocalizedString(@"face", nil)];
            else if (value == 2)
                description = [NSString stringWithFormat:@"%ld%@ %@",
                               (long)value, NSBaseLocalizedString(@"nd", nil), NSBaseLocalizedString(@"face", nil)];
            else if (value == 3)
                description = [NSString stringWithFormat:@"%ld%@ %@",
                               (long)value, NSBaseLocalizedString(@"rd", nil), NSBaseLocalizedString(@"face", nil)];
            else
                description = [NSString stringWithFormat:@"%ld%@ %@",
                               (long)value, NSBaseLocalizedString(@"th", nil), NSBaseLocalizedString(@"face", nil)];
            
            customCell.titleLabel.text = description;
            
            if (self.isProfileMode)
            {
                [customCell.accImage setHidden:YES];
            }
            else
            {
                [customCell.accImage setHidden:NO];
                [customCell setCheckSeleted:faceTemplates[indexPath.row].isSelected];
            }
            
            
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
                FingerprintTemplate *template = [fingerPrintTemplates objectAtIndex:indexPath.row];
                
                template.isSelected = !template.isSelected;
                if (template.isSelected)
                {
                    [toDeleteArray addObject:template];
                }
                else
                {
                    [toDeleteArray removeObject:template];
                }
                [self checkAllSelected:fingerPrintTemplates.count selectedCount:toDeleteArray.count];
                
                totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)fingerPrintTemplates.count];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else
            {
                // 지문 교체 모드
                [self replaceFingerprint:indexPath];

            }
            break;
        
        case ACCESS_GROUPS:
        {
            UserItemAccessGroup *accessGroup = [userAccessGroups objectAtIndex:indexPath.row];
            if([accessGroup.included_by_user_group isEqualToString:@"YES"] || [accessGroup.included_by_user_group isEqualToString:@"BOTH"])
            {
                // 편집 불가한 항목 상속받은 유저 그룹
                [self.view makeToast:NSBaseLocalizedString(@"inherited_not_change", nil)
                            duration:2.0 position:CSToastPositionBottom
                               title:NSBaseLocalizedString(@"inherited", nil)
                               image:[UIImage imageNamed:@"toast_popup_i_05"]];
                return;
            }
            if (totalCountView.hidden)
            {
                // ACCESS_GROUPS 삭제 모드
                accessGroup.isSelected = !accessGroup.isSelected;
                if (accessGroup.isSelected)
                {
                    [toDeleteArray addObject:accessGroup];
                }
                else
                {
                    [toDeleteArray removeObject:accessGroup];
                }
                
                [self checkAllSelected:userAccessGroups.count selectedCount:toDeleteArray.count];
                
                totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)userAccessGroups.count];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else
            {
                // ACCESS_GROUPS 교체 모드
                [self replaceAccessGroup:indexPath];
                
            }
            break;
        }
            
        case CARD:
            if (totalCountView.hidden)
            {
                // 카드 삭제 모드
                Card *card = [userCards objectAtIndex:indexPath.row];
                
                card.isSelected = !card.isSelected;
                if (card.isSelected)
                {
                    [toDeleteArray addObject:card];
                }
                else
                {
                    [toDeleteArray removeObject:card];
                }
                
                [self checkAllSelected:userCards.count selectedCount:toDeleteArray.count];
                
                totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)userCards.count];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else
            {
                // 카드 교체 모드
                [self replaceCard:indexPath];
                
            }
            break;
        case FACETEMPLATE:
            
            if (totalCountView.hidden)
            {
                // FACETEMPLATE 삭제 모드
                FaceTemplate *template = [faceTemplates objectAtIndex:indexPath.row];
                
                template.isSelected = !template.isSelected;
                if (template.isSelected)
                {
                    [toDeleteArray addObject:template];
                }
                else
                {
                    [toDeleteArray removeObject:template];
                }
                [self checkAllSelected:faceTemplates.count selectedCount:toDeleteArray.count];
                
                totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)faceTemplates.count];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else
            {
                // FACETEMPLATE 교체 모드
                [self replaceFaceTemplate:indexPath];
                
            }
            
            break;
            
    }
}


@end
