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
#import "EventProvider.h"
#import "MonitoringCell.h"
#import "MonitoringExtraCell.h"
#import "DoorDetailViewController.h"
#import "DoorProvider.h"
#import "OneButtonTablePopupViewController.h"
#import "UserNewDetailViewController.h"
#import "MonitorFilterViewController.h"
#import "MonitoringSubExtraCell.h"
#import "ImagePopupViewController.h"
#import "EventQuery.h"
#import "SelectModel.h"

typedef enum{
    NONE_SELECT,
    SELECT_USER,
    SELECT_DEVICE,
    SELECT_BOTH,
    
} SelectType;

typedef enum{
    EVENT_USER,     // user 디테일에서 로그로 진입 했을때 
    EVENT_DOOR,     // Door 디테일에서 로그로 진입 했을때
    EVENT_MONITOR,  // 메뉴 버튼으로 진입 했을때
    
} RequestType;


@interface MonitoringViewController : BaseViewController <MonitorFilterDelegate>
{
    __weak IBOutlet UITableView *eventTableView;
    __weak IBOutlet UIButton *filterButton;
    __weak IBOutlet UIView *filterView;
    __weak IBOutlet UIButton *scrollButton;
    __weak IBOutlet UILabel *titleLabel;
    
    NSInteger totalCount;
    EventProvider *eventProvider;
    DoorProvider *doorProvider;
    NSMutableArray <EventLogResult *> *events;
    NSMutableArray <ListDoorItem *> *doors;
    MonitorFilterViewController *filterViewController;
    EventQuery *searchQuery;
    NSString *userID;
    NSInteger requestCount;
    BOOL hasNextPage;
    float firstYPosition;
    float secondYPosition;
    BOOL canScrollTop;
    BOOL canMoveToDetail;       // 사용자 디테일, 도어 디테일에서 이동했을때 무한뎁스 막기 위한 용도
}

@property (assign, nonatomic) RequestType requestType;

- (IBAction)moveToBack:(id)sender;
- (IBAction)showFilter:(id)sender;
- (IBAction)scrollTopOrBottom:(id)sender;
- (void)searchEvent:(EventQuery*)query;
//- (void)getDoors;
- (void)moveToDetail:(SelectType)currentType ID:(NSInteger)currentID event:(EventLogResult*)eventResult;
- (void)searchByFilter;
- (void)refreshEvents;
- (void)setUserCondition:(NSArray <NSString *> *)userIDs;  // 유저 디테일에서 뷰로그로 넘어 올때
- (void)setDeviceCondition:(NSArray <NSString *> *)deviceIDs; // 도어 디테일에서 뷰로그로 넘어 올때
- (void)setDefaultDateCondition;
- (NSUInteger)searchDoorIDByDeviceID:(NSString*)devicdID;
- (NSString*)searchDoorNameByDoorID:(NSUInteger)ID;
@end
