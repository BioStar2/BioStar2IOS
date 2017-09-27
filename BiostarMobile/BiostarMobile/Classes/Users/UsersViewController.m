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

#import "UsersViewController.h"

@interface UsersViewController ()

- (void)getUserList:(NSInteger)listOffset limit:(NSInteger)listLimit groupID:(NSString*)listGroupID query:(NSString*)listQuery;

@end

@implementation UsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSharedViewController:self];
    // Do any additional setup after loading the view.
    selectedUserGroup = nil;
    usersTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    refreshControl = [[UIRefreshControl alloc] init];
    [usersTableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshUsers) forControlEvents:UIControlEventValueChanged];
    totalDecLabel.text = NSBaseLocalizedString(@"total", nil);
    titleLabel.text = NSBaseLocalizedString(@"all_users", nil);
    canScrollTop = NO;
    scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
    isFirstLoad = YES;
    
    if ([PreferenceProvider isUpperVersion])
    {
        //groupID = [AuthProvider getLoginUserInfo].permission.permissions[0].allowed_group_id_list[0];
        groupID = nil;
    }
    else
    {
        groupID = @"1";
    }
    
    offset = 0;
    limit = 50;
    totalCount = 0;
    isSelectedAllUser = NO;
    hasNextPage = NO;
    isForFilter = NO;
    selectedUserCount.text = @"0";
    query = nil;
    isEditMode = NO;
    isSearchMode = NO;
    secondYPosition = 0.0f;
    
    users = [[NSMutableArray alloc] init];
    toDeleteUsers = [[NSMutableArray alloc] init];
    
    provider = UserProviderInstance;
    preferenceProvoder = [[PreferenceProvider alloc] init];
    [self getUserList:offset limit:limit groupID:groupID query:query];
    
    if (![AuthProvider hasWritePermission:USER_PERMISSION])
    {
        // 추가, 삭제
        [addButton setHidden:YES];
        [deleteButton setHidden:YES];
    }
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(useFaceTemplateForProfilePicture:)
                                                 name:USE_FACE_TEMPLATE
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:USE_FACE_TEMPLATE object:nil];
}

- (void)useFaceTemplateForProfilePicture:(NSNotification*)userInfo
{
    NSString *photoStr = [userInfo.object objectForKey:@"photo"];
    NSString *updatedUserID = [userInfo.object objectForKey:@"userID"];
    
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:photoStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *serverImage = [UIImage imageWithData:imageData];
    UIImage* scaledImage = [CommonUtil imageCompress:serverImage fileSize:MAX_IMAGE_FILE_SIZE];
    
    for (NSUInteger i = 0; i < users.count; i++)
    {
        User *user = [users objectAtIndex:i];
        if ([user.user_id isEqualToString:updatedUserID])
        {
            user.photo_exist = YES;
            
            NSString *userPhotoKey = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USER_PHOTO, user.user_id]];
            [[SDImageCache sharedImageCache] storeImage:scaledImage forKey:userPhotoKey toDisk:YES];
            
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
            [usersTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            break;
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)loadUserPhoto:(NSArray*)tempUsers
{
    for (User *user in tempUsers)
    {
        if (user.photo_exist && nil == user.photo)
        {
            
            NSString *userPhotoKey = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USER_PHOTO, user.user_id]];
            
            if (![[SDImageCache sharedImageCache] diskImageExistsWithKey:userPhotoKey])
            {
                [provider getUserPhoto:user.user_id completeHandler:^(NSDictionary *responseObject, NSError *error) {
                    if (nil == error)
                    {
                        NSData *imageData = [NSData base64DataFromString:[responseObject objectForKey:@"user_image"]];
                        UIImage *userImage = [UIImage imageWithData:imageData];
                        
                        [[SDImageCache sharedImageCache] storeImage:userImage forKey:userPhotoKey toDisk:YES];
                        
                        NSInteger index = [users indexOfObject:user];
                        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
                        [usersTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
                        
                    }
                }];
            }
        }
    }
}

- (void)getUserList:(NSInteger)listOffset limit:(NSInteger)listLimit groupID:(NSString*)listGroupID query:(NSString*)listQuery
{
    [self startLoading:self];
    
    [provider getUsersOffset:listOffset limit:listLimit groupID:listGroupID query:listQuery completeHandler:^(UserSearchResult *userSearchResult) {
        
        isFirstLoad = NO;
        
        [refreshControl endRefreshing];
        [self finishLoading];
        
        if (!isForFilter)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:USER_COUNT_UPDATE object:@{@"count" : [NSNumber numberWithInteger:userSearchResult.total]}];
        }
        else
            isForFilter = NO;
        
        
        totalCount = userSearchResult.total;
        
        if (isEditMode)
        {
            totalUserCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)[toDeleteUsers count], (long)totalCount];
        }
        else
        {
            totalUserCount.text = [NSString stringWithFormat:@"%ld", (long)userSearchResult.total];
        }
        
        [self finishLoading];
        if (userSearchResult.total == 0)
        {
            // 검색결과가 없거나 실제 데이터가 없을 경우
            hasNextPage = NO;
            [users removeAllObjects];
        }
        else
        {
            [users addObjectsFromArray:userSearchResult.records];
            
            if (users.count < userSearchResult.total)
            {
                hasNextPage = YES;
                offset += limit;
            }
            else
            {
                hasNextPage = NO;
            }
        }
        canScrollTop = NO;
        scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
        [usersTableView reloadData];
        
        [self loadUserPhoto:users];
        
    } onError:^(Response *error) {
        
        [refreshControl endRefreshing];
        [self finishLoading];
        
        [self showImagePopup:NSBaseLocalizedString(@"fail_retry", nil) magePopupType:MAIN_REQUEST_FAIL content:error.message];
    }];
    
}

- (void)deleteSelectedUsers:(NSArray *)seletedUsers
{
    [self startLoading:self];
    
    [provider deleteUsers:seletedUsers responseBlock:^(Response *error) {
        [refreshControl endRefreshing];
        [self finishLoading];
        
        //User Deleted 1
        
        NSString *deleteToast = [NSString stringWithFormat:@"%@ %ld",NSBaseLocalizedString(@"deleted_user", nil), (unsigned long)toDeleteUsers.count];
        [self.view makeToast:deleteToast
                    duration:1.0
                    position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_03"]];
        
        [toDeleteUsers removeAllObjects];
        [users removeAllObjects];
        [usersTableView setEditing:NO animated:YES];
        
        offset = 0;
        selectedUserCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)[toDeleteUsers count]];
        [self getUserList:offset limit:limit groupID:groupID query:query];
        
        
    } onErrorBlock:^(Response *error) {
        [refreshControl endRefreshing];
        [self finishLoading];
        
        [self showImagePopup:NSBaseLocalizedString(@"fail_retry", nil) magePopupType:DELETE_USERS content:error.message];
    }];
}

- (void)refreshUsers
{
    [toDeleteUsers removeAllObjects];
    
    offset = 0;
    totalCount = 0;
    
    [users removeAllObjects];
    [usersTableView reloadData];
    
    [self getUserList:offset limit:limit groupID:groupID query:query];
    
}

- (void)setDefaultView
{
    if (isSearchMode)
    {
        isSearchMode = YES;
        [selectView setHidden:YES];
        [searchView setHidden:NO];
    }
    else
    {
        [searchView setHidden:YES];
    }
    
    [doneButton setHidden:YES];
    [editButtonView setHidden:NO];
    if ([AuthProvider hasWritePermission:USER_PERMISSION])
    {
        // 추가, 삭제
        [addButton setHidden:NO];
        [deleteButton setHidden:NO];
    }
    [toDeleteUsers removeAllObjects];
    isEditMode = NO;
    
    if ([selectedUserGroup.name isEqualToString:@""] || nil == selectedUserGroup.name)
    {
        titleLabel.text = NSBaseLocalizedString(@"all_users", nil);
    }
    else
    {
        titleLabel.text = selectedUserGroup.name;
    }
    
    totalUserCount.text = [NSString stringWithFormat:@"%ld", (long)totalCount];
    
    [usersTableView reloadData];
}

- (IBAction)moveToBack:(id)sender
{
    if (isEditMode)
    {
        [self setDefaultView];
        
        [toDeleteUsers removeAllObjects];
        
        for (User *user in users)
        {
            user.isSelected = NO;
        }
        
        selectedUserCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)[toDeleteUsers count]];
        [usersTableView reloadData];
    }
    else
    {
        [NetworkControllerInstance cancelAllRequests];
        
        [users removeAllObjects];
        users = nil;
        usersTableView = nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NEED_TO_GET_MOBILE_CREDENTIAL object:nil];
        
        [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
    }
}

- (IBAction)addUser:(id)sender
{
    if ([PreferenceProvider isUpperVersion])
    {
        [self startLoading:self];
        
        [preferenceProvoder getBiostarACSetting:^(BioStarSetting *result) {
            
            [self finishLoading];
            
            if (selectedUserGroup)
            {
                [self moveToCreateUserController:selectedUserGroup];
            }
            else
            {
                [self showUserGroups];
            }
            
        } onError:^(Response *error) {
            
            [self finishLoading];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
            imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
            imagePopupCtrl.type = REQUEST_FAIL;
            [imagePopupCtrl setContent:error.message];
            [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
            
            [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
                
                if (isConfirm)
                {
                    [self addUser:nil];
                }
                
            }];
            
        }];
    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UserNewDetailViewController __weak *userEditViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserNewDetailViewController"];
        userEditViewController.delegate = self;
        userEditViewController.type = CREATE_MODE;
        
        [self pushChildViewController:userEditViewController parentViewController:self contentView:contentView animated:YES];
        
        if (selectedUserGroup)
        {
            [userEditViewController setUserGroup:selectedUserGroup];
        }
    }
}

- (void)showUserGroups
{
    [self startLoading:self];
    [provider getUserGroups:^(UserGroupSearchResult *userSearchResult) {
        
        [self finishLoading];
        
        if (userSearchResult.records.count == 0)
        {
            UserGroup *defaultUserGroup = [UserGroup new];
            defaultUserGroup.id = @"1";
            defaultUserGroup.name = @"All users";
            
            [self moveToCreateUserController:defaultUserGroup];
            
        }
        else if ( userSearchResult.records.count == 1 )
        {
            [self moveToCreateUserController:userSearchResult.records[0]];
        }
        else
        {
            BOOL isFoundAllUser = NO;
            UserGroup *allUserGroup;
            for (UserGroup *userGroup in userSearchResult.records)
            {
                if ([userGroup.id isEqualToString:@"1"])
                {
                    allUserGroup = userGroup;
                    isFoundAllUser = YES;
                    break;
                }
            }
            
            if (isFoundAllUser)
            {
                [self moveToCreateUserController:allUserGroup];
            }
            else
            {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
                UserGroupPopupViewController *listPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"UserGroupPopupViewController"];
                
                [self showPopup:listPopupCtrl parentViewController:self parentView:self.view];
                
                [listPopupCtrl getSelectedUserGroup:^(UserGroup *userGroup) {
                    
                    [self moveToCreateUserController:userGroup];
                    
                }];
            }
            
        }
        
    } onError:^(Response *error) {
        
        [self finishLoading];
        
        // 재시도 할것인지에 대한 팝업 띄워주기
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self showUserGroups];
            }
        }];
        
    }];
}

- (void)moveToCreateUserController:(UserGroup*)userGroup
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserNewDetailViewController __weak *userEditViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserNewDetailViewController"];
    userEditViewController.delegate = self;
    userEditViewController.type = CREATE_MODE;
    
    [self pushChildViewController:userEditViewController parentViewController:self contentView:contentView animated:YES];
    
    [userEditViewController setUserGroup:userGroup];
}

- (IBAction)changeToDeleteMode:(id)sender
{
    if (!isSearchMode)
    {
        [searchView setHidden:YES];
    }
    [usersTableView reloadData];
    // 한글 일본어 일때 순서 바꾸기
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:language];
    NSString *languageCode = [languageDic objectForKey:@"kCFLocaleLanguageCodeKey"];
    
    if ([languageCode isEqualToString:@"ko"] || [languageCode isEqualToString:@"ja"])
    {
        titleLabel.text = [NSString stringWithFormat:@"%@ %@",NSBaseLocalizedString(@"user", nil) ,NSBaseLocalizedString(@"delete", nil)];
    }
    else
    {
        titleLabel.text = [NSString stringWithFormat:@"%@ %@",NSBaseLocalizedString(@"delete", nil) ,NSBaseLocalizedString(@"user", nil)];
    }

    isEditMode = YES;
    
    [self.view endEditing:YES];
    [editButtonView setHidden:YES];
    [doneButton setHidden:NO];
    
    totalUserCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)[toDeleteUsers count], (long)totalCount];
    
}

- (IBAction)cancelSearch:(id)sender
{
    isSearchMode = NO;
    
    if (!isEditMode)
    {
        //[self setDefaultView];
    }
    
    [selectView setHidden:NO];
    [searchView setHidden:YES];
    
    [self.view endEditing:YES];
    
    if ((nil == query || [query isEqualToString:@""]) && didSearch)
    {
        [users removeAllObjects];
        didSearch = NO;
//        if ([PreferenceProvider isUpperVersion])
//        {
//            groupID = nil;
//        }
//        else
//        {
//            groupID = @"1";
//        }
        query = nil;
        offset = 0;
        limit = 50;
        [self getUserList:offset limit:limit groupID:groupID query:query];
    }
}


- (IBAction)showSearchView:(id)sender
{
    isSearchMode = YES;
    [selectView setHidden:YES];
    [searchView setHidden:NO];
    
    [searchTextField becomeFirstResponder];
}

- (IBAction)scrollTopOrBottom:(id)sender {
    
    if (nil == users || users.count == 0)
    {
        return;
    }
    
    if (canScrollTop)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [usersTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
        canScrollTop = NO;
    }
    else
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:users.count - 1 inSection:0];
        [usersTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
        
        if (users.count == totalCount)
        {
            canScrollTop = YES;
            scrollButton.transform = CGAffineTransformMakeRotation(0);
        }
    }
}

- (IBAction)showUserGroupFilter:(id)sender
{
    [self.view endEditing:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    UserGroupPopupViewController *listPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"UserGroupPopupViewController"];
    
    [self showPopup:listPopupCtrl parentViewController:self parentView:self.view];
    
    [listPopupCtrl getSelectedUserGroup:^(UserGroup *userGroup) {
        
        isForFilter = YES;
        titleLabel.text = userGroup.name;
        selectedUserGroup = userGroup;
        groupID = userGroup.id;
        offset = 0;
        [users removeAllObjects];
        
        [self getUserList:offset limit:limit groupID:groupID query:query];

    }];
}

- (IBAction)deleteUsers:(id)sender
{
    [self.view endEditing:YES];
    if ([toDeleteUsers count] > 0)
    {
        [self showImagePopup:NSBaseLocalizedString(@"delete_confirm_question", nil) magePopupType:DELETE_USERS content:[NSString stringWithFormat:@"%@ %ld", NSBaseLocalizedString(@"selected_count", nil), (unsigned long)toDeleteUsers.count]];
        
    }
    else
    {
        [self.view makeToast:NSBaseLocalizedString(@"selected_none", nil)
                    duration:2.0
                    position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_03"]];
        
    }
}

- (void)showImagePopup:(NSString*)title magePopupType:(ImagePopupType)type content:(NSString*)content
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.titleContent = title;
    imagePopupCtrl.type = type;
    [imagePopupCtrl setContent:content];
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
    
    [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
        
        if (isConfirm)
        {
            if (type == DELETE_USERS)
            {
                [self deleteSelectedUsers:toDeleteUsers];
            }
            else if (type == MAIN_REQUEST_FAIL)
            {
                [self getUserList:offset limit:limit groupID:groupID query:query];
            }
        }
        else
        {
            if (type == MAIN_REQUEST_FAIL)
            {
                if (isFirstLoad)
                {
                    // 최초 유저리스트 못 불러와서 이전 화면으로 가주어야 함.
                    [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
                }
            }
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [users count];
    //return 500;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userInfoCell" forIndexPath:indexPath];

    // Configure the cell...

    [cell setUser:[users objectAtIndex:indexPath.row] isEditMode:isEditMode];
    
    
    
    if (indexPath.row == users.count -1)
    {
        if (hasNextPage)
        {
            [self getUserList:offset limit:limit groupID:groupID query:query];
        }
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [users objectAtIndex:indexPath.row];
    [toDeleteUsers addObject:user.user_id];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    TextPopupViewController *textPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"TextPopupViewController"];
    
    textPopupCtrl.type = USER_DELETE;
    [self showPopup:textPopupCtrl parentViewController:self parentView:self.view];
    
    [textPopupCtrl getResponse:^(TextPopupType type, BOOL isConfirm) {
        if (isConfirm)
        {
            [self deleteSelectedUsers:toDeleteUsers];
        }
    }];
    
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    if (isEditMode)
    {
        User *user = [users objectAtIndex:indexPath.row];

        if (![PermissionProvider isEnableDeleteUser:user])
        {
            return;
        }
        
//        if ([CommonUtil isAllDigits:user.user_id])
//        {
//            if ([user.user_id integerValue] == 1)
//            {
//                return;
//            }
//        }
        
        if (user.isSelected)
        {
            user.isSelected = NO;
            [toDeleteUsers removeObject:user.user_id];
        }
        else
        {
            user.isSelected = YES;
            [toDeleteUsers addObject:user.user_id];
        }
        
        totalUserCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)[toDeleteUsers count], (long)totalCount];
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UserNewDetailViewController __weak *userDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserNewDetailViewController"];
        userDetailViewController.delegate = self;
        [userDetailViewController getUserInfo:[users objectAtIndex:indexPath.row].user_id];
        [userDetailViewController setType:VIEW_MODE];
        [self pushChildViewController:userDetailViewController parentViewController:self contentView:contentView animated:YES];
    }
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""])
    {
        isForFilter = YES;
        for (User *user in users)
        {
            user.isSelected = NO;
        }
        selectedUserCount.text = @"0";
        [toDeleteUsers removeAllObjects];
        
        query = textField.text;
        offset = 0;
        [users removeAllObjects];
        [usersTableView reloadData];
        
        [self getUserList:offset limit:limit groupID:groupID query:query];
        
        [textField resignFirstResponder];
        didSearch = YES;
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    query = @"";
    return YES;
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString *content = [[NSMutableString alloc] initWithString:textField.text];
    
    if (![string isEqualToString:@""])
    {
        // append
        @try {
            [content insertString:string atIndex:range.location];
        } @catch (NSException *exception) {
            NSLog(@"%@ \n %@", exception.description, content);
        }
    }
    else
    {
        //delete
        @try {
            [content deleteCharactersInRange:range];
        } @catch (NSException *exception) {
            NSLog(@"%@ \n %@", exception.description, content);
        }
    }
    
    query = content;
    return YES;
}


#pragma mark - UserDetailDelegate
- (void)needToReloadUsers
{
    [self refreshUsers];
}


#pragma mark - ScrollView Delegate


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidEndDecelerating");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    secondYPosition = scrollView.contentOffset.y;
    //NSLog(@"scrollViewDidEndDragging");
    if (firstYPosition < secondYPosition)
    {
        // 스크롤 위로 움직이게
        if (decelerate)
            canScrollTop = NO;
    }
    else
    {
        // 스크롤 아래로
        if (decelerate)
            canScrollTop = YES;
    }
    if (canScrollTop)
    {
        scrollButton.transform = CGAffineTransformMakeRotation(0);
    }
    else
    {
        scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
    }
    
    if (scrollView.contentOffset.y > scrollView.contentSize.height - usersTableView.frame.size.height) {
        //NSLog(@"bouncing down");
        canScrollTop = YES;
        scrollButton.transform = CGAffineTransformMakeRotation(0);
    }
    
    if (scrollView.contentOffset.y < 0) {
        //NSLog(@"bouncing up");
        canScrollTop = NO;
        scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidScroll");
    secondYPosition = scrollView.contentOffset.y;
    
    if (scrollView.contentOffset.y < 0) {
        //NSLog(@"bouncing up");
        canScrollTop = NO;
        scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
    }
    
    
    if (scrollView.contentOffset.y > scrollView.contentSize.height - usersTableView.frame.size.height) {
        //NSLog(@"bouncing down");
        canScrollTop = YES;
        scrollButton.transform = CGAffineTransformMakeRotation(0);
    }
   
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    firstYPosition = scrollView.contentOffset.y;
    
}


@end
