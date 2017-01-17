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

#import "QuickStartGuideViewController.h"

@interface QuickStartGuideViewController ()

@end

@implementation QuickStartGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)closeQuickGuide:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)showPrevGuide:(id)sender
{
    [closeButton setHidden:YES];
    [prevButton setHidden:YES];
    [nextButton setHidden:NO];
    guideImageView.image = [UIImage imageNamed:@"Screenshot_01"];
}

- (IBAction)showNextGuide:(id)sender
{
    [closeButton setHidden:NO];
    [prevButton setHidden:NO];
    [nextButton setHidden:YES];
    guideImageView.image = [UIImage imageNamed:@"Screenshot_02"];
}
@end
