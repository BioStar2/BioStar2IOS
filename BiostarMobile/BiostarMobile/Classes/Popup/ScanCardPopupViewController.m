//
//  ScanCardPopupViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 8..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "ScanCardPopupViewController.h"

@interface ScanCardPopupViewController ()

@end

@implementation ScanCardPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSharedViewController:self];
    // Do any additional setup after loading the view.
    [self showPopupAnimation:containerView];
    deviceProvider = [[DeviceProvider alloc] init];
    cardProvider = [[CardProvider alloc] init];
    
    [confirmBtn setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    
    descriptionLabel.text = NSLocalizedString(@"card_on_device", nil);
    scanImage.image = [UIImage imageNamed:@"user_card1"];
    
    if (_deviceMode != SMART_CARD_MODE)
    {
        if ([PreferenceProvider isUpperVersion])
        {
            titleLabel.text = NSLocalizedString(@"read_card", nil);
        }
        else
        {
            titleLabel.text = NSLocalizedString(@"add_card", nil);
        }
        [self scanCard:self.deviceID];
    }
    else
    {
        titleLabel.text = NSLocalizedString(@"write_card", nil);
        if ([_cardType integerValue] == 0)
        {
            [self scanScureCard:self.secureCredential];
        }
        else
        {
            [self scanAccessOnCard:self.accessOnCredential];
        }
    }
    
    
    isRequesting = YES;
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

- (void)getScanCard:(ScanCardBlock)scanCardBlock
{
    self.scanCardBlock = scanCardBlock;
}

- (void)getScanedSmartCard:(ScanCardBlock)scanCardBlock
{
    self.scanCardBlock = scanCardBlock;
}

- (void)scanCard:(NSString*)scanDeviceID
{
    [self showPopupAnimation:containerView];
    
    [deviceProvider scanCard:scanDeviceID scanBlock:^(Card *scanCard) {
        
        if ([PreferenceProvider isUpperVersion])
        {
            if (self.scanCardBlock)
            {
                self.scanCardBlock(scanCard);
                self.scanCardBlock = nil;
            }
            [self closePopup:self parentViewController:self.parentViewController];
        }
        else
        {
            
            cardIDLabel.text = scanCard.card_id;
            isRequesting = NO;
            
            [cardConfirmView setHidden:NO];
            [scanImage setHidden:YES];
            [confirmButton setHidden:NO];
            [descriptionLabel setHidden:YES];
            
            scanedCard = scanCard;
        }
    } onError:^(Response *error) {
        // 재시도 할것인지에 대한 팝업 띄워주기
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        //imagePopupCtrl.delegate = self;
        imagePopupCtrl.type = REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self scanCard:scanDeviceID];
            }
            else
            {
                [self closePopup:self parentViewController:self.parentViewController];
            }
        }];
    }];
}



- (void)scanScureCard:(SecureCredential*)credential
{
    [self showPopupAnimation:containerView];
    
    [cardProvider makeSecureCredentialCard:credential resultBlock:^(AddResponse *response) {
        
        [self finishLoading];
        
        Card *newSecureCard = [Card new];
        newSecureCard.id = response.id;
        
        if (self.scanCardBlock)
        {
            self.scanCardBlock(newSecureCard);
            self.scanCardBlock = nil;
        }
        
        [self closePopup:self parentViewController:self.parentViewController];
        
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
                [self scanScureCard:credential];
            }
            else
            {
                [self closePopup:self parentViewController:self.parentViewController];
            }
        }];
        
    }];
}



- (void)scanAccessOnCard:(AccessOnCredential*)credential
{
    [self showPopupAnimation:containerView];
    
    [cardProvider makeAccessOnCard:credential resultBlock:^(AddResponse *response) {
        
        [self finishLoading];
        
        Card *newAccessOnCard = [Card new];
        newAccessOnCard.id = response.id;

        if (self.scanCardBlock)
        {
            self.scanCardBlock(newAccessOnCard);
            self.scanCardBlock = nil;
        }
        
        [self closePopup:self parentViewController:self.parentViewController];
        
        
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
                [self scanAccessOnCard:credential];
            }
            else
            {
                [self closePopup:self parentViewController:self.parentViewController];
            }
        }];
        
    }];
}



- (IBAction)confirmPopup:(id)sender
{
    if (self.scanCardBlock)
    {
        self.scanCardBlock(scanedCard);
        self.scanCardBlock = nil;
    }
    [self closePopup:self parentViewController:self.parentViewController];
}

- (void)setScanIndex:(NSInteger)index
{
    scanIndex = index;
    
}


@end
