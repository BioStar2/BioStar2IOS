//
//  LicenseViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2017. 3. 22..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import "LicenseViewController.h"

@interface LicenseViewController ()

@end

@implementation LicenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    titleLabel.text = NSBaseLocalizedString(@"License", nil);
    
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

- (IBAction)moveToBack:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NEED_TO_GET_MOBILE_CREDENTIAL object:nil];
    [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
}
@end
