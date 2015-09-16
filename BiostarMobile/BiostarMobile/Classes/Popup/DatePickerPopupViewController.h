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

@protocol DatePickerDelegate <NSObject>

- (void)confirmDateFilter:(NSString*)date isStartDate:(BOOL)isStartDate;

@end

@interface DatePickerPopupViewController : BaseViewController
{
    __weak IBOutlet UIDatePicker *datePicker;
    __weak IBOutlet UIView *contentView;
    
}

@property (assign, nonatomic) id <DatePickerDelegate> delegate;
@property (assign, nonatomic) BOOL isStartDate;
@property (assign, nonatomic) BOOL isLocalTime;

- (IBAction)cancelDateFilter:(id)sender;
- (IBAction)confirmDateFilter:(id)sender;
- (void)setDate:(NSDate*)date;
@end
