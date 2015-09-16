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

#import "NotiPopupController.h"

@interface NotiPopupController ()

@end

@implementation NotiPopupController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.notiDic)
    {
        if ([[[self.notiDic objectForKey:@"aps"] objectForKey:@"alert"] isKindOfClass:[NSDictionary class]])
        {
            if (nil != [[[self.notiDic objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"title"])
            {
                titleLabel.text = [[[self.notiDic objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"title"];
            }
            if ([[[self.notiDic objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"])
            {
                contentLabel.text = [[[self.notiDic objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"];
            }
        }
    }
    
    [containerView setHidden:YES];
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
    //[contentView setHidden:YES];
    [self showPopupAnimation:containerView];
}

- (IBAction)closePopup:(id)sender
{
    [self closePopup:self parentViewController:self.parentViewController];
}

- (IBAction)moveToAlarm:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MOVING_TO_ALARM object:nil];
    [self closePopup:self parentViewController:self.parentViewController];
}
@end
