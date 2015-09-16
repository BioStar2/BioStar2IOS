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
#import "RadioCell.h"
#import "UserProvider.h"
#import "DeviceProvider.h"
#import "AccessGroupProvider.h"
#import "PreferenceProvider.h"

@protocol ListSubInfoPopupDelegate <NSObject>

@optional

- (void)confirmServerList:(NSInteger)index;
- (void)confirmUserGroup:(NSDictionary*)userGroup;
- (void)confirmDoorControl:(NSInteger)index;
- (void)confirmTimezone:(NSInteger)index;
- (void)confirmTimeFormat:(NSDictionary*)dic;
- (void)confirmDateFormat:(NSDictionary*)dic;

- (void)confirmDeviceForFingerprint:(NSDictionary*)dic;
- (void)confirmDeviceForRegisterCard:(NSDictionary*)dic;
- (void)confirmCardInfo:(NSDictionary*)dic;
- (void)confirmCardsInfo:(NSMutableArray*)cardInfo;
- (void)confirmExchangeCard:(NSDictionary*)dic;
- (void)confirmExchangeAccessGroup:(NSDictionary *)dic;
- (void)confirmAddAccessGroup:(NSArray *)groups;
- (void)confirmFilterEvents:(NSArray*)events;
- (void)confirmFilterUsers:(NSArray*)users;
- (void)confirmFilterDevices:(NSArray*)devices;

- (void)cancelListSubInfoPopupWithError:(NSDictionary*)errDic;
@end

@interface ListSubInfoPopupViewController : BaseViewController <UserProviderDelegate, DeviceProviderDelegate, AccessGroupProviderDelegate>
{
    __weak IBOutlet NSLayoutConstraint *containerHeightConstraint;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *singleSelectTotalCountLabel;
    __weak IBOutlet UILabel *multiSelectTotalCountLabel;
    __weak IBOutlet UILabel *searchTotalCountLabel;
    __weak IBOutlet UITableView *listTableView;
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UIView *singleSelectView;
    __weak IBOutlet UIView *multiSelectView;
    __weak IBOutlet UIButton *multiSearchSelectAllButton;
    __weak IBOutlet UIView *multiSelectSearchView;
    __weak IBOutlet UIView *textView;
    __weak IBOutlet UITextField *searchTextField;
    __weak IBOutlet UIButton *singleSearchButton;
    __weak IBOutlet UIView *singleSearchView;
    __weak IBOutlet UITextField *singleSearchTextField;
    __weak IBOutlet UIView *contentView;
    
    NSMutableArray *contentListArray;
    NSMutableArray *selectedInfoArray;
    NSMutableArray *eventArray;
    UserProvider *userProvider;
    DeviceProvider *deviceProvider;
    AccessGroupProvider *accessProvider;
    NSMutableDictionary *contentDic;
    NSString *query;
    NSInteger offset;
    NSInteger limit;
    NSInteger totalCount;
    NSInteger selectedIndex;
    BOOL multiSelect;
    BOOL isSelectedAll;
    BOOL isSearchable;
    BOOL isForSearch;
    BOOL isForSingleSearch;
    BOOL hasNextPage;
}

@property (assign, nonatomic) id <ListSubInfoPopupDelegate> delegate;
@property (assign, nonatomic) ListType type;

- (IBAction)showSearchTextFieldView:(id)sender;
- (IBAction)showSingleSearchView:(id)sender;
- (IBAction)cancelSearch:(id)sender;
- (IBAction)cancelSingleSearch:(id)sender;
- (IBAction)selectAll:(id)sender;
- (void)adjustHeight:(NSInteger)count;
- (IBAction)cancelCurrentPopup:(id)sender;
- (IBAction)confirmCurrentPopup:(id)sender;
- (void)setContentList:(NSArray*)array;     // 모니터링 이벤트등 이미 데이터가 있을때 호출

@end
