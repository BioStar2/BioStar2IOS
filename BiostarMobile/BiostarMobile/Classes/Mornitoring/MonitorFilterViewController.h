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
#import "DateCell.h"
#import "TimeCell.h"
#import "SingleSelectionCell.h"
#import "MultiSelectionCell.h"
#import "BaseViewController.h"
#import "SectionCell.h"
#import "DatePickerPopupViewController.h"
#import "TimePickerPopupViewController.h"
#import "EventProvider.h"
#import "ListPopupViewController.h"
#import "OneButtonPopupViewController.h"
#import "DevicePopupViewController.h"
#import "SelectModel.h"
#import "User.h"
#import "UserPopupViewController.h"
#import "EventPopupViewController.h"
#import "DoorPopupViewController.h"

@protocol MonitorFilterDelegate <NSObject>

@optional

- (void)searchEventByFilterController:(EventQuery*)filteredQuery withDoors:(NSArray<ListDoorItem*>*)filteredDoors;
- (void)saveFilter:(EventQuery*)filteredQuery;
@end

@interface MonitorFilterViewController : BaseViewController
{
    __weak IBOutlet UITableView *filterTableView;
    __weak IBOutlet UILabel *titleLabel;
    
    NSString *eventDec;
    NSString *eventCount;
    NSString *deviceDec;
    NSString *deviceCount;
    NSString *doorDec;
    NSString *doorCount;
    NSString *userDec;
    NSString *userCount;
    
    NSArray <ListDoorItem *> *selectedDoors;
    EventProvider *eventProvider;
    EventQuery *searchQuery;
    
}

@property (assign, nonatomic) id <MonitorFilterDelegate> delegate;

- (void)setSearchQuery:(EventQuery*)query;
- (void)showListDatePopup:(BOOL)isDate;
- (void)getEventMessage;
- (IBAction)moveToBack:(id)sender;
- (IBAction)searchEventByFilter:(id)sender;
- (void)setDefaultValue;
- (IBAction)showDatePicker:(UIButton *)sender;
- (IBAction)showTimePicker:(UIButton *)sender;
- (IBAction)resetCondition:(id)sender;
// 피커뷰에서 선택된 날짜만 바꾸기
- (NSString*)stringFromChanging:(NSString*)origin targetDate:(NSString*)target;
// 피커뷰에서 선택된 시간만 바꾸기 
- (NSString*)stringFromChanging:(NSString*)origin targetTime:(NSString*)target;
- (void)setEventsContent:(NSArray <EventType*> *)events;
- (void)setUserContent:(NSArray <User*> *)users;
- (void)setDeviceContent:(NSArray <SearchResultDevice*>*)devices;
- (void)setDoorContent:(NSArray <ListDoorItem*>*)doors;
- (BOOL)verifyPeriod;
- (BOOL)verifyStartDate:(NSString*)start withEndDate:(NSString*)end;
- (void)showVerificationPopup:(NSString*)message;
+ (void)filterReset;
+ (void)setResetFilter:(BOOL)neetToReset;
//+ (void)setFilterDevices:(NSArray<SearchResultDevice*>*)devices;
+ (void)setFilterUsers:(NSArray<User*>*)users;
@end
