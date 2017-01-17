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

#import "ListPopupViewController.h"


@interface ListPopupViewController ()

@end

@implementation ListPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setSharedViewController:self];
    [containerView setHidden:YES];
    
    contentListArray = [[NSMutableArray alloc] init];
    selectedIndex = NOT_SELECTED;
    
    [cancelBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    
    switch (_type)
    {
        case CARD_OPTION:
            titleLabel.text = NSLocalizedString(@"registeration_option", nil);
            break;
        case PEROID:
            titleLabel.text = NSLocalizedString(@"select_option", nil);
            break;
        case CARD_TYPE:
            titleLabel.text = NSLocalizedString(@"card_type", nil);
            break;
        case REGISTRATION_POPUP:
            titleLabel.text = NSLocalizedString(@"registeration_option", nil);
            break;
        case SMART_CARD_POPUP:
            titleLabel.text = NSLocalizedString(@"smartcard_type", nil);
            break;
        case WIGAND_CARD_POPUP:
            cardProvider = [[CardProvider alloc] init];
            [self getWiegandCardFormats];
            titleLabel.text = NSLocalizedString(@"smartcard_type", nil);
            break;
        case SCAN_METHOD:
            titleLabel.text = NSLocalizedString(@"rescan", nil);
            break;
    }
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


- (void)getIndexResponseBlock:(ListPopupIndexResponseBlock)responseBlock
{
    self.indexResponseBlock = responseBlock;
}

- (void)getModelResponseBlock:(ListPopupModelResponseBlock)responseBlock
{
    self.modelResponseBlock = responseBlock;
}

- (void)getCancelBlock:(ListPopupCancelBlock)cancelBlock
{
    self.cancelBlock = cancelBlock;
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

- (void)addOptions:(NSArray <NSString*> *)names
{
    for (NSString *name in names) {
        SelectModel *model = [SelectModel new];
        model.name = name;
        [contentListArray addObject:model];
    }
    
    [self adjustHeight:names.count];
    
    [contentTableView reloadData];
}


- (IBAction)cancelCurrentPopup:(id)sender
{
    if (self.cancelBlock)
    {
        self.cancelBlock();
        self.cancelBlock = nil;
    }
    
    [self closePopup:self parentViewController:self.parentViewController];
}


- (IBAction)confirmCurrentPopup:(id)sender
{
    if (selectedIndex != NOT_SELECTED)
    {
        if (self.indexResponseBlock)
        {
            self.indexResponseBlock(selectedIndex);
            self.indexResponseBlock = nil;
        }
        if (self.modelResponseBlock)
        {
            self.modelResponseBlock([contentListArray objectAtIndex:selectedIndex]);
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
        
        for (SimpleModel *format in result.records) {
            SelectModel *model = [SelectModel new];
            model.name = format.name;
            model.id = format.id;
            [contentListArray addObject:model];
        }
        
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
    
    SelectModel *model = [contentListArray objectAtIndex:indexPath.row];
    [customCell checkSelected:model.isSelected];
    
    customCell.titleLabel.text = model.name;
    
    return customCell;
}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    SelectModel *model = [contentListArray objectAtIndex:indexPath.row];
    
    NSInteger index = 0;
    
    for (SelectModel *model in contentListArray)
    {
        model.isSelected = NO;
        
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        index++;
        
    }
    
    model.isSelected = YES;
    selectedIndex = indexPath.row;
    
    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

@end
