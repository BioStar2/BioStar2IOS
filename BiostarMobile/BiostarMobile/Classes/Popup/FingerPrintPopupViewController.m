//
//  FingerPrintPopupViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 29..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "FingerPrintPopupViewController.h"

@interface FingerPrintPopupViewController ()

@end

@implementation FingerPrintPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setSharedViewController:self];
    [containerView setHidden:YES];
    fingerprintIndexs = [[NSMutableArray alloc] init];
    titleLabel.text = NSBaseLocalizedString(@"fingerprint", nil);
    totalDecLabel.text = NSBaseLocalizedString(@"total", nil);
    [cancelBtn setTitle:NSBaseLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSBaseLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)templates.count];
    
    [self adjustHeight:templates.count];
    isLimited = NO;
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


- (void)setFingerprintTeaplatesCount:(NSInteger)count maxFingerprintCount:(NSInteger)maxFingerprintCount
{
    maxCount = maxFingerprintCount;
    templates = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < count; i++)
    {
        SimpleModel *model = [SimpleModel new];
        model.isSelected = NO;
        [templates addObject:model];
    }
}

- (void)getSelectedIndexsBlock:(SelectedIndexsBlock)selectedIndexsBlock
{
    self.selectedIndexsBlock = selectedIndexsBlock;
}

- (void)adjustHeight:(NSInteger)count
{
    if (count < 4)
    {
        containerHeightConstraint.constant = LIST_POPUP_MINIMUM_HEIGHT;
    }
    
    [containerView setHidden:NO];
    [self showPopupAnimation:containerView];
}

- (IBAction)cancelCurrentPopup:(id)sender
{
    [self closePopup:self parentViewController:self.parentViewController];
}



- (IBAction)confirmCurrentPopup:(id)sender
{
    if (self.selectedIndexsBlock)
    {
        self.selectedIndexsBlock(fingerprintIndexs);
        self.selectedIndexsBlock = nil;
    }
    
    [self closePopup:self parentViewController:self.parentViewController];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return templates.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RadioCell" forIndexPath:indexPath];
    RadioCell *customCell = (RadioCell*)cell;
    
    SimpleModel *model = [templates objectAtIndex:indexPath.row];
    
    
    NSInteger value = indexPath.row + 1;
    NSString *description;
    
    if (value == 1)
        description = [NSString stringWithFormat:@"%ld%@ %@",(long)value ,NSBaseLocalizedString(@"st", nil) ,NSBaseLocalizedString(@"fingerprint", nil)];
    else if (value == 2)
        description = [NSString stringWithFormat:@"%ld%@ %@",(long)value ,NSBaseLocalizedString(@"nd", nil) ,NSBaseLocalizedString(@"fingerprint", nil)];
    else if (value == 3)
        description = [NSString stringWithFormat:@"%ld%@ %@",(long)value ,NSBaseLocalizedString(@"rd", nil) ,NSBaseLocalizedString(@"fingerprint", nil)];
    else
        description = [NSString stringWithFormat:@"%ld%@ %@",(long)value ,NSBaseLocalizedString(@"th", nil) ,NSBaseLocalizedString(@"fingerprint", nil)];
    
    customCell.titleLabel.text = description;
    [customCell checkSelected:model.isSelected isLimited:isLimited];
    return customCell;
}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimpleModel *model = [templates objectAtIndex:indexPath.row];
    model.isSelected = !model.isSelected;
    
    if (model.isSelected)
    {
        if (fingerprintIndexs.count < maxCount)
        {
            [fingerprintIndexs addObject:[NSNumber numberWithInteger:indexPath.row]];
            if (fingerprintIndexs.count == maxCount)
            {
                isLimited = YES;
            }
            else
            {
                isLimited = NO;
            }
            
        }
        else
        {
            model.isSelected = NO;
            isLimited = YES;
        }
    }
    else
    {
        NSNumber *index = [NSNumber numberWithInteger:indexPath.row];
        [fingerprintIndexs removeObject:index];
        isLimited = NO;
    }
    
    searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld/%ld",(unsigned long)fingerprintIndexs.count ,(unsigned long)templates.count];
    
    [tableView reloadData];
    
}

@end
