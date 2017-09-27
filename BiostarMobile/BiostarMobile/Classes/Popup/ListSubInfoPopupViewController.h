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
#import "DeviceProvider.h"
#import "ImagePopupViewController.h"

@interface ListSubInfoPopupViewController : BaseViewController
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
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UIButton *confirmBtn;
    __weak IBOutlet UILabel *totalDecLabel;
    
    
    NSMutableArray *contentListArray;
    NSMutableArray *selectedInfoArray;
    NSMutableArray *eventArray;
    NSMutableArray *verificationInfo;
    DeviceProvider *deviceProvider;
    NSMutableDictionary *contentDic;
    NSString *query;
    NSInteger offset;
    NSInteger limit;
    NSInteger totalCount;
    NSInteger limitCount;
    NSInteger selectedIndex;
    BOOL multiSelect;
    BOOL isSelectedAll;
    BOOL isSearchable;
    BOOL isForSearch;
    BOOL isForSingleSearch; // 검색 가능하나 멀티셀렉트 안됨
    BOOL hasNextPage;
    BOOL isLimited;
}

typedef void (^ListSubInfoPopupDictionaryResponseBlock)(NSDictionary *dictionary);
typedef void (^ListSubInfoPopupArrayResponseBlock)(NSArray *array);
typedef void (^ListSubInfoPopupIndexResponseBlock)(NSInteger index);


@property (assign, nonatomic) ListPopupType type;
@property (nonatomic, strong) ListSubInfoPopupDictionaryResponseBlock dictionaryResponseBlock;
@property (nonatomic, strong) ListSubInfoPopupArrayResponseBlock arrayResponseBlock;
@property (nonatomic, strong) ListSubInfoPopupIndexResponseBlock indexResponseBlock;


- (void)getDictionaryResponse:(ListSubInfoPopupDictionaryResponseBlock)dictionaryResponseBlock;

- (void)getArrayResponse:(ListSubInfoPopupArrayResponseBlock)arrayResponseBlock;

- (void)getIndexResponse:(ListSubInfoPopupIndexResponseBlock)indexResponseBlock;


- (void)getCards:(NSString*)searchQuery limit:(NSInteger)searchLimit offset:(NSInteger)searchOffset;

- (IBAction)showSearchTextFieldView:(id)sender;

- (IBAction)showSingleSearchView:(id)sender;

- (IBAction)cancelSearch:(id)sender;

- (IBAction)cancelSingleSearch:(id)sender;

- (IBAction)selectAll:(id)sender;

- (void)adjustHeight:(NSInteger)count;

- (IBAction)cancelCurrentPopup:(id)sender;

- (IBAction)confirmCurrentPopup:(id)sender;

- (void)setContentList:(NSArray*)array;     // 모니터링 이벤트등 이미 데이터가 있을때 호출

- (void)setVerificationInfo:(NSArray*)info;

- (void)addContent:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;

@end
