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

#import "DatePickerPopupViewController.h"

@interface DatePickerPopupViewController ()

@end

@implementation DatePickerPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    datePicker.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    _isLocalTime = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [super popupViewDidAppear:contentView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)cancelDateFilter:(id)sender
{
    [self closePopup:self parentViewController:self.parentViewController];
}

- (IBAction)confirmDateFilter:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(confirmDateFilter:isStartDate:)])
    {
        [self.delegate confirmDateFilter:[datePicker.date debugDescription] isStartDate:_isStartDate];
    }
    
    [self closePopup:self parentViewController:self.parentViewController];
}

- (void)setDate:(NSDate*)date
{
    datePicker.date = date;
    if (_isLocalTime)
    {
        datePicker.timeZone = [NSTimeZone localTimeZone];
    }
    else
    {
        datePicker.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    }
    
}
@end
