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

#import "AlarmTimeTablePopupController.h"

@interface AlarmTimeTablePopupController ()

@end

@implementation AlarmTimeTablePopupController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [containerView setHidden:YES];
    titleLabel.text = NSLocalizedString(@"open_door_time_title", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [super popupViewDidAppear:contentView];
    [containerView setHidden:NO];
    [self showPopupAnimation:containerView];
}


- (IBAction)closePopup:(id)sender
{
    [self closePopup:self parentViewController:self.parentViewController];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _timeArray.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if (indexPath.row == 0)
    {
        height = 120;
    }
    else
    {
        height = 44;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
        
        return cell;
    }
    else
    {
        NotiTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotiTimeCell" forIndexPath:indexPath];
        
        NSDictionary *tempDic = [_timeArray objectAtIndex:indexPath.row - 1];
        NSDate *calculatedDate = [CommonUtil dateFromString:[tempDic objectForKey:@"datetime"] originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
        
        
        NSString *timeFormat;
        
        if ([[PreferenceProvider getTimeFormat] isEqualToString:@"hh:mm a"])
        {
            timeFormat = @"hh:mm:ss a";
        }
        else
        {
            timeFormat = [NSString stringWithFormat:@"%@ %@:ss",[PreferenceProvider getDateFormat], [PreferenceProvider getTimeFormat]];
        }
        
        NSString *content = [CommonUtil stringFromCurrentLocaleDateString:[calculatedDate description]
                                                         originDateFormat:@"YYYY-MM-dd HH:mm:ss z"
                                                          transDateFormat:[NSString stringWithFormat:@"%@ %@",
                                                                           [PreferenceProvider getDateFormat],
                                                                           timeFormat]];
        
        [cell setContent:content];
        return cell;
    }
    
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end
