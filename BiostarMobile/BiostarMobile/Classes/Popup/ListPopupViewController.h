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
#import "PermissionProvider.h"
#import "RadioCell.h"
#import "DeviceProvider.h"
#import "ImagePopupViewController.h"


@protocol ListPopupViewControllerDelegate <NSObject>

@optional

- (void)didSelectContent:(NSDictionary*)dic;

// 지문추가시 단말 선택 팝업에서 단말을 선택했을때 호출
- (void)didSelectCardOption:(NSInteger)optionIndex;
- (void)didSelectDateOption:(NSInteger)optionIndex;
- (void)didSelectCard:(NSDictionary*)cardInfo;

- (void)cancelListPopupWithError:(NSDictionary*)errDic;
@end


@interface ListPopupViewController :BaseViewController <UserProviderDelegate, PermissionProviderDelegate, DeviceProviderDelegate, ImagePopupDelegate>
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UITableView *contentTableView;
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet NSLayoutConstraint *heightConstraint;
    __weak IBOutlet UIView *contentView;
    
    UserProvider *userProvider;
    PermissionProvider *permissionProvider;
    DeviceProvider *deviceProvider;
    
    NSInteger selectedIndex;
    NSMutableDictionary *contentDic;
    NSMutableArray *contentListArray;
    NSInteger offset;
    NSInteger limit;
    NSString *query;
    
}

@property (assign, nonatomic) BOOL isRadioStyle;
@property (assign, nonatomic) ListType type;
@property (assign, nonatomic) id <ListPopupViewControllerDelegate>delegate;

- (IBAction)cancelCurrentPopup:(id)sender;
- (IBAction)confirmCurrentPopup:(id)sender;
- (void)addOptions:(NSArray*)options;
- (void)adjustHeight:(NSInteger)count;

@end
