//
//  ScanCardPopupViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 8..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "BaseViewController.h"
#import "DeviceProvider.h"
#import "ImagePopupViewController.h"
#import "Card.h"
#import "CardProvider.h"
#import "PreferenceProvider.h"

@interface ScanCardPopupViewController : BaseViewController
{
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIImageView *scanImage;
    __weak IBOutlet UILabel *descriptionLabel;
    __weak IBOutlet UIButton *confirmButton;
    __weak IBOutlet UIView *cardConfirmView;
    __weak IBOutlet UILabel *cardIDLabel;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UIButton *confirmBtn;
    
    
    DeviceProvider *deviceProvider;
    CardProvider *cardProvider;
    Card *scanedCard;
    BOOL isRequesting;
    NSInteger scanIndex;
    
}

typedef void (^ScanCardBlock)(Card *scanCard);

@property (nonatomic, strong) ScanCardBlock scanCardBlock;


@property (assign, nonatomic) NSInteger scanCount;
@property (assign, nonatomic) NSInteger templateIndex;
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *cardType;
@property (assign, nonatomic) DeviceMode deviceMode;
@property (assign, nonatomic) SecureCredential *secureCredential;
@property (assign, nonatomic) AccessOnCredential *accessOnCredential;

- (void)getScanCard:(ScanCardBlock)scanCardBlock;

- (void)getScanedSmartCard:(ScanCardBlock)scanCardBlock;

- (void)setScanIndex:(NSInteger)index;

- (void)scanCard:(NSString*)scanDeviceID;

- (void)scanScureCard:(SecureCredential*)credential;

- (void)scanAccessOnCard:(AccessOnCredential*)credential;

- (IBAction)confirmPopup:(id)sender;


@end
