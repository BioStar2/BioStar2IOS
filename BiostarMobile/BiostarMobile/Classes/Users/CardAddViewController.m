//
//  CardAddViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 4..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "CardAddViewController.h"

@interface CardAddViewController ()

- (IBAction)moveToBack:(id)sender;
- (IBAction)saveCard:(id)sender;

@end

@implementation CardAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setSharedViewController:self];
    
    titleLabel.text = NSLocalizedString(@"register_card", nil);
    
    WIEGANDFormat = [WiegandFormat new];
    wiegandCard = [WiegandCard new];
    mobileCredential = [MobileCredential new];
    mobileCredential.type = SECURE;
    
    secureCredential = [SecureCredential new];
    secureCredential.user_id = currentUser.user_id;
    
    accessOnCredential = [AccessOnCredential new];
    accessOnCredential.user_id = currentUser.user_id;
    
    deviceMode = CSN_CARD_MODE;
    registrationType = NEW_CARD;
    smartCardType = [[SimpleModel alloc] init];
    smartCardType.id = @"0";
    smartCardType.name = NSLocalizedString(@"secure_card", nil);
    
    contentTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    
    
    cardProvider = [[CardProvider alloc] init];
    userProvider = [[UserProvider alloc] init];
    deviceProvider = [[DeviceProvider alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    isCardAdded = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (isCardAdded)
    {
        if ([self.delegate respondsToSelector:@selector(addedCard:)])
        {
            [self.delegate addedCard:addedCard];
        }
    }
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
}

- (IBAction)saveCard:(id)sender {
    [self.view endEditing:YES];
    
    switch (deviceMode) {
            
        case CSN_CARD_MODE:
            switch (registrationType) {
                case NEW_CARD:
                    [self assignCSNCard];
                    break;
                case ASSIGNMENT:
                    [self assignCard:scanedCard];
                    break;
                case INPUT:
                    [self assignCSNCard];
                    break;
            }
            
            break;
            
        case WIEGAND_CARD_MODE:
            switch (registrationType) {
                case NEW_CARD:
                    [self assignWIEGANDCard];
                    break;
                case ASSIGNMENT:
                    [self assignCard:scanedCard];
                    break;
                case INPUT:
                    [self assignWIEGANDCard];
                    break;
            }
            break;
            
        case SMART_CARD_MODE:
            [self showSmartCardScanCardPopup];
            
            break;
            
        case MOBILE_CARD_MODE:
            [self issueMobileCredential];
            break;
            
        case READING_CARD_MODE:
        {
            CardType cardType = [scanedCard.type cardTypeEnumFromString];
            switch (cardType) {
                case CSN:
                case CSN_WIEGAND:
                case WIEGAND:
                case ACCESS_ON:
                case SECURE_CREDENTIAL:
                    
                    break;
            }
        }
            break;
        default:
            break;
    }
    
}


- (void)showInvalidCardTypeToast
{
    [self.view makeToast:NSLocalizedString(@"invalid_card_type", nil)
                duration:1.0
                position:CSToastPositionBottom
                   image:[UIImage imageNamed:@"toast_popup_i_03"]];
}

- (void)showScanCardPopup
{
    if (nil == selectedDevice)
    {
        [self.view makeToast:NSLocalizedString(@"select_device_orginal", nil)
                    duration:1.0
                    position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_03"]];
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ScanCardPopupViewController *scanPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ScanCardPopupViewController"];
    
    [scanPopupCtrl setDeviceID:selectedDevice.id];
    [scanPopupCtrl setDeviceMode:deviceMode];
    [self showPopup:scanPopupCtrl parentViewController:self parentView:self.view];
    
    [scanPopupCtrl getScanCard:^(Card *scanCard) {
        
        CardType cardType = [scanCard.type cardTypeEnumFromString];
        
        switch (deviceMode)
        {
            case CSN_CARD_MODE:
                if (cardType != CSN)
                {
                    [self showInvalidCardTypeToast];
                    return ;
                }
                
                break;
                
            case WIEGAND_CARD_MODE:
                if(cardType == CSN || cardType == SECURE_CREDENTIAL || cardType == ACCESS_ON)
                {
                    [self showInvalidCardTypeToast];
                    return ;
                }
                break;
                
            case SMART_CARD_MODE:
                if(cardType == CSN || cardType == WIEGAND || cardType == CSN_WIEGAND)
                {
                    [self showInvalidCardTypeToast];
                    return ;
                }
                break;
                
            default:
                break;
        }
        scanedCard = scanCard;
        
        
        if(cardType == CSN_WIEGAND || cardType == WIEGAND)
        {
            if (wiegandCard)
            {
                wiegandCard = nil;
                wiegandCard = [WiegandCard new];
            }
            wiegandCard.wiegand_format_id = scanCard.wiegand_format.id;
            
            NSMutableArray <WiegandCardID*> *wiegand_card_id_list = [[NSMutableArray alloc] init];
            NSArray *scanedCardIDS = [scanedCard.card_id componentsSeparatedByString:@"-"];
            
            for (NSString *wiegandCardID in scanedCardIDS)
            {
                WiegandCardID *cardID = [WiegandCardID new];
                cardID.card_id = wiegandCardID;
                [wiegand_card_id_list addObject:cardID];
            }
            
            wiegandCard.wiegand_card_id_list = wiegand_card_id_list;
        }
        else if (cardType == CSN)
        {
            inputCardID = scanedCard.card_id;
        }
        
        [contentTableView reloadData];
    }];
}

- (void)showSmartCardScanCardPopup
{
    if ([smartCardType.id integerValue] == 0)
    {
        // secure card
        if (nil == secureCredential.card_id || [secureCredential.card_id isEqualToString:@""])
        {
            [self.view makeToast:NSLocalizedString(@"none_select_card", nil)
                        duration:1.0
                        position:CSToastPositionBottom
                           image:[UIImage imageNamed:@"toast_popup_i_03"]];
            return;
        }
    }
    
    if (nil == selectedDevice)
    {
        [self.view makeToast:NSLocalizedString(@"none_card_layout_format", nil)
                    duration:1.0
                    position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_03"]];
        return;
    }
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ScanCardPopupViewController *scanPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ScanCardPopupViewController"];
    
    [scanPopupCtrl setDeviceMode:deviceMode];
    [scanPopupCtrl setCardType:smartCardType.id];
    if ([smartCardType.id integerValue] == 0)
    {
        // secure card
        [scanPopupCtrl setSecureCredential:secureCredential];
    }
    else
    {
        // access on card
        [scanPopupCtrl setAccessOnCredential:accessOnCredential];
        
    }
    [self showPopup:scanPopupCtrl parentViewController:self parentView:self.view];
    
    [scanPopupCtrl getScanedSmartCard:^(Card *scanCard) {
        
        addedCard = scanCard;
        isCardAdded = YES;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        OneButtonPopupViewController *oneButtonPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonPopupViewController"];
        oneButtonPopupCtrl.type = CARD_CHANGED;
        
        [self showPopup:oneButtonPopupCtrl parentViewController:self parentView:self.view];
        
        [oneButtonPopupCtrl getResponse:^(OneButtonPopupType type) {
            [self moveToBack:nil];
        }];
        
        if ([smartCardType.id integerValue] == 0)
        {
            // secure card
        }
        else
        {
            // access on card
            
        }
        
        
    }];
    
}

- (void)showListPopup:(PopupType)popupType
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ListPopupViewController *listPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListPopupViewController"];
    listPopupCtrl.type = popupType;
    [self showPopup:listPopupCtrl parentViewController:self parentView:self.view];
    
    if (popupType == CARD_TYPE)
    {
        
#warning 2.4.0 에는 mobile_card_upper 빼야함
#if MOBILE_CARD
        [listPopupCtrl addOptions:@[NSLocalizedString(@"csn", nil),
                                    NSLocalizedString(@"wiegand", nil),
                                    NSLocalizedString(@"smartcard", nil),
                                    NSLocalizedString(@"mobile_card_upper", nil),
                                    NSLocalizedString(@"read_card", nil)]];
#else
        [listPopupCtrl addOptions:@[NSLocalizedString(@"csn", nil),
                                    NSLocalizedString(@"wiegand", nil),
                                    NSLocalizedString(@"smartcard", nil),
                                    NSLocalizedString(@"read_card", nil)]];
#endif
        
    }
    else if (popupType == REGISTRATION_POPUP)
    {
        [listPopupCtrl addOptions:@[NSLocalizedString(@"registeration_option_card_reader", nil),
                                    NSLocalizedString(@"registeration_option_assign_card", nil),
                                    NSLocalizedString(@"registeration_option_direct_input", nil)]];
    }
    
    [listPopupCtrl getIndexResponseBlock:^(NSInteger index) {
        //카드 등록 방법 바꾸면 기존에 스캔했던 카드 nil;
        
        inputCardID = nil;
        scanedCard = nil;
        mobileCredential = nil;
        wiegandCard = nil;
        secureCredential = nil;
        accessOnCredential = nil;
        selectedDevice = nil;
        WIEGANDFormat = [WiegandFormat new];
        wiegandCard = [WiegandCard new];
        
        mobileCredential = [MobileCredential new];
        mobileCredential.type = SECURE;
        
        secureCredential = [SecureCredential new];
        secureCredential.user_id = currentUser.user_id;
        
        accessOnCredential = [AccessOnCredential new];
        accessOnCredential.user_id = currentUser.user_id;
        
        if (popupType == CARD_TYPE)
        {
            [saveButton setHidden:NO];
#if MOBILE_CARD
            
            switch (index) {
                case 0:
                    deviceMode = CSN_CARD_MODE;
                    break;
                case 1:
                    deviceMode = WIEGAND_CARD_MODE;
                    break;
                case 2:
                    deviceMode = SMART_CARD_MODE;
                    break;
                case 3:
                    deviceMode = MOBILE_CARD_MODE;
                    break;
                case 4:
                    deviceMode = READING_CARD_MODE;
                    [saveButton setHidden:YES];
                    break;
                default:
                    break;
            }
#else
            switch (index) {
                case 0:
                    deviceMode = CSN_CARD_MODE;
                    break;
                case 1:
                    deviceMode = WIEGAND_CARD_MODE;
                    break;
                case 2:
                    deviceMode = SMART_CARD_MODE;
                    break;
                case 3:
                    deviceMode = READING_CARD_MODE;
                    [saveButton setHidden:YES];
                    break;
                default:
                    break;
            }
#endif
            
        }
        else
        {
            switch (index) {
                case 0:
                    registrationType = NEW_CARD;
                    break;
                case 1:
                    registrationType = ASSIGNMENT;
                    break;
                case 2:
                    registrationType = INPUT;
                    break;
                default:
                    break;
            }
        }
        
        
        [contentTableView reloadData];
    }];
}

- (void)showDevicePopup
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    DevicePopupViewController *devicePopupController = [storyboard instantiateViewControllerWithIdentifier:@"DevicePopupViewController"];
    
    devicePopupController.deviceMode = deviceMode;
    [self showPopup:devicePopupController parentViewController:self parentView:self.view];
    [devicePopupController getDevice:^(SearchResultDevice *device) {
        selectedDevice = device;
        secureCredential.device_id = device.id;
        accessOnCredential.device_id = device.id;
        
        scanedCard = nil;
        wiegandCard = nil;
        wiegandCard = [WiegandCard new];
        
        [contentTableView reloadData];
    }];
}

- (void)showSmartCardPopup
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ListPopupViewController *listPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListPopupViewController"];
    listPopupCtrl.type = SMART_CARD_POPUP;
    
    [self showPopup:listPopupCtrl parentViewController:self parentView:self.view];
    
    [listPopupCtrl addOptions:@[NSLocalizedString(@"secure_card", nil),
                                NSLocalizedString(@"access_on_card", nil)]];
    
    [listPopupCtrl getIndexResponseBlock:^(NSInteger index) {
        if (index == 0)
        {
            smartCardType.name = NSLocalizedString(@"secure_card", nil);
            smartCardType.id = @"0";
            mobileCredential.type = SECURE;
        }
        else
        {
            smartCardType.name = NSLocalizedString(@"access_on_card", nil);
            smartCardType.id = @"1";
            mobileCredential.type = ACCESS;
        }
        
        secureCredential.card_id = nil;
        
        [contentTableView reloadData];
    }];
}

- (void)showWIEGANDCardDataTypePopup
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    WiegandFormatListPopupViewController *listPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"WiegandFormatListPopupViewController"];
    
    [self showPopup:listPopupCtrl parentViewController:self parentView:self.view];
    
    [listPopupCtrl getModelResponseBlock:^(WiegandFormat *model) {
        WIEGANDFormat = model;
        
        wiegandCardFormats = nil;
        wiegandCardFormats = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < WIEGANDFormat.wiegand_card_id_list.count; i++)
        {
            WiegandCardID *wiegandID = [WiegandCardID new];
            [wiegandCardFormats addObject:wiegandID];
        }
        
        wiegandCard.wiegand_card_id_list = wiegandCardFormats;
        wiegandCard.wiegand_format_id = model.id;
        [contentTableView reloadData];
    }];
    
}



- (void)showUnassignedCardPopup
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    CardPopupViewController *cardPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"CardPopupViewController"];
    [cardPopupCtrl setCardType:deviceMode];
    [self showPopup:cardPopupCtrl parentViewController:self parentView:self.view];

    [cardPopupCtrl getCardBlock:^(Card *card) {
        if (card.unassigned)
            scanedCard = card;
        
        CardType type = [card.type cardTypeEnumFromString];
        if (type == WIEGAND || type == CSN_WIEGAND)
        {
            if (wiegandCard)
            {
                wiegandCard = nil;
                wiegandCard = [WiegandCard new];
            }
            wiegandCard.wiegand_format_id = card.wiegand_format.id;
            
            NSMutableArray <WiegandCardID*> *wiegand_card_id_list = [[NSMutableArray alloc] init];
            
            NSArray *scanedCardIDS = [scanedCard.card_id componentsSeparatedByString:@"-"];
            
            for (NSString *wiegandCardID in scanedCardIDS)
            {
                WiegandCardID *cardID = [WiegandCardID new];
                cardID.card_id = wiegandCardID;
                [wiegand_card_id_list addObject:cardID];
            }
            
            wiegandCard.wiegand_card_id_list = wiegand_card_id_list;
        }
        
        [contentTableView reloadData];
    }];
}

- (void)showCardLayoutPopup
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    LayoutPopupViewController *layoutPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"LayoutPopupViewController"];
    
    [self showPopup:layoutPopupCtrl parentViewController:self parentView:self.view];
    
    [layoutPopupCtrl getCardLayoutBlock:^(SmartCardLayout *cardLayout) {
        
        currentCardLayout = cardLayout;
        mobileCredential.layout_id = cardLayout.id;
        
        [contentTableView reloadData];
        
    }];
    
}

- (void)showFingerPrintSelectPopup
{
    if (currentUser.fingerprint_template_count == 0)
    {
        [self.view makeToast:NSLocalizedString(@"none_registered_fingerprint", nil)
                    duration:1.0 position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_03"]];
        
        return;
    }
    
    if (deviceMode == SMART_CARD_MODE)
    {
        if (nil == selectedDevice)
        {
            [self.view makeToast:NSLocalizedString(@"none_card_layout_format", nil)
                        duration:1.0 position:CSToastPositionBottom
                           image:[UIImage imageNamed:@"toast_popup_i_03"]];
            return;
        }
    }
    else if (deviceMode == MOBILE_CARD_MODE)
    {
        if (nil == currentCardLayout)
        {
            [self.view makeToast:NSLocalizedString(@"none_card_layout_format", nil)
                        duration:1.0 position:CSToastPositionBottom
                           image:[UIImage imageNamed:@"toast_popup_i_03"]];
            return;
        }
    }
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    FingerPrintPopupViewController *fingerprintSelectPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"FingerPrintPopupViewController"];
    
    if (deviceMode == SMART_CARD_MODE)
    {
        [fingerprintSelectPopupCtrl setFingerprintTeaplatesCount:[currentUser.fingerprint_template_count integerValue] maxFingerprintCount:selectedDevice.smart_card_layout.max_template_in_card];
    }
    else if (deviceMode == MOBILE_CARD_MODE)
    {
        [fingerprintSelectPopupCtrl setFingerprintTeaplatesCount:[currentUser.fingerprint_template_count integerValue] maxFingerprintCount:currentCardLayout.max_template_in_card];
    }
    
    [self showPopup:fingerprintSelectPopupCtrl parentViewController:self parentView:self.view];
    
    [fingerprintSelectPopupCtrl getSelectedIndexsBlock:^(NSArray<NSNumber *> *fingerprintIndexs) {
        
        mobileCredential.fingerprint_index_list = fingerprintIndexs;
        secureCredential.fingerprint_index_list = fingerprintIndexs;
        accessOnCredential.fingerprint_index_list = fingerprintIndexs;
        
        [contentTableView reloadData];
    }];
    
}

- (void)setUserVeryfications:(User*)user userCards:(NSArray<Card*>*)cards
{
    userCards = cards;
    currentUser = user;
}


- (void)makeCSNCard:(NSString*)cardID
{
    [self startLoading:self];
    
    [cardProvider makeCSNCard:cardID resultBlock:^(AddResponse *response) {
        [self finishLoading];
        
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
                [self saveCard:nil];
            }
        }];
        
    }];
}

- (void)assignCard:(Card*)card
{
    if (nil == card)
    {
        [self.view makeToast:NSLocalizedString(@"none_select_card", nil)
                    duration:1.0 position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_03"]];
        
        return;
    }
    
    [self startLoading:self];
    
    CardList *cardList = [CardList new];
    
    NSMutableArray <SimpleCard *> *assignCardList = [[NSMutableArray alloc] init];
    for (Card *assignedCard in userCards)
    {
        SimpleCard *simpleCard = [[SimpleCard alloc] initWithID:assignedCard.id cardID:assignedCard.card_id];
        [assignCardList addObject:simpleCard];
    }
    
    SimpleCard *simpleCard = [[SimpleCard alloc] initWithID:card.id cardID:card.card_id];
    
    [assignCardList addObject:simpleCard];
    cardList.card_list = assignCardList;
    
    [userProvider updateUserCard:cardList userID:currentUser.user_id responseBlock:^(Response *response) {
        [self finishLoading];
        
        addedCard = card;
        isCardAdded = YES;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        OneButtonPopupViewController *oneButtonPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonPopupViewController"];
        oneButtonPopupCtrl.type = CARD_CHANGED;
        
        [self showPopup:oneButtonPopupCtrl parentViewController:self parentView:self.view];
        
        [oneButtonPopupCtrl getResponse:^(OneButtonPopupType type) {
            [self moveToBack:nil];
        }];
        
    } onErrorBlock:^(Response *error) {
        
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self assignCard:card];
            }
        }];
    }];
    
}

- (void)assignCSNCard
{
    if (nil == inputCardID)
    {
        [self.view makeToast:NSLocalizedString(@"none_select_card", nil)
                    duration:1.0 position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_03"]];
        
        return;
    }
    
    [self startLoading:self];
    
    [cardProvider makeCSNCard:inputCardID resultBlock:^(AddResponse *response) {
        
        [self finishLoading];
        Card *csnCard = [Card new];
        csnCard.id = response.id;
        csnCard.card_id = inputCardID;
        csnCard.type = [NSString cardTypeStringFromEnum:CSN];
        
        [self assignCard:csnCard];
    } onError:^(Response *error) {
       
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self assignCSNCard];
            }
        }];
        
    }];
    
    
}


- (void)assignWIEGANDCard
{
    switch (registrationType) {
        case NEW_CARD:
            if (nil == selectedDevice || nil == wiegandCard.wiegand_card_id_list)
            {
                [self.view makeToast:NSLocalizedString(@"wiegand_format_empty", nil)
                            duration:1.0 position:CSToastPositionBottom
                               image:[UIImage imageNamed:@"toast_popup_i_03"]];
                
                return;
            }
            break;
            
        case ASSIGNMENT:
            if (nil == wiegandCard.wiegand_card_id_list)
            {
                [self.view makeToast:NSLocalizedString(@"none_select_card", nil)
                            duration:1.0 position:CSToastPositionBottom
                               image:[UIImage imageNamed:@"toast_popup_i_03"]];
                
                return;
            }
            break;
            
        case INPUT:
            if (nil == wiegandCard.wiegand_card_id_list)
            {
                [self.view makeToast:NSLocalizedString(@"wiegand_format_empty", nil)
                            duration:1.0 position:CSToastPositionBottom
                               image:[UIImage imageNamed:@"toast_popup_i_03"]];
                
                return;
            }
            else
            {
                for (int i = 0; i < wiegandCard.wiegand_card_id_list.count; i++)
                {
                    WiegandCardID *WID = wiegandCard.wiegand_card_id_list[i];
                    
                    if ([WID.card_id isEqualToString:@""] || nil == WID.card_id)
                    {
                        if (i == 0)
                        {
                            [self.view makeToast:NSLocalizedString(@"discern_empty", nil)
                                        duration:1.0 position:CSToastPositionBottom
                                           image:[UIImage imageNamed:@"toast_popup_i_03"]];
                            return;
                        }
                        else
                        {
                            [self.view makeToast:NSLocalizedString(@"none_select_card", nil)
                                        duration:1.0 position:CSToastPositionBottom
                                           image:[UIImage imageNamed:@"toast_popup_i_03"]];
                            
                            return;
                        }
                    }
                }
            }
            
            
            break;
    }
    
    
    
    
    [self startLoading:self];
    
    [cardProvider makeWIEGANDCard:wiegandCard resultBlock:^(AddResponse *response) {
        
        [self finishLoading];
        
        Card *newWiegandCard = [Card new];
        newWiegandCard.id = response.id;
        
        [self assignCard:newWiegandCard];
        
    } onError:^(Response *error) {
        
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self assignWIEGANDCard];
            }
        }];
        
    }];
}

- (void)assignSecureCard
{
    [self startLoading:self];
    
    [cardProvider makeSecureCredentialCard:secureCredential resultBlock:^(AddResponse *response) {
        
        [self finishLoading];
        
        Card *newSecureCard = [Card new];
        newSecureCard.id = response.id;
        
        addedCard = newSecureCard;
        isCardAdded = YES;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        OneButtonPopupViewController *oneButtonPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonPopupViewController"];
        oneButtonPopupCtrl.type = CARD_CHANGED;
        
        [self showPopup:oneButtonPopupCtrl parentViewController:self parentView:self.view];
        
        [oneButtonPopupCtrl getResponse:^(OneButtonPopupType type) {
            [self moveToBack:nil];
        }];
        
        
    } onError:^(Response *error) {
        
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self assignSecureCard];
            }
        }];
        
    }];
}

- (void)assignAccessOnCard
{
    [self startLoading:self];
    
    [cardProvider makeAccessOnCard:accessOnCredential resultBlock:^(AddResponse *response) {
        
        [self finishLoading];
        
        Card *newSecureCard = [Card new];
        newSecureCard.id = response.id;
        
        addedCard = newSecureCard;
        isCardAdded = YES;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        OneButtonPopupViewController *oneButtonPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonPopupViewController"];
        oneButtonPopupCtrl.type = CARD_CHANGED;
        
        [self showPopup:oneButtonPopupCtrl parentViewController:self parentView:self.view];
        
        [oneButtonPopupCtrl getResponse:^(OneButtonPopupType type) {
            [self moveToBack:nil];
        }];
        
        
    } onError:^(Response *error) {
        
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self assignAccessOnCard];
            }
        }];
        
    }];
}

- (void)issueMobileCredential
{
    [self startLoading:self];
    [userProvider issueMobileCredential:mobileCredential userID:currentUser.user_id responseBlock:^(AddResponse *response) {
        
        [self finishLoading];
        Card *newSecureCard = [Card new];
        newSecureCard.id = response.id;
        
        addedCard = newSecureCard;
        isCardAdded = YES;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        OneButtonPopupViewController *successPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonPopupViewController"];

        successPopupCtrl.type = CARD_CHANGED;
        [self showPopup:successPopupCtrl parentViewController:self parentView:self.view];
        
        [successPopupCtrl getResponse:^(OneButtonPopupType type) {
            [self moveToBack:nil];
        }];
        
    } onErrorBlock:^(Response *error) {
        
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
                [self issueMobileCredential];
            }
        }];
        
    }];
    
}

#pragma mark - KeyBoard Noti

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    tableViewConstraint.constant = kbSize.height;
}

- (void)keyboardWillHide:(NSNotification*)notification {
    
    tableViewConstraint.constant = 0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0)
    {
        switch (deviceMode) {
            case CSN_CARD_MODE:
                switch (registrationType) {
                    case NEW_CARD:
                        return 4;
                        break;
                        
                    case ASSIGNMENT:
                        return 3;
                        break;
                        
                    case INPUT:
                        return 2;
                        break;
                }
                
            case WIEGAND_CARD_MODE:
                switch (registrationType) {
                    case NEW_CARD:
                        return 5;
                        break;
                        
                    case ASSIGNMENT:
                        return 4;
                        break;
                        
                    case INPUT:
                        return 3;
                        break;
                }
                break;
                
            case SMART_CARD_MODE:
                return 4;
                break;
            case MOBILE_CARD_MODE:
                return 3;
                break;
                
            case READING_CARD_MODE:
                if (nil == scanedCard)
                    return 3;
                else
                {
                    CardType type = [scanedCard.type cardTypeEnumFromString];
                    switch (type)
                    {
                        case CSN:
                            return 3;
                        case WIEGAND:
                        case CSN_WIEGAND:
                            return 4;
                        case SECURE_CREDENTIAL:
                            return 5;
                        case ACCESS_ON:
                            return 5;
                    }
                }
                break;
            default:
                return 0;
                break;
        }
    }
    else
    {
        switch (deviceMode) {
            case CSN_CARD_MODE:
                return 1;
                
            case WIEGAND_CARD_MODE:
                switch (registrationType) {
                    case NEW_CARD:
                        return wiegandCard.wiegand_card_id_list.count;
                        break;
                        
                    case ASSIGNMENT:
                        return wiegandCard.wiegand_card_id_list.count;
                        break;
                        
                    case INPUT:
                        return WIEGANDFormat.wiegand_card_id_list.count;
                        break;
                }
                break;
                
            case SMART_CARD_MODE:
                if ([smartCardType.id integerValue] == 0)
                {
                    return 3;
                }
                else
                {
                    return 5;
                }
                
                break;
            case MOBILE_CARD_MODE:
                return 5;
                break;
                
            case READING_CARD_MODE:
                if (nil == scanedCard)
                {
                    return 0;
                }
                else
                {
                    CardType cardType = [scanedCard.type cardTypeEnumFromString];
                    switch (cardType) {
                        case CSN:
                            return 1;
                        case CSN_WIEGAND:
                        case WIEGAND:
                            return wiegandCard.wiegand_card_id_list.count;
                        case ACCESS_ON:
                            return 5;
                            break;
                        case SECURE_CREDENTIAL:
                            return 3;
                            break;
                    }
                }
                
                break;
            default:
                return 0;
                break;
        }
    }
    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // 폰트 때문에 뷰에서 섹션 타이틀 정해줘야 할 필요 있음.
    if (section == 1)
    {
        return NSLocalizedString(@"info", nil);
    }
    else
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0;
    }
    else
    {
        return 30;
    }
    
}

- (UITableViewCell*)makeCSNCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
        CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
        
        switch (registrationType) {
            case NEW_CARD:
                if (indexPath.row == 0)
                {
                    [customCell setTitle:NSLocalizedString(@"card_type", nil) content:NSLocalizedString(@"csn", nil)];
                }
                else if (indexPath.row == 1)
                {
                    [customCell setTitle:NSLocalizedString(@"register_method", nil) content:NSLocalizedString(@"registeration_option_card_reader", nil)];
                }
                else if (indexPath.row == 2)
                {
                    [customCell setTitle:NSLocalizedString(@"device", nil) content:selectedDevice.name];
                }
                else if (indexPath.row == 3)
                {
                    [customCell setTitle:NSLocalizedString(@"read_card", nil) content:@""];
                }
                break;
                
            case ASSIGNMENT:
                if (indexPath.row == 0)
                {
                    [customCell setTitle:NSLocalizedString(@"card_type", nil) content:NSLocalizedString(@"csn", nil)];
                }
                else if (indexPath.row == 1)
                {
                    [customCell setTitle:NSLocalizedString(@"register_method", nil) content:NSLocalizedString(@"registeration_option_assign_card", nil)];
                }
                else if (indexPath.row == 2)
                {
                    [customCell setTitle:NSLocalizedString(@"registeration_option_assign_card", nil) content:nil];
                }
                break;
                
            case INPUT:
                if (indexPath.row == 0)
                {
                    [customCell setTitle:NSLocalizedString(@"card_type", nil) content:NSLocalizedString(@"csn", nil)];
                }
                else if (indexPath.row == 1)
                {
                    [customCell setTitle:NSLocalizedString(@"register_method", nil) content:NSLocalizedString(@"registeration_option_direct_input", nil)];
                }
                break;
        }
        return customCell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
        CardInfoText *customCell = (CardInfoText*)cell;
        customCell.delegate = self;
        switch (registrationType) {
            case NEW_CARD:
                [customCell setTitle:NSLocalizedString(@"card_id", nil) content:scanedCard.card_id];
                break;
            case ASSIGNMENT:
                [customCell setTitle:NSLocalizedString(@"card_id", nil) content:scanedCard.card_id];
                break;
            case INPUT:
                [customCell setTitle:NSLocalizedString(@"card_id", nil) field:inputCardID];
                break;
        }
        [customCell setCardInfoType:registrationType deviceMode:deviceMode];
        return customCell;
    }
}

- (UITableViewCell*)makeWIEGANDCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        switch (registrationType) {
            case NEW_CARD:
            {
                if (indexPath.row == 0)
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
                    CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
                    
                    [customCell setTitle:NSLocalizedString(@"card_type", nil) content:NSLocalizedString(@"wiegand", nil)];
                    return customCell;
                }
                else if (indexPath.row == 1)
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
                    CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
                    
                    [customCell setTitle:NSLocalizedString(@"register_method", nil) content:NSLocalizedString(@"registeration_option_card_reader", nil)];
                    return customCell;
                }
                else if (indexPath.row == 2)
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
                    CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
                    [customCell setTitle:NSLocalizedString(@"device", nil) content:selectedDevice.name];
                    return customCell;
                }
                else if (indexPath.row == 3)
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                    CardInfoText *customCell = (CardInfoText*)cell;
                    [customCell setTitle:NSLocalizedString(@"card_data_format", nil) content:scanedCard.wiegand_format.name];
                    [customCell setOnlyContent];
                    return customCell;
                }
                else
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
                    CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
                    
                    [customCell setTitle:NSLocalizedString(@"read_card", nil) content:@""];
                    return customCell;
                }
            }
                break;
                
            case ASSIGNMENT:
            {
                if (indexPath.row == 0)
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
                    CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
                    [customCell setTitle:NSLocalizedString(@"card_type", nil) content:NSLocalizedString(@"wiegand", nil)];
                    return customCell;
                }
                else if (indexPath.row == 1)
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
                    CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
                    [customCell setTitle:NSLocalizedString(@"register_method", nil) content:NSLocalizedString(@"registeration_option_assign_card", nil)];
                    return customCell;
                }
                else if (indexPath.row == 2)
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                    CardInfoText *customCell = (CardInfoText*)cell;
                    customCell.delegate = self;
                    [customCell setTitle:NSLocalizedString(@"card_data_format", nil) content:scanedCard.wiegand_format.name];
                    [customCell setOnlyContent];
                    
                    return customCell;
                }
                else
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
                    CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
                    [customCell setTitle:NSLocalizedString(@"registeration_option_assign_card", nil) content:@""];
                    return customCell;
                }
                
            }
                break;
                
            case INPUT:
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
                CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
                if (indexPath.row == 0)
                {
                    [customCell setTitle:NSLocalizedString(@"card_type", nil) content:NSLocalizedString(@"wiegand", nil)];
                }
                else if (indexPath.row == 1)
                {
                    [customCell setTitle:NSLocalizedString(@"register_method", nil) content:NSLocalizedString(@"registeration_option_direct_input", nil)];
                }
                else
                {
                    [customCell setTitle:NSLocalizedString(@"card_data_format", nil) content:WIEGANDFormat.name];
                }
                return customCell;
            }
                break;
        }
    }
    else
    {
        switch (registrationType) {
                
            case NEW_CARD:
            case ASSIGNMENT:
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                CardInfoText *customCell = (CardInfoText*)cell;
                [customCell setCardInfoType:registrationType deviceMode:deviceMode];
                if (indexPath.row == 0)
                {
                    [customCell setTitle:NSLocalizedString(@"id_code", nil) content:wiegandCard.wiegand_card_id_list[indexPath.row].card_id];
                }
                else
                {
                    [customCell setTitle:NSLocalizedString(@"card_id", nil) content:wiegandCard.wiegand_card_id_list[indexPath.row].card_id];
                }
                
                return customCell;
            }
                break;
                
            case INPUT:
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                CardInfoText *customCell = (CardInfoText*)cell;
                customCell.delegate = self;
                [customCell setCardInfoType:registrationType deviceMode:deviceMode];
                
                if (WIEGANDFormat.wiegand_card_id_list.count == 1)
                {
                    [customCell setTitle:NSLocalizedString(@"card_id", nil) field:wiegandCard.wiegand_card_id_list[indexPath.row].card_id maxValue:WIEGANDFormat.wiegand_card_id_list[indexPath.row].card_id_max_num];
                    return customCell;
                }
                else
                {
                    if (indexPath.row == 0)
                    {
                        [customCell setTitle:NSLocalizedString(@"id_code", nil) field:wiegandCard.wiegand_card_id_list[indexPath.row].card_id maxValue:WIEGANDFormat.wiegand_card_id_list[indexPath.row].card_id_max_num];
                        return customCell;
                    }
                    else
                    {
                        [customCell setTitle:NSLocalizedString(@"card_id", nil) field:wiegandCard.wiegand_card_id_list[indexPath.row].card_id maxValue:WIEGANDFormat.wiegand_card_id_list[indexPath.row].card_id_max_num];
                        return customCell;
                    }
                }
                
            }
                break;
        }
    }
}

- (UITableViewCell*)makeSmartCardCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
            CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
            [customCell setTitle:NSLocalizedString(@"card_type", nil) content:NSLocalizedString(@"smartcard", nil)];
            return customCell;
        }
        else if (indexPath.row == 1)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
            CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
            [customCell setTitle:NSLocalizedString(@"device", nil) content:selectedDevice.name];
            return customCell;
        }
        else if (indexPath.row == 2)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
            CardInfoText *customCell = (CardInfoText*)cell;
            [customCell setTitle:NSLocalizedString(@"card_layout_format", nil) content:selectedDevice.smart_card_layout.name];
            [customCell setCardInfoType:NEW_CARD deviceMode:deviceMode];
            return customCell;
        }
        else if (indexPath.row == 3)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
            CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
            [customCell setTitle:NSLocalizedString(@"smartcard_type", nil) content:smartCardType.name];
            return customCell;
        }
        else
        {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            return cell;
        }
    }
    else
    {
        if ([smartCardType.id integerValue] == 0)
        {
            if (indexPath.row == 0)
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                CardInfoText *customCell = (CardInfoText*)cell;
                customCell.delegate = self;
                [customCell setCardInfoType:INPUT deviceMode:deviceMode];
                [customCell setTitle:NSLocalizedString(@"card_id", nil) field:secureCredential.card_id];
                return customCell;
            }
            else if (indexPath.row == 1)
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
                CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
                
                if (mobileCredential.fingerprint_index_list.count > 0)
                {
                    [customCell setTitle:NSLocalizedString(@"fingerprint", nil) content:[mobileCredential getFingerprintDescription]];
                }
                else
                {
                    [customCell setTitle:NSLocalizedString(@"fingerprint", nil) content:nil];
                }
                return customCell;
            }
            else
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                CardInfoText *customCell = (CardInfoText*)cell;
                customCell.delegate = self;
                [customCell setPinExist:currentUser.pin_exist];
                [customCell setTitle:NSLocalizedString(@"pin_upper", nil) content:nil];
                return customCell;
            }
        }
        else
        {
            if (indexPath.row == 0)
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                CardInfoText *customCell = (CardInfoText*)cell;
                customCell.delegate = self;
                [customCell setOnlyContent];
                [customCell setTitle:NSLocalizedString(@"card_id", nil) content:currentUser.user_id];
                return customCell;
            }
            else if (indexPath.row == 1)
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
                CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
                
                if (mobileCredential.fingerprint_index_list.count > 0)
                {
                    [customCell setTitle:NSLocalizedString(@"fingerprint", nil) content:[mobileCredential getFingerprintDescription]];
                }
                else
                {
                    [customCell setTitle:NSLocalizedString(@"fingerprint", nil) content:nil];
                }
                return customCell;
            }
            else if (indexPath.row == 2)
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                CardInfoText *customCell = (CardInfoText*)cell;
                [customCell setPinExist:currentUser.pin_exist];
                [customCell setTitle:NSLocalizedString(@"pin_upper", nil) content:nil];
                return customCell;
            }
            else if (indexPath.row == 3)
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                CardInfoText *customCell = (CardInfoText*)cell;
                [customCell setOnlyContent];
                NSString *accessGroup = currentUser.access_groups.count > 0 ? currentUser.access_groups[0].name : nil;
                [customCell setTitle:NSLocalizedString(@"access_group", nil) content:accessGroup];
                return customCell;
            }
            else
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                CardInfoText *customCell = (CardInfoText*)cell;
                [customCell setOnlyContent];
                [customCell setTitle:NSLocalizedString(@"period", nil) content:nil];
                [customCell setStartDate:currentUser.start_datetime andExpireDate:currentUser.expiry_datetime];
                return customCell;
            }
        }
        
    }
}


- (UITableViewCell*)makeMobileCardCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
            CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
            [customCell setTitle:NSLocalizedString(@"card_type", nil) content:NSLocalizedString(@"mobile_card_upper", nil)];
            return customCell;
        }
        else if (indexPath.row == 1)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
            CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
            [customCell setTitle:NSLocalizedString(@"card_layout_format", nil) content:currentCardLayout.name];
            return customCell;
        }
        else
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
            CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
            [customCell setTitle:NSLocalizedString(@"smartcard_type", nil) content:smartCardType.name];
            return customCell;
        }
    }
    else
    {
        if (indexPath.row == 0)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
            CardInfoText *customCell = (CardInfoText*)cell;
            customCell.delegate = self;
            [customCell setCardInfoType:INPUT deviceMode:deviceMode];
            [customCell setTitle:NSLocalizedString(@"card_id", nil) field:mobileCredential.card_id];
            return customCell;
        }
        else if (indexPath.row == 1)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
            CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
            
            if (mobileCredential.fingerprint_index_list.count > 0)
            {
                [customCell setTitle:NSLocalizedString(@"fingerprint", nil) content:[mobileCredential getFingerprintDescription]];
            }
            else
            {
                [customCell setTitle:NSLocalizedString(@"fingerprint", nil) content:nil];
            }
            return customCell;
        }
        else if (indexPath.row == 2)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
            CardInfoText *customCell = (CardInfoText*)cell;
            [customCell setPinExist:currentUser.pin_exist];
            [customCell setTitle:NSLocalizedString(@"pin_upper", nil) content:nil];
            return customCell;
        }
        else if (indexPath.row == 3)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
            CardInfoText *customCell = (CardInfoText*)cell;
            [customCell setOnlyContent];
            NSString *accessGroup = currentUser.access_groups.count > 0 ? currentUser.access_groups[0].name : nil;
            [customCell setTitle:NSLocalizedString(@"access_group", nil) content:accessGroup];
            return customCell;
        }
        else
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
            CardInfoText *customCell = (CardInfoText*)cell;
            [customCell setOnlyContent];
            [customCell setTitle:NSLocalizedString(@"period", nil) content:nil];
            [customCell setStartDate:currentUser.start_datetime andExpireDate:currentUser.expiry_datetime];
            return customCell;
        }
    }
}



- (UITableViewCell*)makeCardReadingCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        if (nil == scanedCard)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
            CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
            if (indexPath.row == 0)
            {
                [customCell setTitle:NSLocalizedString(@"card_type", nil) content:NSLocalizedString(@"read_card", nil)];
            }
            else if (indexPath.row == 1)
            {
                [customCell setTitle:NSLocalizedString(@"device", nil) content:selectedDevice.name];
            }
            else
            {
                [customCell setTitle:NSLocalizedString(@"read_card", nil) content:@""];
            }
            return customCell;
        }
        else
        {
            CardType type = [scanedCard.type cardTypeEnumFromString];
            
            switch (type)
            {
                case CSN:
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
                    CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
                    if (indexPath.row == 0)
                    {
                        [customCell setTitle:NSLocalizedString(@"card_type", nil) content:NSLocalizedString(@"read_card", nil)];
                    }
                    else if (indexPath.row == 1)
                    {
                        [customCell setTitle:NSLocalizedString(@"device", nil) content:selectedDevice.name];
                    }
                    else
                    {
                        [customCell setTitle:NSLocalizedString(@"read_card", nil) content:@""];
                    }
                    return customCell;
                }
                case CSN_WIEGAND:
                case WIEGAND:
                {
                    if (indexPath.row == 0)
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
                        CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
                        [customCell setTitle:NSLocalizedString(@"card_type", nil) content:NSLocalizedString(@"read_card", nil)];
                        return customCell;
                    }
                    else if (indexPath.row == 1)
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
                        CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
                        [customCell setTitle:NSLocalizedString(@"device", nil) content:selectedDevice.name];
                        return customCell;
                    }
                    else if (indexPath.row == 2)
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                        CardInfoText *customCell = (CardInfoText*)cell;
                        [customCell setTitle:NSLocalizedString(@"card_data_format", nil) content:scanedCard.wiegand_format.name];
                        [customCell setOnlyContent];
                        return customCell;
                    }
                    else
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
                        CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
                        [customCell setTitle:NSLocalizedString(@"read_card", nil) content:@""];
                        return customCell;
                    }
                    
                }
                case SECURE_CREDENTIAL:
                {
                    if (indexPath.row == 0)
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
                        CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
                        [customCell setTitle:NSLocalizedString(@"card_type", nil) content:NSLocalizedString(@"read_card", nil)];
                        return customCell;
                    }
                    else if (indexPath.row == 1)
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
                        CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
                        [customCell setTitle:NSLocalizedString(@"device", nil) content:selectedDevice.name];
                        return customCell;
                    }
                    else if (indexPath.row == 2)
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                        CardInfoText *customCell = (CardInfoText*)cell;
                        [customCell setTitle:NSLocalizedString(@"card_layout_format", nil) content:selectedDevice.smart_card_layout.name];
                        [customCell setOnlyContent];
                        return customCell;
                    }
                    else if (indexPath.row == 3)
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                        CardInfoText *customCell = (CardInfoText*)cell;
                        [customCell setTitle:NSLocalizedString(@"smartcard_type", nil) smartCardType:scanedCard.type];
                        [customCell setOnlyContent];
                        return customCell;
                    }
                    else
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
                        CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
                        [customCell setTitle:NSLocalizedString(@"read_card", nil) content:@""];
                        return customCell;
                    }
                    
                }
                case ACCESS_ON:
                {
                    if (indexPath.row == 0)
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
                        CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
                        [customCell setTitle:NSLocalizedString(@"card_type", nil) content:NSLocalizedString(@"read_card", nil)];
                        return customCell;
                    }
                    else if (indexPath.row == 1)
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
                        CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
                        [customCell setTitle:NSLocalizedString(@"device", nil) content:selectedDevice.name];
                        return customCell;
                    }
                    else if (indexPath.row == 2)
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                        CardInfoText *customCell = (CardInfoText*)cell;
                        [customCell setTitle:NSLocalizedString(@"card_layout_format", nil) content:selectedDevice.smart_card_layout.name];
                        [customCell setOnlyContent];
                        return customCell;
                    }
                    else if (indexPath.row == 3)
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                        CardInfoText *customCell = (CardInfoText*)cell;
                        [customCell setTitle:NSLocalizedString(@"smartcard_type", nil) smartCardType:scanedCard.type];
                        [customCell setOnlyContent];
                        return customCell;
                    }
                    else
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardAddInfoCell" forIndexPath:indexPath];
                        CardAddInfoCell *customCell = (CardAddInfoCell*)cell;
                        [customCell setTitle:NSLocalizedString(@"read_card", nil) content:@""];
                        return customCell;
                    }
                }
            }
        }
    }
    else
    {
        if (nil == scanedCard)
        {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            return cell;
        }
        else
        {
            CardType cardType = [scanedCard.type cardTypeEnumFromString];
            switch (cardType) {
                case CSN:
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                    CardInfoText *customCell = (CardInfoText*)cell;
                    [customCell setOnlyContent];
                    [customCell setTitle:NSLocalizedString(@"card_id", nil) content:scanedCard.card_id];
                    return customCell;
                }
                case CSN_WIEGAND:
                case WIEGAND:
                    if (indexPath.row == 0)
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                        CardInfoText *customCell = (CardInfoText*)cell;
                        [customCell setOnlyContent];
                        [customCell setTitle:NSLocalizedString(@"id_code", nil) content:wiegandCard.wiegand_card_id_list[indexPath.row].card_id];
                        return customCell;
                    }
                    else
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                        CardInfoText *customCell = (CardInfoText*)cell;
                        [customCell setOnlyContent];
                        [customCell setTitle:NSLocalizedString(@"card_id", nil) content:wiegandCard.wiegand_card_id_list[indexPath.row].card_id];
                        return customCell;
                    }
                    
                case ACCESS_ON:
                case SECURE_CREDENTIAL:
                    if (indexPath.row == 0)
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                        CardInfoText *customCell = (CardInfoText*)cell;
                        [customCell setOnlyContent];
                        [customCell setTitle:NSLocalizedString(@"card_id", nil) content:scanedCard.card_id];
                        return customCell;
                    }
                    else if (indexPath.row == 1)
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                        CardInfoText *customCell = (CardInfoText*)cell;
                        [customCell setOnlyContent];
                        
                        if (scanedCard.fingerprint_templates.count > 0)
                        {
                            [customCell setTitle:NSLocalizedString(@"fingerprint", nil) content:[scanedCard getFingerprintDescription]];
                        }
                        else
                        {
                            [customCell setTitle:NSLocalizedString(@"fingerprint", nil) content:nil];
                        }
                        
                        return customCell;
                    }
                    else if (indexPath.row == 2)
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                        CardInfoText *customCell = (CardInfoText*)cell;
                        customCell.delegate = self;
                        [customCell setPinExist:scanedCard.pin_exist];
                        [customCell setTitle:NSLocalizedString(@"pin_upper", nil) content:nil];
                        return customCell;
                    }
                    else if (indexPath.row == 3)
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                        CardInfoText *customCell = (CardInfoText*)cell;
                        [customCell setOnlyContent];
                        if (scanedCard.access_groups.count > 0)
                        {
                            [customCell setTitle:NSLocalizedString(@"access_group", nil) content:scanedCard.access_groups[0].name];
                        }
                        else if (scanedCard.access_groups.count  > 1)
                        {
                            NSString *content = [NSString stringWithFormat:@"%@ +%ld",scanedCard.access_groups[0].name , scanedCard.access_groups.count - 1];
                            [customCell setTitle:NSLocalizedString(@"access_group", nil) content:content];
                        }
                        else
                        {
                            [customCell setTitle:NSLocalizedString(@"access_group", nil) content:nil];
                        }
                        
                        return customCell;
                    }
                    else
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardInfoText" forIndexPath:indexPath];
                        CardInfoText *customCell = (CardInfoText*)cell;
                        [customCell setOnlyContent];
                        [customCell setTitle:NSLocalizedString(@"period", nil) content:nil];
                        [customCell setStartDate:scanedCard.start_datetime andExpireDate:scanedCard.expiry_datetime];
                        return customCell;
                    }
                    break;
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        switch (deviceMode) {
            case CSN_CARD_MODE:
                return [self makeCSNCell:tableView cellForRowAtIndexPath:indexPath];
                break;
            case WIEGAND_CARD_MODE:
                return [self makeWIEGANDCell:tableView cellForRowAtIndexPath:indexPath];
                break;
                
            case SMART_CARD_MODE:
                return [self makeSmartCardCell:tableView cellForRowAtIndexPath:indexPath];
                break;
            case MOBILE_CARD_MODE:
                return [self makeMobileCardCell:tableView cellForRowAtIndexPath:indexPath];
                break;
                
            case READING_CARD_MODE:
                return [self makeCardReadingCell:tableView cellForRowAtIndexPath:indexPath];
                break;
            default:
            {
                UITableViewCell *cell = [[UITableViewCell alloc] init];
                return cell;
            }
                break;
        }
    }
    else
    {
        switch (deviceMode) {
            case CSN_CARD_MODE:
                return [self makeCSNCell:tableView cellForRowAtIndexPath:indexPath];
                break;
                
            case WIEGAND_CARD_MODE:
                return [self makeWIEGANDCell:tableView cellForRowAtIndexPath:indexPath];
                break;
                
            case SMART_CARD_MODE:
                return [self makeSmartCardCell:tableView cellForRowAtIndexPath:indexPath];
                break;
            case MOBILE_CARD_MODE:
                return [self makeMobileCardCell:tableView cellForRowAtIndexPath:indexPath];
                break;
                
            case READING_CARD_MODE:
                return [self makeCardReadingCell:tableView cellForRowAtIndexPath:indexPath];
                break;
            default:
            {
                UITableViewCell *cell = [[UITableViewCell alloc] init];
                return cell;
            }
                break;
        }
    }
}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    id cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSString *cellTitle;
    
    if ([cell respondsToSelector:@selector(getTitle)])
    {
        cellTitle = [cell getTitle];
    }
    
    
    if ([cellTitle isEqualToString:NSLocalizedString(@"card_type", nil)])
    {
        // 카드 종류 -> 카드 종류 선택 팝업
        [self showListPopup:CARD_TYPE];
    }
    else if ([cellTitle isEqualToString:NSLocalizedString(@"register_method", nil)])
    {
        // 등록 방법 -> 리더, 할당, 직접 입력 팝업
        [self showListPopup:REGISTRATION_POPUP];
    }
    else if ([cellTitle isEqualToString:NSLocalizedString(@"device", nil)])
    {
        // 장치 선택 팝업
        [self showDevicePopup];
    }
    else if ([cellTitle isEqualToString:NSLocalizedString(@"read_card", nil)])
    {
        // 카드 읽기
        [self showScanCardPopup];
    }
    else if ([cellTitle isEqualToString:NSLocalizedString(@"registeration_option_assign_card", nil)])
    {
        // 카드 할당 unassigned cards 팝업
        [self showUnassignedCardPopup];
    }
    else if ([cellTitle isEqualToString:NSLocalizedString(@"smartcard_type", nil)])
    {
        // 스마트 카드 종류 팝업
        [self showSmartCardPopup];
    }
    else if ([cellTitle isEqualToString:NSLocalizedString(@"fingerprint", nil)])
    {
        // 지문 팝업
        [self showFingerPrintSelectPopup];
    }
    else if ([cellTitle isEqualToString:NSLocalizedString(@"card_layout_format", nil)])
    {
        if (deviceMode == MOBILE_CARD_MODE)
        {
            // 모바일 카드에서 카드레이아웃 형식
            [self showCardLayoutPopup];
        }
    }
    else if ([cellTitle isEqualToString:NSLocalizedString(@"card_data_format", nil)])
    {
        // 카드 데이터 형식 wiegand
        if (registrationType == INPUT)
        {
            [self showWIEGANDCardDataTypePopup];
        }
    }
    

}


#pragma mark - CardInfoTextCellDelegate

- (void)wiegandContentDidChanged:(NSString*)content cell:(UITableViewCell*)cell
{
    NSIndexPath *indexPath = [contentTableView indexPathForCell:cell];
    
    wiegandCardFormats[indexPath.row].card_id = content;
    
    wiegandCard.wiegand_card_id_list = wiegandCardFormats;
    
    [contentTableView reloadData];
}

- (void)textfieldContentDidChanged:(NSString*)content
{
    switch (deviceMode) {
        case CSN_CARD_MODE:
            inputCardID = content;
            break;
            
        case WIEGAND_CARD_MODE:
            //wiegandCard.card_id = content;
            break;
            
        case SMART_CARD_MODE:
            secureCredential.card_id = content;
            break;
        case MOBILE_CARD_MODE:
            mobileCredential.card_id = content;
            break;
            
        case READING_CARD_MODE:
            
            break;
        default:
            break;
    }
}

- (void)maxValueIsOver:(NSInteger)maxValue
{
    [self.view makeToast:[NSString stringWithFormat:@"%@\n%ld",NSLocalizedString(@"over_value", nil) ,(long)maxValue]
                duration:1.0 position:CSToastPositionTop
                   image:[UIImage imageNamed:@"toast_popup_i_03"]];
}

- (void)zeroValueNotAllowed
{
    [self.view makeToast:NSLocalizedString(@"invalid_card_id", nil)
                duration:1.0 position:CSToastPositionTop
                   image:[UIImage imageNamed:@"toast_popup_i_03"]];
}
@end
