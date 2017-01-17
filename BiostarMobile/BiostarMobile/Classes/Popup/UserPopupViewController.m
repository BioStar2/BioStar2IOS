//
//  UserPopupViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 10..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "UserPopupViewController.h"

@interface UserPopupViewController ()

@end

@implementation UserPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self setSharedViewController:self];
    
    users = [[NSMutableArray alloc] init];
    selectedUsers = [[NSMutableArray alloc] init];
    [containerView setHidden:YES];
    hasNextPage = NO;
    offset = 0;
    limit = 50;
    
    [cancelBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    
    listTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    userProvider = [[UserProvider alloc] init];
    titleLabel.text = NSLocalizedString(@"select_user_original", nil);
    [self getUsersOffset:offset limit:limit groupID:@"1" query:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [super popupViewDidAppear:contentView];
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



- (void)getUsersOffset:(NSInteger)searchOffset limit:(NSInteger)searchLimit groupID:(NSString*)groupID query:(NSString*)searchQuery
{
    [self startLoading:self];
    
    [userProvider getUsersOffset:searchOffset limit:searchLimit groupID:groupID query:searchQuery completeHandler:^(UserSearchResult *userSearchResult) {
        
        [self finishLoading];
        
        NSInteger count = userSearchResult.total;
        if (isForSearch)
        {
            [selectedUsers removeAllObjects];
            [users removeAllObjects];
            isForSearch = NO;
        }
        else
        {
            // 최초로 불러 올때만 팝업 사이즈 조절및 애니메이션 적용
            if (users.count == 0)
                [self adjustHeight:count];
        }
        
        searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)selectedUsers.count, (unsigned long)count];
        if (count == 0)
        {
            [users removeAllObjects];
        }
        else
        {
            [users addObjectsFromArray:userSearchResult.records];
        }
        
        if (count > users.count)
        {
            offset += limit;
            hasNextPage = YES;
        }
        else
        {
            hasNextPage = NO;
        }
        
        [listTableView reloadData];
        
    } onError:^(Response *error) {
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            
            if (isConfirm)
            {
                [self getUsersOffset:searchOffset limit:searchLimit groupID:groupID query:searchQuery];
            }
            else
            {
                [self closePopup:self parentViewController:self.parentViewController];
            }
        }];
    }];
    
    
}


- (IBAction)showSearchTextFieldView:(id)sender
{
    [textView setHidden:NO];
    [searchTextField resignFirstResponder];
}



- (IBAction)cancelSearch:(id)sender
{
    [self.view endEditing:YES];
    [textView setHidden:YES];
}





- (void)adjustHeight:(NSInteger)count
{
    if (count < 4)
    {
        containerHeightConstraint.constant = LIST_SUB_POPUP_MINIMUM_HEIGHT;
    }
    [containerView setHidden:NO];
    [self showPopupAnimation:containerView];
}

- (IBAction)cancelCurrentPopup:(id)sender
{
    [self closePopup:self parentViewController:self.parentViewController];
}

- (IBAction)confirmCurrentPopup:(id)sender
{
    if (self.usersBlock && selectedUsers.count != 0)
    {
        self.usersBlock(selectedUsers);
        self.usersBlock = nil;
    }
    
    [self closePopup:self parentViewController:self.parentViewController];
}

- (void)getUsers:(UsersBlock)usersBlock
{
    self.usersBlock = usersBlock;
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RadioCell" forIndexPath:indexPath];
    RadioCell *customCell = (RadioCell*)cell;
    User *user = [users objectAtIndex:indexPath.row];
    [customCell checkSelected:user.isSelected];
    NSString *name = user.name;
    NSString *ID = user.user_id;
    if (nil == name || [name isEqualToString:@""])
    {
        name = ID;
    }
    NSString *description = [NSString stringWithFormat:@"%@ / %@",ID, name];
    customCell.titleLabel.text = description;
    
    if (indexPath.row == users.count -1)
    {
        if (hasNextPage)
        {
            [self getUsersOffset:offset limit:limit groupID:@"1" query:query];
        }
    }
    
    return customCell;
}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [users objectAtIndex:indexPath.row];
    user.isSelected = !user.isSelected;

    if (user.isSelected)
    {
        [selectedUsers addObject:user];
    }
    else
    {
        [selectedUsers removeObject:user];
    }

    searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)selectedUsers.count, (long)users.count];
    
    [tableView reloadData];
}



#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    query = textField.text;
    offset = 0;
    [selectedUsers removeAllObjects];
    [users removeAllObjects];
    [self getUsersOffset:offset limit:limit groupID:@"1" query:query];
    
    [textField resignFirstResponder];
    return YES;
}

@end
