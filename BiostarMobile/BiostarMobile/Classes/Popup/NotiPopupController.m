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
    
    [cancelBtn setTitle:NSBaseLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSBaseLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    
    if (self.notiDic)
    {
        
        if ([[[self.notiDic objectForKey:@"aps"] objectForKey:@"alert"] isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *alert = [[self.notiDic objectForKey:@"aps"] objectForKey:@"alert"];
            
            titleLabel.text = NSBaseLocalizedString([alert objectForKey:@"title-loc-key"], nil);
            
            NSArray *args = [alert objectForKey:@"loc-args"];
            
            if (nil != args)
            {
                NSRange range = NSMakeRange(0, [args count]);
                NSMutableData* data = [NSMutableData dataWithLength: sizeof(id) * [args count]];
                [args getObjects: (__unsafe_unretained id *)data.mutableBytes range:range];
                
                NSString *content = [[NSString alloc] initWithFormat:NSBaseLocalizedString([alert objectForKey:@"loc-key"], nil) arguments:data.mutableBytes];
                contentTextView.text = content;
            }
            else
            {
                contentTextView.text = NSBaseLocalizedString([alert objectForKey:@"loc-key"], nil);
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
