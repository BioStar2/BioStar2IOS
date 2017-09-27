//
//  CardPopupViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 15..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "CardPopupViewController.h"

@interface CardPopupViewController ()

@end

@implementation CardPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self setSharedViewController:self];
    
    [cancelBtn setTitle:NSBaseLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSBaseLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    
    cards = [[NSMutableArray alloc] init];
    [containerView setHidden:YES];
    hasNextPage = NO;
    offset = 0;
    limit = 50;
    loadedItemCount = 0;
    isForSearch = NO;
    
    listTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    titleLabel.text = NSBaseLocalizedString(@"registeration_option_assign_card", nil);
    
    cardProvider = [[CardProvider alloc] init];
    if (deviceMode == CSN_CARD_MODE)
    {
        [self getCSNCards:nil limit:limit offset:offset];
    }
    else if (deviceMode == WIEGAND_CARD_MODE)
    {
        [self getWiegandCards:nil limit:limit offset:offset];
    }
    else if (deviceMode == SMART_CARD_MODE)
    {
        [self getSmartCards:nil limit:limit offset:offset];
    }
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [super popupViewDidAppear:contentView];
    
    if ([PreferenceProvider isUpperVersion])
    {
        tableViewTopConstraint.constant = - multiSelectSearchView.frame.size.height;
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

- (void)setCardType:(DeviceMode)type
{
    deviceMode = type;
}

- (void)getCSNCards:(NSString*)searchQuery limit:(NSInteger)searchLimit offset:(NSInteger)searchOffset
{
    [self startLoading:self];
    
    [cardProvider getCards:searchQuery limit:searchLimit offset:searchOffset resultBlock:^(CardSearchResult *result) {
        [self finishLoading];
        
        if (isForSearch)
        {
            isForSearch = NO;
            [cards removeAllObjects];
        }

        if (cards.count == 0)
        {
            [self adjustHeight:cards.count];
        }
        
        for (Card *card in result.records)
        {
            CardType type = [card.type cardTypeEnumFromString];
            if (type == CSN)
            {
                [cards addObject:card];
            }
        }
        
        

        [listTableView reloadData];
        
        loadedItemCount += result.records.count;
        if (result.total > loadedItemCount)
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
                [self getCSNCards:searchQuery limit:searchLimit offset:searchOffset];
            }
            else
            {
                [self closePopup:self parentViewController:self.parentViewController];
            }
        }];

    }];
    
}

- (void)getWiegandCards:(NSString*)searchQuery limit:(NSInteger)searchLimit offset:(NSInteger)searchOffset
{
    [self startLoading:self];
    
    [cardProvider getCards:searchQuery limit:searchLimit offset:searchOffset resultBlock:^(CardSearchResult *result) {
        [self finishLoading];
        
        if (isForSearch)
        {
            isForSearch = NO;
            [cards removeAllObjects];
        }
        
        if (cards.count == 0)
        {
            [self adjustHeight:cards.count];
        }
        
        for (Card *card in result.records)
        {
            CardType type = [card.type cardTypeEnumFromString];
            if (type == WIEGAND || type == CSN_WIEGAND)
            {
                [cards addObject:card];
            }
        }
        
        
        [listTableView reloadData];
        
        loadedItemCount += result.records.count;
        if (result.total > loadedItemCount)
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
                [self getWiegandCards:searchQuery limit:searchLimit offset:searchOffset];
            }
            else
            {
                [self closePopup:self parentViewController:self.parentViewController];
            }
        }];
        
    }];
    
}

- (void)getSmartCards:(NSString*)searchQuery limit:(NSInteger)searchLimit offset:(NSInteger)searchOffset
{
    [self startLoading:self];
    
    [cardProvider getCards:searchQuery limit:searchLimit offset:searchOffset resultBlock:^(CardSearchResult *result) {
        [self finishLoading];
        
        if (isForSearch)
        {
            isForSearch = NO;
            [cards removeAllObjects];
        }
        
        if (cards.count == 0)
        {
            [self adjustHeight:cards.count];
        }
        
        for (Card *card in result.records)
        {
            CardType type = [card.type cardTypeEnumFromString];
            if (!card.is_mobile_credential)
            {
                if (type == SECURE_CREDENTIAL || type == ACCESS_ON)
                {
                    [cards addObject:card];
                }
            }
            
        }
        
        [listTableView reloadData];
        
        loadedItemCount += result.records.count;
        if (result.total > loadedItemCount)
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
                [self getSmartCards:searchQuery limit:searchLimit offset:searchOffset];
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
        
        if (deviceMode == CSN_CARD_MODE)
        {
            [self getCSNCards:nil limit:limit offset:offset];
        }
        else if (deviceMode == WIEGAND_CARD_MODE)
        {
            [self getWiegandCards:nil limit:limit offset:offset];
        }
        else if (deviceMode == SMART_CARD_MODE)
        {
            [self getSmartCards:nil limit:limit offset:offset];
        }
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
    if (self.cardBlock && nil != selectedCard)
    {
        self.cardBlock(selectedCard);
        self.cardBlock = nil;
    }
    
    [self closePopup:self parentViewController:self.parentViewController];
}


- (void)getCardBlock:(CardBlock)cardBlock
{
    self.cardBlock = cardBlock;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return cards.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardRadioCell" forIndexPath:indexPath];
    CardRadioCell *customCell = (CardRadioCell*)cell;
    Card *card = [cards objectAtIndex:indexPath.row];
    
    
    [customCell setCardType:deviceMode card:card isSelected:card.isSelected];
    customCell.titleLabel.text = card.card_id;
    
    if (indexPath.row == cards.count -1)
    {
        if (hasNextPage)
        {
            if (deviceMode == CSN_CARD_MODE)
            {
                [self getCSNCards:query limit:limit offset:offset];
            }
            else if (deviceMode == WIEGAND_CARD_MODE)
            {
                [self getWiegandCards:query limit:limit offset:offset];
            }
            
        }
    }
    
    return customCell;
}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Card *currentCard = [cards objectAtIndex:indexPath.row];
    
    
    for (Card *card in cards)
    {
        card.isSelected = NO;
    }
    
    currentCard.isSelected = YES;
    
    selectedCard = currentCard;
    
    searchTotalCountLabel.text = [NSString stringWithFormat:@"1 / %ld", (long)cards.count];
    
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
        
        if (deviceMode == CSN_CARD_MODE)
        {
            [self getCSNCards:query limit:limit offset:offset];
        }
        else if (deviceMode == WIEGAND_CARD_MODE)
        {
            [self getWiegandCards:query limit:limit offset:offset];
        }
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
