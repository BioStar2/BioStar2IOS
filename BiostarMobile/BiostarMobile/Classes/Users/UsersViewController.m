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

@end

@implementation UsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    refreshControl = [[UIRefreshControl alloc] init];
    //refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"refresh Users"];
    [usersTableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshUsers) forControlEvents:UIControlEventValueChanged];
    
    canScrollTop = NO;
    scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
    
    groupID = @"1";
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
    [users removeAllObjects];
    
    provider = UserProviderInstance;
    provider.delegate = self;
    [provider getUsersOffset:offset limit:limit groupID:groupID query:query];
    [self startLoading:self];
    
    
    if (![AuthProvider hasWritePermission:@"USER"])
    {
        // 추가, 삭제, 필터 버튼 삭제
        [editButtonView setHidden:YES];
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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)refreshUsers
{

    isEditMode = NO;
    [toDeleteUsers removeAllObjects];
    
    for (NSMutableDictionary *user in users)
    {
        [user setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
    }
    
    offset = 0;
    totalCount = 0;
    
    [users removeAllObjects];
    [usersTableView reloadData];
    [provider getUsersOffset:offset limit:limit groupID:groupID query:query];
    [self startLoading:self];
}

- (void)setDefaultView
{
    [doneButton setHidden:YES];
    [editButtonView setHidden:NO];
    [toDeleteUsers removeAllObjects];
    isEditMode = NO;
    if ([[filterUserGroup objectForKey:@"name"] isEqualToString:@""] || nil == [filterUserGroup objectForKey:@"name"])
    {
        titleLabel.text = NSLocalizedString(@"all_users", nil);
    }
    else
    {
        titleLabel.text = [filterUserGroup objectForKey:@"name"];
    }
    
    totalUserCount.text = [NSString stringWithFormat:@"%ld", (long)totalCount];
    [searchView setHidden:YES];
    [usersTableView reloadData];
}

- (IBAction)moveToBack:(id)sender
{
    if (isEditMode)
    {
        [self setDefaultView];
        
        [toDeleteUsers removeAllObjects];
        for (NSMutableDictionary *user in users)
        {
            [user setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        }
        selectedUserCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)[toDeleteUsers count]];
        [usersTableView reloadData];
    }
    else
    {
        [provider setDelegate:nil];
        [NetworkControllerInstance cancelAllRequests];
        
        [users removeAllObjects];
        users = nil;
        usersTableView = nil;
        
        [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
    }
}

- (IBAction)addUser:(id)sender
{
 
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserNewDetailViewController __weak *userEditViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserNewDetailViewController"];
    userEditViewController.delegate = self;
    userEditViewController.type = CREATE_MODE;
    
    [self pushChildViewController:userEditViewController parentViewController:self contentView:contentView animated:YES];
    
    if (filterUserGroup)
    {
        [userEditViewController setUserGroup:filterUserGroup];
    }
}

- (IBAction)changeToDeleteMode:(id)sender
{
    if (!isSearchMode)
    {
        [searchView setHidden:YES];
    }
    [usersTableView reloadData];
    titleLabel.text = NSLocalizedString(@"delete_user", nil);
    isEditMode = YES;
    
    [self.view endEditing:YES];
    [editButtonView setHidden:YES];
    [doneButton setHidden:NO];
    
    totalUserCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)[toDeleteUsers count], (long)totalCount];
    
}

- (IBAction)cancelSearch:(id)sender
{
    if (!isEditMode)
    {
        [self setDefaultView];
    }
    
    isSearchMode = NO;
    
    [selectView setHidden:NO];
    [searchView setHidden:YES];
    
    [self.view endEditing:YES];
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
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ListSubInfoPopupViewController *listPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListSubInfoPopupViewController"];
    listPopupCtrl.delegate = self;
    listPopupCtrl.type = USER_GROUP;
    [self showPopup:listPopupCtrl parentViewController:self parentView:self.view];
}

- (IBAction)deleteUsers:(id)sender
{
    if ([toDeleteUsers count] > 0)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.delegate = self;
        imagePopupCtrl.titleContent = NSLocalizedString(@"delete_confirm_question", nil);
        imagePopupCtrl.type = DELETE_USERS;
        [imagePopupCtrl setContent:[NSString stringWithFormat:NSLocalizedString(@"selected_count %ld", nil), toDeleteUsers.count]];
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
    NSDictionary *dic = [users objectAtIndex:indexPath.row];
    [cell setCellDictionary:dic];
    
    if (isEditMode)
    {
        [cell.accView setHidden:YES];
    }
    else
    {
        [cell.accView setHidden:NO];
    }
    
    
    if (indexPath.row == users.count -1)
    {
        if (hasNextPage)
        {
            [provider getUsersOffset:offset limit:limit groupID:groupID query:query];
            [self startLoading:self];
        }
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![AuthProvider hasWritePermission:@"USER"])
    {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [users objectAtIndex:indexPath.row];
    [toDeleteUsers addObject:[dic valueForKey:@"user_id"]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    TextPopupViewController *textPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"TextPopupViewController"];
    textPopupCtrl.delegate = self;
    textPopupCtrl.type = USER_DELETE;
    [self showPopup:textPopupCtrl parentViewController:self parentView:self.view];
    
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    if (isEditMode)
    {
        
        NSMutableDictionary *userDic = [users objectAtIndex:indexPath.row];
        
        if ([[userDic objectForKey:@"selected"] boolValue])
        {
            [userDic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            [toDeleteUsers removeObject:[userDic valueForKey:@"user_id"]];
        }
        else
        {
            [userDic setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
            [toDeleteUsers addObject:[userDic valueForKey:@"user_id"]];
        }
        
        totalUserCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)[toDeleteUsers count], (long)totalCount];
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UserNewDetailViewController __weak *userDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserNewDetailViewController"];
        userDetailViewController.delegate = self;
        NSDictionary *dic = [users objectAtIndex:indexPath.row];
        [userDetailViewController getUserInfo:[dic valueForKey:@"user_id"]];
        [userDetailViewController setType:VIEW_MODE];
        [self pushChildViewController:userDetailViewController parentViewController:self contentView:contentView animated:YES];
    }
    
    
    
    
}

#pragma mark - UserProvider delegate

- (void)requestDidFinishDeleteUser:(NSDictionary*)result
{
    [self finishLoading];
    [toDeleteUsers removeAllObjects];
    [users removeAllObjects];
    [usersTableView setEditing:NO animated:YES];
    
    offset = 0;
    selectedUserCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)[toDeleteUsers count]];
    [provider getUsersOffset:offset limit:limit groupID:groupID query:query];
    [self startLoading:self];
}

- (void)requestDidFinishGettingUsersInfo:(NSArray*)userArray totclCount:(NSInteger)count
{
    if (!isForFilter)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:USER_COUNT_UPDATE object:@{@"count" : [NSNumber numberWithInteger:count]}];
    }
    else
        isForFilter = NO;
    
    [refreshControl endRefreshing];
    
    totalCount = count;
    totalUserCount.text = [NSString stringWithFormat:@"%ld", (long)totalCount];
    [self finishLoading];
    if (count == 0)
    {
        // 검색결과가 없거나 실제 데이터가 없을 경우
        hasNextPage = NO;
        [users removeAllObjects];
    }
    else
    {
        // 선택 삭제를 위해 뮤터블 딕션어리로 교체
        for (NSDictionary *user in userArray)
        {
            NSMutableDictionary *tempUser = [[NSMutableDictionary alloc] initWithDictionary:user];
            [tempUser setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            [users addObject:tempUser];
        }
        
        if (users.count < totalCount)
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
    
}

- (void)requestUserProviderDidFail:(NSDictionary *)errDic
{
    [refreshControl endRefreshing];
    [self finishLoading];
    
    // 재시도 할것인지에 대한 팝업 띄워주기
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.delegate = self;
    imagePopupCtrl.type = MAIN_REQUEST_FAIL;
    imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
    [imagePopupCtrl setContent:[errDic objectForKey:@"message"]];
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    for (NSMutableDictionary *user in users)
    {
        [user setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
    }
    selectedUserCount.text = @"0";
    [toDeleteUsers removeAllObjects];
    
    query = textField.text;
    offset = 0;
    [users removeAllObjects];
    [usersTableView reloadData];
    [provider getUsersOffset:offset limit:limit groupID:groupID query:query];
    [self startLoading:self];
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - TextPopupDelegate

- (void)confirmDeleteUser
{
    [provider deleteUsers:toDeleteUsers];
    [self startLoading:self];
}

- (void)confirmDeleteUsers
{
    [provider deleteUsers:toDeleteUsers];
    [self startLoading:self];
}

#pragma mark - ImagePopupDelegate

- (void)confirmImagePopup
{
    if (isEditMode)
    {
        [provider deleteUsers:toDeleteUsers];
        [self startLoading:self];
    }
    else
    {
        [provider getUsersOffset:offset limit:limit groupID:groupID query:query];
        [self startLoading:self];
    }
}

- (void)cancelImagePopup
{
    switch (provider.type)
    {
        case UsersInfo:
            if (offset == 0)
            {
                // 최초 유저리스트 못 불러와서 이전 화면으로 가주어야 함.
                [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
            }
            break;
        default:
            break;
    }
    
}

#pragma mark - UserDetailDelegate
- (void)needToReloadUsers
{
    [self refreshUsers];
}

#pragma mark - ListSubInfoPopupDelegate

- (void)confirmUserGroup:(NSDictionary*)userGroup
{
    //query = textField.text;
    isForFilter = YES;
    titleLabel.text = [userGroup objectForKey:@"name"];
    filterUserGroup = userGroup;
    groupID = [NSString stringWithFormat:@"%ld", (long)[[userGroup objectForKey:@"id"] integerValue]];
    offset = 0;
    [users removeAllObjects];
    [provider getUsersOffset:offset limit:limit groupID:groupID query:query];
    [self startLoading:self];
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
