//
//  LayoutPopupViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 16..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "LayoutPopupViewController.h"

@interface LayoutPopupViewController ()

@end

@implementation LayoutPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self setSharedViewController:self];
    
    [cancelBtn setTitle:NSBaseLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSBaseLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    
    cardLayouts = [[NSMutableArray alloc] init];
    [containerView setHidden:YES];
    hasNextPage = NO;
    offset = 0;
    limit = 50;
    isForSearch = NO;
    
    listTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    titleLabel.text = NSBaseLocalizedString(@"card_layout_format", nil);
    
    cardProvider = [[CardProvider alloc] init];
    [self getCardLayouts:nil limit:limit offset:offset];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [super popupViewDidAppear:contentView];
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

- (void)getCardLayouts:(NSString*)searchQuery limit:(NSInteger)searchLimit offset:(NSInteger)searchOffset
{
    [self startLoading:self];
    
    [cardProvider getSmartCardLayouts:searchQuery limit:searchLimit offset:searchOffset resultBlock:^(CardLayoutSearchResult *result) {
        
        [self finishLoading];
        
        if (isForSearch)
        {
            isForSearch = NO;
            [cardLayouts removeAllObjects];
        }
        [self adjustHeight:result.records.count];
        
        [cardLayouts addObjectsFromArray:result.records];
        
        [listTableView reloadData];
        
        if (result.total > cardLayouts.count)
        {
            hasNextPage = YES;
            offset += limit;
        }
        else
        {
            hasNextPage = NO;
        }
        
        searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld", (long)result.total];
        
    } onError:^(Response *error) {
        
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            
            if (isConfirm)
            {
                [self getCardLayouts:searchQuery limit:searchLimit offset:searchOffset];
            }
            else
            {
                [self closePopup:self parentViewController:self.parentViewController];
            }
        }];
        
    }];
}



- (IBAction)showSearchTextFieldView:(id)sender
{
    [textView setHidden:NO];
    [searchTextField becomeFirstResponder];
}



- (IBAction)cancelSearch:(id)sender
{
    [self.view endEditing:YES];
    [textView setHidden:YES];
    
    if ((nil == query || [query isEqualToString:@""]) && didSearch)
    {
        didSearch = NO;
        offset = 0;
        limit = 50;
        query = nil;
        
        [self getCardLayouts:nil limit:limit offset:offset];
    }
}





- (void)adjustHeight:(NSInteger)count
{
    if (count < 4)
    {
        containerHeightConstraint.constant = LIST_SUB_POPUP_MINIMUM_HEIGHT;
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
    
    if (self.layoutBlock && nil != selectedCardLayout)
    {
        self.layoutBlock(selectedCardLayout);
        self.layoutBlock = nil;
    }
    
    [self closePopup:self parentViewController:self.parentViewController];
}


- (void)getCardLayoutBlock:(LayoutBlock)layoutBlock
{
    self.layoutBlock = layoutBlock;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return cardLayouts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RadioCell" forIndexPath:indexPath];
    RadioCell *customCell = (RadioCell*)cell;
    SimpleModel *cardLayout = [cardLayouts objectAtIndex:indexPath.row];
    
    [customCell checkSelected:cardLayout.isSelected];
    customCell.titleLabel.text = cardLayout.name;
    
    if (indexPath.row == cardLayouts.count -1)
    {
        if (hasNextPage)
        {
            [self getCardLayouts:query limit:limit offset:offset];
        }
    }
    
    return customCell;
}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (Card *card in cardLayouts)
    {
        card.isSelected = NO;
    }
    SmartCardLayout *cardLayout = [cardLayouts objectAtIndex:indexPath.row];
    cardLayout.isSelected = YES;
    
    selectedCardLayout = [cardLayouts objectAtIndex:indexPath.row];
    
    searchTotalCountLabel.text = [NSString stringWithFormat:@"1 / %ld", (long)cardLayouts.count];
    
    [tableView reloadData];
}



#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""])
    {
        query = textField.text;
        offset = 0;
        isForSearch = YES;
        [self getCardLayouts:query limit:limit offset:offset];
        didSearch = YES;
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    query = @"";
    return YES;
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString *content = [[NSMutableString alloc] initWithString:textField.text];
    
    if (![string isEqualToString:@""])
    {
        // append
        @try {
            [content insertString:string atIndex:range.location];
        } @catch (NSException *exception) {
            NSLog(@"%@ \n %@", exception.description, content);
        }
    }
    else
    {
        //delete
        @try {
            [content deleteCharactersInRange:range];
        } @catch (NSException *exception) {
            NSLog(@"%@ \n %@", exception.description, content);
        }
    }
    
    query = content;
    return YES;
}

@end
