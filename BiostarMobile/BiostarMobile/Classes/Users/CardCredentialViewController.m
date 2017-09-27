//
//  CardCredentialViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 16..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "CardCredentialViewController.h"

@interface CardCredentialViewController ()

- (void)checkAllSelected:(NSInteger)allCount selectedCount:(NSInteger)selectedCount;

@end

@implementation CardCredentialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setSharedViewController:self];
    isCardChanged = NO;
    toDeleteArray = [[NSMutableArray alloc] init];
    isSelectedAll = NO;
    isForSwitchIndex = NO;
    isDeleteMode = NO;
    
    totalDecLabel.text = NSBaseLocalizedString(@"total", nil);;
    selectTotalDecLabel.text = NSBaseLocalizedString(@"total", nil);;
    titleLabel.text = NSBaseLocalizedString(@"card", nil);
    
    if (_isProfileMode)
    {
        [editButtonView setHidden:YES];
        [doneButtonView setHidden:YES];
    }
    
    cardProvider = [[CardProvider alloc] init];
    userProvier = [[UserProvider alloc] init];
    
    if (nil == userCards)
    {
        userCards = [[NSMutableArray alloc] init];
    }
    if (nil == cellHeights)
        cellHeights = [[NSMutableArray alloc] init];
    
    if (!self.isProfileMode)
    {
        [self getUserCards];
    }
    else
    {
        totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)userCards.count];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
//    if (isCardChanged)
//    {
//        if ([self.delegate respondsToSelector:@selector(cardDidChanged)])
//        {
//            [self.delegate cardDidChanged];
//        }
//    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */




- (void)setUserVeryfications:(User*)user;
{
    currentUser = user;
    if (self.isProfileMode)
    {
        if (nil == userCards)
        {
            userCards = [[NSMutableArray alloc] initWithArray:currentUser.cards];
            cellHeights = [[NSMutableArray alloc] init];
            for (int i = 0; i < userCards.count; i++)
            {
                [cellHeights addObject:[NSNumber numberWithFloat:77]];
            }
        }
    }
    
    fingerPrintTemplates = [[NSMutableArray alloc] initWithArray:user.fingerprint_templates];
}

- (void)getUserCards
{
    [cellHeights removeAllObjects];
    
    [self startLoading:self];
    
    [userProvier getUserCards:currentUser.user_id responseBlock:^(UserCardList *result) {
        
        [self finishLoading];
        
        [userCards removeAllObjects];
        
        [userCards addObjectsFromArray:result.card_list];
        
        for (int i = 0; i < result.card_list.count; i++)
        {
            [cellHeights addObject:[NSNumber numberWithFloat:77]];
        }
        
        if ([self.delegate respondsToSelector:@selector(cardDidChanged:)])
        {
            [self.delegate cardDidChanged:userCards];
        }
        
        totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)userCards.count];
        [contentTableView reloadData];
        
    } onErrorBlock:^(Response *error) {
        
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        imagePopupCtrl.type = MAIN_REQUEST_FAIL;
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self getUserCards];
            }
            else
            {
                [self moveToBack:nil];
            }
            
        }];
    }];
    
    
}

- (IBAction)addVerification:(id)sender
{
    if ([userCards count] >= 8)
    {
        // 8 개 초과 등록 안됨
        [self.view makeToast:NSBaseLocalizedString(@"max_size", nil)
                    duration:2.0
                    position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_03"]];
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CardAddViewController *cardAddViewController = [storyboard instantiateViewControllerWithIdentifier:@"CardAddViewController"];
    [cardAddViewController setUserVeryfications:currentUser userCards:userCards];
    cardAddViewController.delegate = self;
    [self pushChildViewController:cardAddViewController parentViewController:self contentView:self.view animated:YES];
}

- (IBAction)moveToBack:(id)sender
{
    if (isDeleteMode)
    {
        mobileCard = nil;
        isDeleteMode = NO;
        for (Card *info in userCards)
        {
            info.isSelected = NO;
            
        }
        totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)userCards.count];
        totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)userCards.count];
        
        [toDeleteArray removeAllObjects];
        
        [selectAllButton setImage:[UIImage imageNamed:@"check_box_blank"] forState:UIControlStateNormal];
        [contentTableView reloadData];
        isSelectedAll = NO;
        
        [editButtonView setHidden:NO];
        [doneButtonView setHidden:YES];
        [totalCountView setHidden:NO];
        [verificationSelectView setHidden:YES];
        
        return;
    }
    [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
}

- (IBAction)deleteVerification:(id)sender
{
    isDeleteMode = YES;
    titleLabel.text = NSBaseLocalizedString(@"delete_card", nil);
    totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)userCards.count];
    
    [editButtonView setHidden:YES];
    [doneButtonView setHidden:NO];
    [totalCountView setHidden:YES];
    [verificationSelectView setHidden:NO];
    [contentTableView reloadData];
}

- (IBAction)done:(id)sender
{
    if (toDeleteArray.count > 0)
    {
        // delete popup display
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = WARNING;
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"delete_confirm_question", nil);
        [imagePopupCtrl setContent:[NSString stringWithFormat:@"%@ %ld", NSBaseLocalizedString(@"selected_count", nil), (unsigned long)toDeleteArray.count]];
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            
            if (isConfirm)
            {
                [self checkToBeDeletedCard];
            }
        }];
        
    }
    else
    {
        [self.view makeToast:NSBaseLocalizedString(@"selected_none", nil)
                    duration:2.0
                    position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_03"]];
    }
}

- (void)checkToBeDeletedCard
{
    if (mobileCard)
    {
        [self deleteMobileCard];
    }
    else
    {
        [self updateUserCards];
    }
}

- (void)deleteMobileCard
{
    [self startLoading:self];
    
    [cardProvider deleteMobileCredential:mobileCard.id resultBlock:^(Response *response) {
        
        [self finishLoading];
        
        [userCards removeObject:mobileCard];
        [toDeleteArray removeObject:mobileCard];
        
        if (toDeleteArray.count > 0)
        {
            [self updateUserCards];
        }
        else
        {
            isCardChanged = YES;
            
            [contentTableView reloadData];
            
            totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)userCards.count];
            
            if ([self.delegate respondsToSelector:@selector(cardDidChanged:)])
            {
                [self.delegate cardDidChanged:userCards];
            }
        }
        
    } onError:^(Response *error) {
        
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        imagePopupCtrl.type = REQUEST_FAIL;
        [imagePopupCtrl setContent:error.message];
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            
            if (isConfirm)
            {
                [self deleteMobileCard];
            }
            
        }];
        
    }];
}

- (void)updateUserCards
{
    
    [self startLoading:self];
    CardList *cardList = [CardList new];
    
    NSMutableArray <SimpleCard*> *updateCardList = [[NSMutableArray alloc] init];
    
    NSMutableArray <Card*> *originCardList = [[NSMutableArray alloc] initWithArray:userCards];
    
    [originCardList removeObjectsInArray:toDeleteArray];
    
    for (Card* card in originCardList)
    {
        SimpleCard *targetCard = [[SimpleCard alloc] initWithID:card.id cardID:card.card_id];
        [updateCardList addObject:targetCard];
    }
    
    cardList.card_list = updateCardList;
    
    [userProvier updateUserCard:cardList userID:currentUser.user_id responseBlock:^(Response *response) {
        
        [self finishLoading];
        [userCards removeObjectsInArray:toDeleteArray];
        
        isCardChanged = YES;
        
        [toDeleteArray removeAllObjects];
        [contentTableView reloadData];
        
        totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)userCards.count];
        
        if ([self.delegate respondsToSelector:@selector(cardDidChanged:)])
        {
            [self.delegate cardDidChanged:userCards];
        }
        
    } onErrorBlock:^(Response *error) {
        
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        imagePopupCtrl.type = REQUEST_FAIL;
        [imagePopupCtrl setContent:error.message];
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            
            if (isConfirm)
            {
                [self updateUserCards];
            }
            
        }];
        
    }];
    
}


- (void)blockCurrentCard:(Card*)card
{
    [self startLoading:self];
    
    [cardProvider blockCard:card.id resultBlock:^(Response *response) {
        [self finishLoading];
        
        card.is_blocked = YES;
        [contentTableView reloadData];
        
    } onError:^(Response *error) {
        [self finishLoading];
        
        card.is_blocked = NO;
        [contentTableView reloadData];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        imagePopupCtrl.type = REQUEST_FAIL;
        [imagePopupCtrl setContent:error.message];
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            
            if (isConfirm)
            {
                [self blockCurrentCard:card];
            }
            
        }];
    }];
}

- (void)releaseCurrentCard:(Card*)card
{
    [self startLoading:self];
    
    [cardProvider unblockCard:card.id resultBlock:^(Response *response) {
        [self finishLoading];
        
        card.is_blocked = NO;
        [contentTableView reloadData];
        
    } onError:^(Response *error) {
        [self finishLoading];
        
        card.is_blocked = YES;
        [contentTableView reloadData];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        imagePopupCtrl.type = REQUEST_FAIL;
        [imagePopupCtrl setContent:error.message];
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            
            if (isConfirm)
            {
                [self releaseCurrentCard:card];
            }
            
        }];
    }];
}

- (void)reissueMobileCard:(Card*)card
{
    [self startLoading:self];
    
    [userProvier reissueUserMobileCredential:currentUser.user_id cardRecordID:card.id responseBlock:^(AddResponse *response) {
        
        [self finishLoading];
        
        [self getUserCards];
        
    } onErrorBlock:^(Response *error) {
        
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        imagePopupCtrl.type = REQUEST_FAIL;
        [imagePopupCtrl setContent:error.message];
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            
            if (isConfirm)
            {
                [self reissueMobileCard:card];
            }
            
        }];
        
    }];
    
    
}

- (IBAction)selectAll:(UIButton *)sender
{
    [toDeleteArray removeAllObjects];
    
    if (!isSelectedAll)
    {
        for (Card *card in userCards)
        {
            if ([card.type cardTypeEnumFromString] == ACCESS_ON)
            {
                if (!card.is_blocked)
                {
                    [self.view makeToast:NSBaseLocalizedString(@"non_blocked", nil)
                                duration:1.0 position:CSToastPositionBottom
                                   image:[UIImage imageNamed:@"toast_popup_i_03"]];
                    continue;
                }
                card.isSelected = YES;
                [toDeleteArray addObject:card];
            }
            else
            {
                card.isSelected = YES;
                [toDeleteArray addObject:card];
            }
            
        }
        totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)userCards.count];
        [sender setImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
    }
    else
    {
        for (Card *card in userCards)
        {
            card.isSelected = NO;
        }
        totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)userCards.count];
        
        
        [sender setImage:[UIImage imageNamed:@"check_box_blank"] forState:UIControlStateNormal];
    }
    
    [contentTableView reloadData];
    isSelectedAll = !isSelectedAll;
    
}


- (void)checkAllSelected:(NSInteger)allCount selectedCount:(NSInteger)selectedCount
{
    if (allCount == selectedCount)
    {
        isSelectedAll = YES;
        [selectAllButton setImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
    }
    else
    {
        NSUInteger unBlockedCount = 0;
        for (Card *card in userCards)
        {
            CardType cardType = [card.type cardTypeEnumFromString];
            if (cardType == ACCESS_ON)
            {
                if (!card.is_blocked)
                {
                    unBlockedCount++;
                }
            }
        }
        
        if (allCount - selectedCount == unBlockedCount)
        {
            isSelectedAll = YES;
            [selectAllButton setImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
        }
        else
        {
            isSelectedAll = NO;
            [selectAllButton setImage:[UIImage imageNamed:@"check_box_blank"] forState:UIControlStateNormal];
        }
        
        
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [userCards count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    CGFloat cellHeight = [[cellHeights objectAtIndex:indexPath.row] floatValue];
    if (cellHeight < 20)
    {
        return 77;
    }
    CGFloat height = 77 + cellHeight;
    
    return height;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Card *card = [userCards objectAtIndex:indexPath.row];
    if (card.is_mobile_credential)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MobileCredentialCell" forIndexPath:indexPath];
        MobileCredentialCell *customCell = (MobileCredentialCell*)cell;
        customCell.delegate = self;
        [customCell setContent:card mode:isDeleteMode viewMode:self.isProfileMode];
        //NSLog(@"mobile : %f", [customCell getIDLabelHeight]);
        
        [cellHeights replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithFloat:[customCell getIDLabelHeight]]];
        return customCell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardCredentialCell" forIndexPath:indexPath];
        CardCredentialCell *customCell = (CardCredentialCell*)cell;
        customCell.delegate = self;
        [customCell setContent:card mode:isDeleteMode viewMode:self.isProfileMode];
        //NSLog(@"card : %f", [customCell getIDLabelHeight]);
        [cellHeights replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithFloat:[customCell getIDLabelHeight]]];
        return customCell;
    }

}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isProfileMode)
    {
        return;
    }
    if (isDeleteMode)
    {
        // 카드 삭제 모드
        Card *card = [userCards objectAtIndex:indexPath.row];
        
        CardType cardType = [card.type cardTypeEnumFromString];
        if (cardType == ACCESS_ON)
        {
            if (!card.is_blocked)
            {
                [self.view makeToast:NSBaseLocalizedString(@"non_blocked", nil)
                            duration:1.0 position:CSToastPositionBottom
                               image:[UIImage imageNamed:@"toast_popup_i_03"]];
                return;
            }
        }
        
        card.isSelected = !card.isSelected;
        if (card.isSelected)
        {
            if (card.is_mobile_credential)
            {
                mobileCard = card;
            }
            [toDeleteArray addObject:card];
        }
        else
        {
            if (card.is_mobile_credential)
            {
                mobileCard = nil;
            }
            [toDeleteArray removeObject:card];
        }
        
        [self checkAllSelected:userCards.count selectedCount:toDeleteArray.count];
        
        totalCount.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)toDeleteArray.count, (unsigned long)userCards.count];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Cell Delegate methods

- (void)blockCard:(UITableViewCell*)cell
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.type = CARD_BLOCK;
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
    
    [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
        
        if (isConfirm)
        {
            NSIndexPath *indexPath = [contentTableView indexPathForCell:cell];
            Card *card = [userCards objectAtIndex:indexPath.row];
            
            [self blockCurrentCard:card];
        }
        else
        {
            [contentTableView reloadData];
        }
    }];
}

- (void)releaseCard:(UITableViewCell*)cell
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.type = CARD_RELEASE;
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
    
    [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
        
        if (isConfirm)
        {
            NSIndexPath *indexPath = [contentTableView indexPathForCell:cell];
            Card *card = [userCards objectAtIndex:indexPath.row];
            
            [self releaseCurrentCard:card];
        }
        else
        {
            [contentTableView reloadData];
        }
    }];
    
}

- (void)requestReregisterMobileCard:(Card*)card
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.type = CARD_REREGISTER;
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
    
    [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
        
        if (isConfirm)
        {
            [self reissueMobileCard:card];
        }
    }];
}

#pragma mark - CardAddViewControllerDelegate

- (void)addedCard:(Card*)card
{
    //[userCards addObject:card];
    
//    if ([self.delegate respondsToSelector:@selector(cardDidChanged:)])
//    {
//        [self.delegate cardDidChanged:userCards];
//    }
    isCardChanged = YES;
    [self getUserCards];
}

@end
