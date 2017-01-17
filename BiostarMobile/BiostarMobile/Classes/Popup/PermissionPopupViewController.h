//
//  PermissionPopupViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 7..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "BaseViewController.h"
#import "PermissionProvider.h"
#import "RadioCell.h"
#import "ImagePopupViewController.h"
#import "PreferenceProvider.h"

@interface PermissionPopupViewController : BaseViewController
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UITableView *contentTableView;
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet NSLayoutConstraint *heightConstraint;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UIButton *confirmBtn;
    __weak IBOutlet UIView *contentView;
    
    PermissionProvider *permissionProvider;
    
    NSMutableArray <CloudRole *>*permissions;
    NSMutableArray <Permission *>*privileges;
    
    CloudRole *selectedRole;
    Permission *selectedPermission;
    
}


typedef void (^SelectedRoleBlock)(CloudRole *role);
typedef void (^SelectedPermissionBlock)(Permission *permission);



@property (nonatomic, strong) SelectedRoleBlock selectedRoleBlock;
@property (nonatomic, strong) SelectedPermissionBlock selectedPermissionBlock;


- (IBAction)cancelCurrentPopup:(id)sender;
- (IBAction)confirmCurrentPopup:(id)sender;
- (void)adjustHeight:(NSInteger)count;
- (void)getPermissions;
- (void)getPrivileges;
- (void)getSelectedRoleBlock:(SelectedRoleBlock)selectedRoleBlock;
- (void)getSelectedPermissionBlock:(SelectedPermissionBlock)selectedPermissionBlock;


@end
