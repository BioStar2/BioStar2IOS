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

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UserProvider.h"
#import "UserCell.h"
#import "NetworkController.h"
#import "UserNewDetailViewController.h"
#import "TextPopupViewController.h"
#import "ImagePopupViewController.h"
#import "UserGroupPopupViewController.h"
#import "PreferenceProvider.h"

@interface UsersViewController : BaseViewController <UserDetailDelegate>
{
    __weak IBOutlet UITableView *usersTableView;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UILabel *totalUserCount;
    __weak IBOutlet UILabel *selectedUserCount;
    __weak IBOutlet UIView *searchView;
    __weak IBOutlet UIView *selectView;
    __weak IBOutlet UIView *deleteInfoView;
    __weak IBOutlet UITextField *searchTextField;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIButton *scrollButton;
    __weak IBOutlet UIView *editButtonView;
    __weak IBOutlet UIButton *doneButton;
    __weak IBOutlet UIButton *addButton;
    __weak IBOutlet UIButton *deleteButton;
    __weak IBOutlet UILabel *totalDecLabel;
    
    NSInteger offset;
    NSInteger limit;
    NSInteger totalCount;
    BOOL isSelectedAllUser;
    BOOL isEditMode;
    BOOL isSearchMode;
    BOOL isForFilter;
    NSMutableArray <User*> *users;
    NSMutableArray *toDeleteUsers;
    NSString *query;
    NSString *groupID;
    UserProvider *provider;
    PreferenceProvider *preferenceProvoder;
    BOOL hasNextPage;
    BOOL canScrollTop;
    float firstYPosition;
    float secondYPosition;
    UserGroup *selectedUserGroup;

}

@property (weak, nonatomic) IBOutlet UITableView *tableView;


- (void)deleteSelectedUsers:(NSArray*)seletedUsers;
- (void)showImagePopup:(NSString*)title magePopupType:(ImagePopupType)type content:(NSString*)content;
- (IBAction)moveToBack:(id)sender;
- (IBAction)addUser:(id)sender;
- (IBAction)changeToDeleteMode:(id)sender;
- (IBAction)cancelSearch:(id)sender;
- (IBAction)showSearchView:(id)sender;
- (IBAction)scrollTopOrBottom:(id)sender;
- (IBAction)showUserGroupFilter:(id)sender;
- (IBAction)deleteUsers:(id)sender;
- (void)refreshUsers;
- (void)loadUserPhoto:(NSArray*)tempUsers;
@end
