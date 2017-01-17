//
//  UserGroupPopupViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 1..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "UserGroupPopupViewController.h"

@interface UserGroupPopupViewController ()

@end

@implementation UserGroupPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setSharedViewController:self];
    totalDecLabel.text = NSLocalizedString(@"total", nil);
    [cancelBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    
    isMenuSelected = NO;
    [containerView setHidden:YES];
    titleLabel.text = NSLocalizedString(@"select_user_group", nil);
    userProvider = [[UserProvider alloc] init];
    userGroups = [[NSMutableArray alloc] init];
    [self getUserGroups];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelCurrentPopup:(id)sender
{
    [self closePopup:self parentViewController:self.parentViewController];
}

- (IBAction)confirmCurrentPopup:(id)sender
{
    if (self.userGroupSelectBlock) {
        if (isMenuSelected) {
            self.userGroupSelectBlock(selectedUserGroup);
            self.userGroupSelectBlock = nil;
        }
    }
    
    [self closePopup:self parentViewController:self.parentViewController];
}

- (void)getSelectedUserGroup:(UserGroupSelectBlock)userGroupSelectBlock;
{
    self.userGroupSelectBlock = userGroupSelectBlock;
}

- (void)getUserGroups
{
    [self startLoading:self];
    [userProvider getUserGroups:^(UserGroupSearchResult *userSearchResult) {
        
        [self finishLoading];
        
        [userGroups addObjectsFromArray:userSearchResult.records];
        
        [self adjustHeight:userGroups.count];
        
        totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)userGroups.count];
        [listTableView reloadData];
        
    } onError:^(Response *error) {
        
        [self finishLoading];
        
        // 재시도 할것인지에 대한 팝업 띄워주기
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self getUserGroups];
            }
            else
            {
                [self closePopup:self parentViewController:self.parentViewController];
            }
        }];

    }];
    
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)adjustHeight:(NSInteger)count
{
    if (count < 4)
    {
        containerHeightConstraint.constant = LIST_SUB_POPUP_MINIMUM_HEIGHT;
    }
    [containerView setHidden:NO];
    [self showPopupAnimation:containerView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return userGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RadioCell" forIndexPath:indexPath];
    RadioCell *customCell = (RadioCell*)cell;
    
    UserGroup *userGroup = [userGroups objectAtIndex:indexPath.row];
   
    [customCell checkSelected:userGroup.isSelected];
    customCell.titleLabel.text = userGroup.name;
    
    return customCell;
}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (UserGroup *group in userGroups)
    {
        group.isSelected = NO;
    }
    selectedUserGroup = [userGroups objectAtIndex:indexPath.row];
    selectedUserGroup.isSelected = YES;
    
    
    selectedIndex = indexPath.row;
    isMenuSelected = YES;
    
    [tableView reloadData];
}
@end
