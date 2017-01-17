//
//  WiegandFormatListPopupViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 19..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "WiegandFormatListPopupViewController.h"

@interface WiegandFormatListPopupViewController ()

@end

@implementation WiegandFormatListPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setSharedViewController:self];
    [containerView setHidden:YES];
    
    [cancelBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    
    cardProvider = [[CardProvider alloc] init];
    contentListArray = [[NSMutableArray alloc] init];
    [self getWiegandCardFormats];
    
    titleLabel.text = NSLocalizedString(@"smartcard_type", nil);
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


- (void)getModelResponseBlock:(WiegandPopupModelResponseBlock)modelResponseBlock;
{
    self.modelResponseBlock = modelResponseBlock;
}


- (void)adjustHeight:(NSInteger)count
{
    if (count < 4)
    {
        heightConstraint.constant = LIST_POPUP_MINIMUM_HEIGHT;
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
    if (nil != selectedFormat)
    {
        if (self.modelResponseBlock)
        {
            self.modelResponseBlock(selectedFormat);
            self.modelResponseBlock = nil;
        }
    }
    
    [self closePopup:self parentViewController:self.parentViewController];
}

- (void)getWiegandCardFormats
{
    [self startLoading:self];
    
    [cardProvider getWiegandFormat:^(WiegandFormatSearchResult *result) {
        [self finishLoading];
        
        [contentListArray addObjectsFromArray:result.records];
        
        [self adjustHeight:contentListArray.count];
        
        [contentTableView reloadData];
        
    } onError:^(Response *error) {
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        imagePopupCtrl.type = REQUEST_FAIL;
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self getWiegandCardFormats];
            }
            else
            {
                [self closePopup:self parentViewController:self.parentViewController];
            }
        }];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [contentListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RadioCell" forIndexPath:indexPath];
    RadioCell *customCell = (RadioCell*)cell;
    
    WiegandFormat *model = [contentListArray objectAtIndex:indexPath.row];
    [customCell checkSelected:model.isSelected];
    
    customCell.titleLabel.text = model.name;
    
    return customCell;
}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    selectedFormat = [contentListArray objectAtIndex:indexPath.row];
    
    NSInteger index = 0;
    
    for (WiegandFormat *model in contentListArray)
    {
        model.isSelected = NO;
        
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        index++;
        
    }
    
    selectedFormat.isSelected = YES;
    
    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

@end
