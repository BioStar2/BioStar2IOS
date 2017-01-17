//
//  MobileCardHelpViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 10. 4..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "MobileCardHelpViewController.h"

@interface MobileCardHelpViewController ()

@end

@implementation MobileCardHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [continuouslyCloseButton setTitle:NSLocalizedString(@"donot_again", nil) forState:UIControlStateNormal];
    [contentView setBackgroundColor:[UIColor colorWithRed:88/255 green:80/255 blue:83/255 alpha:0.7]];
    
    if (IS_IPHONE_6_PLUS)
    {
        cellHeight = 900;
    }
    else if (IS_IPHONE_6)
    {
        cellHeight = 790;
    }
    else if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        cellHeight = 700;
    }
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

- (IBAction)closeHelpView:(id)sender
{
    [self closePopup:self parentViewController:self.parentViewController];
}

- (IBAction)closeHelpViewContinuously:(id)sender
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CardHelpCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardHelpCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    
    return cell;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}
@end
