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
#import "ListSubInfoPopupViewController.h"
#import "ListPopupViewController.h"
#import "OneButtonPopupViewController.h"

@protocol MonitorFilterDelegate <NSObject>

@optional

- (void)searchEvent;
- (void)saveFilter;
@end

@interface MonitorFilterViewController : BaseViewController <DatePickerDelegate, TimePickerDelegate, EventProviderDelegate, ListSubInfoPopupDelegate, ListPopupViewControllerDelegate>
{
    __weak IBOutlet UITableView *filterTableView;
    
    NSString *eventDec;
    NSString *eventCount;
    NSString *deviceDec;
    NSString *deviceCount;
    NSString *userDec;
    NSString *userCount;
    EventProvider *eventProvider;
    
    BOOL isForDate;
}

@property (assign, nonatomic) id <MonitorFilterDelegate> delegate;
@property (strong, nonatomic) NSMutableDictionary *condition;


- (IBAction)moveToBack:(id)sender;
- (IBAction)searchEventByFilter:(id)sender;
- (NSDictionary *)getFilterConditions;
- (void)setDefaultValue;
- (IBAction)showDatePicker:(UIButton *)sender;
- (IBAction)showTimePicker:(UIButton *)sender;
- (IBAction)resetCondition:(id)sender;
// 피커뷰에서 선택된 날짜만 바꾸기
- (NSString*)stringFromChanging:(NSString*)origin targetDate:(NSString*)target;
// 피커뷰에서 선택된 시간만 바꾸기 
- (NSString*)stringFromChanging:(NSString*)origin targetTime:(NSString*)target;
- (void)setEventsContent:(NSArray *)events;
- (void)confirmFilterEvents:(NSArray*)events;
- (void)confirmFilterUsers:(NSArray*)users;
- (BOOL)verifyPeriod;
- (void)showVerificationPopup:(NSString*)message;
+ (void)filterReset;
+ (void)setResetFilter:(BOOL)neetToReset;
+ (void)setFilterDevices:(NSArray*)devices;
+ (void)setFilterUsers:(NSArray*)users;
@end
