//
//  MobileCardViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 9. 29..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "MobileCardViewController.h"
#import "Lottie/Lottie.h"


@interface MobileCardViewController ()


@end

@implementation MobileCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    BLEIsReady = NO;
    mobileCredentialIsLoaded = NO;
    
    titleLabel.text = NSBaseLocalizedString(@"mobile_card", nil);
    registDecLabel.text = NSBaseLocalizedString(@"guide_register_mobile_card3", nil);
    
    userProvider = [[UserProvider alloc] init];
    [mobileCredentialView setHidden:YES];
    
    mappingProvider = [[InCodeMappingProvider alloc] init];
    mapper = [[ObjectMapper alloc] init];
    mapper.mappingProvider = mappingProvider;
    
    cbController = [[CBCentralManagerController alloc] init];
    cbController.delegate = self;
    
    [self getMobileCredential];
    
    [testLabel setHidden:YES];
    [errorLabel setHidden:YES];
    
    cardDecLabel.text = NSBaseLocalizedString(@"card_id", nil);
    credentialLabel.text = NSBaseLocalizedString(@"credential", nil);
    accessGroupDecLabel.text = NSBaseLocalizedString(@"access_group", nil);
    periodDecLabel.text = NSBaseLocalizedString(@"period", nil);
    
    
    [resultImageView setHidden:YES];
    
    gradientBackGround = [CAGradientLayer layer];
    gradientBackGround.frame = BGView.bounds;
    gradientBackGround.colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0x302c2d).CGColor, (id)UIColorFromRGB(0x131212).CGColor, nil];
    NSArray *gradientLocations = [NSArray arrayWithObjects:[NSNumber numberWithInt:0.0],[NSNumber numberWithInt:1.0], nil];
    gradientBackGround.locations = gradientLocations;
    [BGView.layer insertSublayer:gradientBackGround atIndex:0];
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground)
                                                 name:APP_DID_ENTER_BACKGROUND
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground)
                                                 name:APP_WILL_ENTER_FOREGROUND
                                               object:nil];
    
    
}

- (void)appDidEnterBackground
{
    [cbController stopScan];
}

- (void)appWillEnterForeground
{
    [self checkAndStartBLEMonitoring];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBLEStatus)
                                                 name:SETTING_WILL_CLOSE
                                               object:nil];
    
    double rads = DEGREES_TO_RADIANS(90);
    CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);
    mobileCredentialView.transform = transform;
    
    if (IS_IPHONE_4)
    {
        cardViewConstraint.constant = 80;
    }
    else if(IS_IPHONE_5)
    {
        cardViewConstraint.constant = 120;
    }
    else if (IS_IPHONE_6)
    {
        cardViewConstraint.constant = 130;
    }
    else
    {
        cardViewConstraint.constant = 150;
    }
    
    animation = [LOTAnimationView animationNamed:@"scan"];
    [animationView addSubview:animation];
    
    [animation setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [animationView addConstraint:[NSLayoutConstraint constraintWithItem:animation
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:animationView
                                                       attribute:NSLayoutAttributeWidth
                                                      multiplier:1
                                                        constant:0]];
    
    [animationView addConstraint:[NSLayoutConstraint constraintWithItem:animation
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:animationView
                                                       attribute:NSLayoutAttributeHeight
                                                      multiplier:1
                                                        constant:0]];
    
    
    [animationView addConstraint:[NSLayoutConstraint constraintWithItem:animation
                                                       attribute:NSLayoutAttributeTop
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:animationView
                                                       attribute:NSLayoutAttributeTop
                                                      multiplier:1
                                                        constant:0]];
    
    [animationView addConstraint:[NSLayoutConstraint constraintWithItem:animation
                                                       attribute:NSLayoutAttributeTrailing
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:animationView
                                                       attribute:NSLayoutAttributeTrailing
                                                      multiplier:1
                                                        constant:0]];
    
    animation.loopAnimation = YES;
    animation.animationSpeed = 1.3;
    animation.alpha = 0.7;
    [animation setHidden:YES];
    //[animation play];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SETTING_WILL_CLOSE object:nil];
    
    //[self disconnectGATT];
}

- (void)updateBLEStatus
{
    if ([LocalDataManager getUserMlbileCredentialStatus])
    {
        [self checkAndStartBLEMonitoring];
    }
    else
    {
        [cbController disconnectGATT];
    }
    
}


- (void)startAnimation
{
    [resultImageView setHidden:YES];
    [animation setHidden:NO];
    [animation play];
}

- (void)stopAnimation
{
    [animation setHidden:YES];
    [animation pause];
}

- (void)setCurrentUser:(User*)user
{
    currentUser = user;
}


- (void)setMobileCardContent:(GetMobileCredential*)card user:(User*)user
{
    if (nil != user.photo && ![user.photo isEqualToString:@""])
    {
        NSData *imageData = [NSData base64DataFromString:user.photo];
        UIImage *userImage = [UIImage imageWithData:imageData];
        
        UIImage *image = [CommonUtil imageCompress:userImage fileSize:MAX_IMAGE_FILE_SIZE];
        if (image)
        {
            cardPhoto.image = image;
        }
        
    }
    
    
    cardNumberLabel.text = card.card_id;
    
    fingerPrintLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)card.fingerprint_index_list.count];
    nameLabel.text = card.user.name;
    accessGroupLabel.text = card.access_groups.count ? card.access_groups[0].name : NSBaseLocalizedString(@"none", nil);
    
    NSString *startDateStr =  [CommonUtil stringFromDateString:card.start_datetime originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'" transDateFormat:[NSString stringWithFormat:@"%@ %@", [LocalDataManager getDateFormat], [LocalDataManager getTimeFormat]]];
    
    
    NSString *expiryDateStr =  [CommonUtil stringFromDateString:card.expiry_datetime originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'" transDateFormat:[NSString stringWithFormat:@"%@ %@", [LocalDataManager getDateFormat], [LocalDataManager getTimeFormat]]];
    
    periodLabel.text = [NSString stringWithFormat:@"%@ - %@", startDateStr, expiryDateStr];
    
    CardType cardType = [card.type cardTypeEnumFromString];
    if (cardType == SECURE_CREDENTIAL)
    {
        cardTitleLabel.text = NSBaseLocalizedString(@"secure_card", nil);
        [periodLabel setHidden:YES];
        [periodDecLabel setHidden:YES];
        [accessGroupLabel setHidden:YES];
        [accessGroupDecLabel setHidden:YES];
    }
    else
    {
        cardTitleLabel.text = NSBaseLocalizedString(@"access_on_card", nil);
        [periodLabel setHidden:NO];
        [periodDecLabel setHidden:NO];
        [accessGroupLabel setHidden:NO];
        [accessGroupDecLabel setHidden:NO];
    }
    
    
}

- (void)checkAndStartBLEMonitoring
{
    if (BLEIsReady && mobileCredentialIsLoaded)
    {
        NSDictionary *credentialDic = [LocalDataManager getMobileCredential];
        
        if (mobileCard.is_registered) // 등록된 카드가 있을 경우
        {
            if (credentialDic.count > 0)
            {
                BLECredential *blecredential = [mapper objectFromSource:credentialDic toInstanceOfClass:[BLECredential class]];
                
                if ([mobileCard.id isEqualToString:blecredential.id])
                {
                    //NSLog(@"getRawData : %@", [blecredential getRawData]);
                    
                    if ([LocalDataManager getUserMlbileCredentialStatus])
                    {
                        [cbController loadMobileCredential];
                        [cbController scanBLE];
                    }
                    
                    [registDecView setHidden:YES];
                    [registButton setHidden:YES];
                    
                }
                else
                {
                    // 등록된 카드와 현재 스마트폰에 저장된 카드가 다른 경우
                    registDecLabel.text = NSBaseLocalizedString(@"invalid_card", nil);
                    [registDecView setHidden:NO];
                    [registButton setHidden:YES];
                    
                    testLabel.text = @"저장된 카드와 서버에서 가져온 카드가 틀림";
                }
                
                
            }
            else
            {
                // 스마트폰에 저장된 카드가 없는데 등록된 카드가 있는 경우
                registDecLabel.text = NSBaseLocalizedString(@"invalid_card", nil);
                [registDecView setHidden:NO];
                [registButton setHidden:YES];
                //[self.view makeToast:NSBaseLocalizedString(@"none_data", nil) duration:1 position:CSToastPositionBottom image:[UIImage imageNamed:@"toast_popup_i_03"]];
            }
        }
        else
        {
            registDecLabel.text = NSBaseLocalizedString(@"guide_register_mobile_card3", nil);
            [registDecView setHidden:NO];
            [registButton setHidden:NO];
            
        }
    }
    
    
    
}

- (IBAction)moveToSetting:(id)sender
{
    [resetTimer invalidate];
    [failTimer invalidate];
    resetTimer = nil;
    failTimer = nil;
    
    [cbController disconnectGATT];
    
    testLabel.text = @"셋팅 이동";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingViewController *settingViewController = [storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    
    
    [settingViewController setUserID:[AuthProvider getLoginUserInfo].user_id];
    [self pushChildViewController:settingViewController
             parentViewController:self
                      contentView:contentView animated:YES];
}

- (IBAction)registMobileCredential:(id)sender
{
    [self startLoading:self];
    
    [userProvider registerMobileCredential:mobileCard.id UUID:[LocalDataManager getUUID] responseBlock:^(MobileCredentialRegisterResponse *response) {
        
        [registDecView setHidden:YES];
        [self finishLoading];
        
        BLECredential *tempMobileCredential = [BLECredential new];
        tempMobileCredential.id = mobileCard.id;
        tempMobileCredential.raw = response.raw;
        tempMobileCredential.smart_card_layout_primary_key = response.smart_card_layout_primary_key;
        tempMobileCredential.smart_card_layout_second_key = response.smart_card_layout_second_key;
        
        NSDictionary *credentialDic = [mapper dictionaryFromObject:tempMobileCredential];
        
        [LocalDataManager deleteMobileCredential];
        [LocalDataManager setMobileCredential:credentialDic];
        
        [self.view makeToast:NSBaseLocalizedString(@"register_mobile_card", nil)
                    duration:1.0
                    position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_03"]];
        
        
        [self getMobileCredential];
        
    } onErrorBlock:^(Response *error) {
        
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = MAIN_REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self getMobileCredential];
            }
        }];
        
    }];
}

- (IBAction)deleteMobileCredential:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.type = WARNING;
    imagePopupCtrl.titleContent = NSBaseLocalizedString(@"delete_confirm_question", nil);
    [imagePopupCtrl setContent:NSBaseLocalizedString(@"delete_confirm_question", nil)];
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
    
    [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
        
        if (isConfirm)
        {
            [LocalDataManager deleteMobileCredential];
            [registDecView setHidden:YES];
            
            //[self disconnectGATT];
        }
    }];
    
    
}

- (void)setResetTimer
{
    if (resetTimer)
    {
        [resetTimer invalidate];
        resetTimer = nil;
    }
    
    resetTimer = [NSTimer scheduledTimerWithTimeInterval:RESET_INTERVAL target:self selector:@selector(scanDevice) userInfo:nil repeats:NO];
}

- (void)setFailTimer
{
    if (failTimer)
    {
        [failTimer invalidate];
        failTimer = nil;
    }
    
    failTimer = [NSTimer scheduledTimerWithTimeInterval:FAIL_INTERVAL target:self selector:@selector(scanDevice) userInfo:nil repeats:NO];
}

- (void)isValidMobileCredential:(BOOL)isValid
{
    
    if (isValid)
    {
        [self setResetTimer];
        resultImageView.image = [UIImage imageNamed:@"ic_access_success"];
        
        gradientBackGround.colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0x2b4557).CGColor, (id)UIColorFromRGB(0x163243).CGColor, nil];
    }
    else
    {
        [self setFailTimer];
        resultImageView.image = [UIImage imageNamed:@"ic_access_fail2"];
        gradientBackGround.colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0x612021).CGColor, (id)UIColorFromRGB(0x4c0d0d).CGColor, nil];
    }
    [resultImageView setHidden:NO];
}

- (void)didFailToBLECommunication
{
    resultImageView.image = [UIImage imageNamed:@"ic_access_fail1"];
    gradientBackGround.colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0x612021).CGColor, (id)UIColorFromRGB(0x4c0d0d).CGColor, nil];
    [resultImageView setHidden:NO];
    //[self disconnectGATT];
    [self setFailTimer];
}



- (double)getDistance:(int)rssi txPower:(int)txPower
{
    /*
     * RSSI = TxPower - 10 * n * lg(d)
     * n = 2 (in free space)
     *
     * d = 10 ^ ((TxPower - RSSI) / (10 * n))
     */
    
    return pow(10, ((double) txPower - rssi) / (10 * 2));
}

- (void)scanDevice
{
    [cbController stopScan];
    [cbController scanBLE];
}

- (void)getMobileCredential
{
    [self startLoading:self];
    
    [userProvider getMyMobileCredentials:^(MobileCredentialList *result) {
        
        [self finishLoading];
        if (result.mobile_credential_list.count > 0)
        {
            mobileCard = result.mobile_credential_list[0];
        }
        
        // ble 및 beacon 셋팅
        if (mobileCard)
        {
            [self setMobileCardContent:mobileCard user:currentUser];
            [mobileCredentialView setHidden:NO];
            mobileCredentialIsLoaded = YES;
            
            [registDecView setHidden:mobileCard.is_registered];
            [registButton setHidden:mobileCard.is_registered];
            
            [self checkAndStartBLEMonitoring];
            
        }
        else
        {
            [self.view makeToast:NSBaseLocalizedString(@"none_data", nil) duration:1 position:CSToastPositionBottom image:[UIImage imageNamed:@"toast_popup_i_03"]];
        }
        
    } onErrorBlock:^(Response *error) {
        
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = MAIN_REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self getMobileCredential];
            }
        }];
        
    }];
    
}


- (void)reqisterMobileCredential:(GetMobileCredential*)card
{
    [self startLoading:self];
    
    [userProvider registerMobileCredential:card.id UUID:[LocalDataManager getUUID] responseBlock:^(MobileCredentialRegisterResponse *response) {
        
        [self finishLoading];
        
        BLECredential *tempMobileCredential = [BLECredential new];
        tempMobileCredential.id = card.id;
        tempMobileCredential.raw = response.raw;
        tempMobileCredential.smart_card_layout_primary_key = response.smart_card_layout_primary_key;
        tempMobileCredential.smart_card_layout_second_key = response.smart_card_layout_second_key;
        
        NSDictionary *credentialDic = [mapper dictionaryFromObject:tempMobileCredential];
        
        [LocalDataManager setMobileCredential:credentialDic];
        
        [self getMobileCredential];
        
    } onErrorBlock:^(Response *error) {
        
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = MAIN_REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self getMobileCredential];
            }
        }];
        
    }];
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_DID_ENTER_BACKGROUND object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_WILL_ENTER_FOREGROUND object:nil];
    
    [cbController disconnectGATT];
    
    [resetTimer invalidate];
    resetTimer = nil;
    [failTimer invalidate];
    failTimer = nil;
    [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
}



#pragma mark - MobileCellDelegate

- (void)reauestRetisterOrReissue:(UITableViewCell*)cell
{
    
    if (!mobileCard.is_registered)
    {
        [self reqisterMobileCredential:mobileCard];
    }
}

#pragma mark - CBManagerDelegate

- (void)BLEConnectionStatusChanged:(BLEConnectionStatus)connectionStatus
{
    
    switch (connectionStatus) {
        case POWER_OFF:
            NSLog(@"POWER_OFF");
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            OneButtonPopupViewController *oneButtonPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonPopupViewController"];
            oneButtonPopupCtrl.type = BLE_POWER_OFF;
            
            [self showPopup:oneButtonPopupCtrl parentViewController:self parentView:self.view];
            
            [oneButtonPopupCtrl getResponse:^(OneButtonPopupType type) {
                [self moveToBack:nil];
            }];
        }
            break;
        case READY_TO_SCAN:
            BLEIsReady = YES;
            break;
            
        case SCANNING:
        {
            NSLog(@"블루투스 스캔 시작");
            [self startAnimation];
            gradientBackGround.colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0x302c2d).CGColor, (id)UIColorFromRGB(0x131212).CGColor, nil];
            
            testLabel.text = @"블루투스 스캔 시작";
        }
            
            break;
            
        case TRYING_TO_SCAN:
            
            break;
            
        case CONNECTING:
            
            break;
        case FAIL_TO_CONNECT:
            break;
        case CONNECTED:
            
            break;
            
        case DISCONNECTED:
            [self stopAnimation];
            break;
        case DISCONNECTED_WITH_ERROR:
            [self didFailToBLECommunication];
            [self stopAnimation];
            break;
        case STATUS_NONE:
            
            break;
        
        case SUCCESS_TRANSACTION:
            [self isValidMobileCredential:YES];
            break;
        case FAILED_TRANSACTION:
            [self isValidMobileCredential:NO];
            break;
    }
}

@end
