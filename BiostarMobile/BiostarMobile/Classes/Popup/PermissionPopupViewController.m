//
//  PermissionPopupViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 7..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "PermissionPopupViewController.h"

@interface PermissionPopupViewController ()

@end

@implementation PermissionPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setSharedViewController:self];
    [containerView setHidden:YES];
    
    [cancelBtn setTitle:NSBaseLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSBaseLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    
    // 한글 일본어 일때 순서 바꾸기
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:language];
    NSString *languageCode = [languageDic objectForKey:@"kCFLocaleLanguageCodeKey"];
    
    if ([languageCode isEqualToString:@"ko"] || [languageCode isEqualToString:@"ja"])
    {
        titleLabel.text = [NSString stringWithFormat:@"%@ %@",NSBaseLocalizedString(@"operator", nil) ,NSBaseLocalizedString(@"select", nil)];
    }
    else
    {
        titleLabel.text = [NSString stringWithFormat:@"%@ %@",NSBaseLocalizedString(@"select", nil) ,NSBaseLocalizedString(@"operator", nil)];
    }
    
    permissionProvider = [[PermissionProvider alloc] init];
    permissions = [[NSMutableArray alloc] init];
    privileges = [[NSMutableArray alloc] init];
    
    if ([PreferenceProvider isUpperVersion])
    {
        [self getPrivileges];
    }
    else
    {
        [self getPermissions];
    }
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [super popupViewDidAppear:contentView];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)getPermissions
{
    [self startLoading:self];
    
    [permissionProvider getPermissions:^(RoleSearchResult *permissionResult) {
        [self finishLoading];
        
        CloudRole *nonRole = [CloudRole new];
        nonRole.code = @"NONE";
        nonRole.role_description = NSBaseLocalizedString(@"none", nil);
        nonRole.isSelected = NO;
        [permissions addObject:nonRole];
        
        [permissions addObjectsFromArray:permissionResult.records];
        
        [self adjustHeight:permissions.count];
        
        [contentTableView reloadData];
        
    } onError:^(Response *error) {
        [self finishLoading];
        
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
                [self getPermissions];
            }
            else
            {
                [self closePopup:self parentViewController:self.parentViewController];
            }
        }];
        
    }];
    
}

- (void)getPrivileges
{
    [self startLoading:self];
    
    [permissionProvider getPrivileges:^(PrivilegeSearchResult *permissionResult) {
        
        [self finishLoading];
        
        Permission *permission = [Permission new];
        permission.name = NSBaseLocalizedString(@"none", nil);
        permission.isSelected = NO;
        [privileges addObject:permission];
        
// 커스텀 권한일 경우 user 권한만 추가 할 수 있음
        User *loginUser = [AuthProvider getLoginUserInfo];
        if ([loginUser.permission.id isEqualToString:@"1"])
        {
            [privileges addObjectsFromArray:permissionResult.records];
        }
        else
        {
            for (Permission *permission in permissionResult.records)
            {
                if ([permission.id isEqualToString:@"255"]) {
                    [privileges addObject:permission];
                }
            }
        }
        
        
        [self adjustHeight:permissions.count];
        
        [contentTableView reloadData];
        
    } onError:^(Response *error) {
        
        [self finishLoading];
        
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
                [self getPrivileges];
            }
            else
            {
                [self closePopup:self parentViewController:self.parentViewController];
            }
        }];

        
    }];
    
    
}

- (void)getSelectedRoleBlock:(SelectedRoleBlock)selectedRoleBlock
{
    self.selectedRoleBlock = selectedRoleBlock;
}

- (void)getSelectedPermissionBlock:(SelectedPermissionBlock)selectedPermissionBlock
{
    self.selectedPermissionBlock = selectedPermissionBlock;
}


- (void)adjustHeight:(NSInteger)count
{
    if (count < 4)
    {
        heightConstraint.constant = LIST_POPUP_MINIMUM_HEIGHT;
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
    if ([PreferenceProvider isUpperVersion])
    {
        if (nil != selectedPermission)
        {
            if (self.selectedPermissionBlock)
            {
                self.selectedPermissionBlock(selectedPermission);
                self.selectedPermissionBlock = nil;
            }
        }
    }
    else
    {
        if (nil != selectedRole)
        {
            if (self.selectedRoleBlock)
            {
                self.selectedRoleBlock(selectedRole);
                self.selectedRoleBlock = nil;
            }
        }
    }
    
    [self closePopup:self parentViewController:self.parentViewController];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ([PreferenceProvider isUpperVersion])
    {
        return privileges.count;
    }
    else
    {
        return permissions.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RadioCell" forIndexPath:indexPath];
    RadioCell *customCell = (RadioCell*)cell;
    
    
    if ([PreferenceProvider isUpperVersion])
    {
        Permission *permission = [privileges objectAtIndex:indexPath.row];
        customCell.titleLabel.text = permission.name;
        [customCell checkSelected:permission.isSelected];
    }
    else
    {
        CloudRole *role = [permissions objectAtIndex:indexPath.row];
        customCell.titleLabel.text = role.role_description;
        [customCell checkSelected:role.isSelected];
    }
    
    
    return customCell;
}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([PreferenceProvider isUpperVersion])
    {
        selectedPermission = [privileges objectAtIndex:indexPath.row];
        
        for (Permission *permission in privileges)
        {
            permission.isSelected = NO;
        }
        
        selectedPermission.isSelected = YES;
    }
    else
    {
        selectedRole = [permissions objectAtIndex:indexPath.row];
        
        for (CloudRole *role in permissions)
        {
            role.isSelected = NO;
        }
        
        selectedRole.isSelected = YES;
    }
    
    
    
    [tableView reloadData];
    
}

@end
