//
//  UserGroupPopupViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 1..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "BaseViewController.h"
#import "RadioCell.h"
#import "UserProvider.h"
#import "ImagePopupViewController.h"

@interface UserGroupPopupViewController : BaseViewController
{
    __weak IBOutlet NSLayoutConstraint *containerHeightConstraint;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *totalCountLabel;
    __weak IBOutlet UITableView *listTableView;
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UIButton *confirmBtn;
    __weak IBOutlet UILabel *totalDecLabel;
    
    UserProvider *userProvider;
    
    NSMutableArray <UserGroup*> *userGroups;
    UserGroup *selectedUserGroup;
    NSInteger selectedIndex;
    BOOL isMenuSelected;
}

typedef void (^UserGroupSelectBlock)(UserGroup *userGroup);

@property (nonatomic, strong) UserGroupSelectBlock userGroupSelectBlock;

- (void)adjustHeight:(NSInteger)count;
- (void)getSelectedUserGroup:(UserGroupSelectBlock)userGroupSelectBlock;
- (void)getUserGroups;
@end
