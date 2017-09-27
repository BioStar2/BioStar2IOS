//
//  MobileCardViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 9. 29..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CustomLabel.h"
#import "CardCell.h"
#import "MobileCardHelpViewController.h"
#import "User.h"
#import "UserProvider.h"
#import "ImagePopupViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLECredential.h"
#import "TKAESCCMCryptor.h"
#import "SettingViewController.h"
#import "NSString+EnumParser.h"
#import <Lottie/Lottie.h>
#import "CBCentralManagerController.h"


#define TAG_LENGTH                              24
#define RESET_INTERVAL                          7
#define FAIL_INTERVAL                           3

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface MobileCardViewController : BaseViewController <MobileCellDelegate, CBManagerDelegate>
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UILabel *registDecLabel;
    __weak IBOutlet UIView *registDecView;
    __weak IBOutlet UIButton *registButton;
    __weak IBOutlet UIView *mobileCredentialView;
    __weak IBOutlet UILabel *cardTitleLabel;
    __weak IBOutlet UILabel *cardDecLabel;
    __weak IBOutlet UILabel *cardNumberLabel;
    __weak IBOutlet UILabel *credentialLabel;
    __weak IBOutlet UILabel *accessGroupDecLabel;
    __weak IBOutlet UILabel *accessGroupLabel;
    __weak IBOutlet UILabel *periodDecLabel;
    __weak IBOutlet UILabel *periodLabel;
    __weak IBOutlet UILabel *nameLabel;
    __weak IBOutlet UIImageView *cardPhoto;
    __weak IBOutlet UILabel *fingerPrintLabel;
    __weak IBOutlet UIImageView *resultImageView;
    __weak IBOutlet UIView *BGView;
    __weak IBOutlet NSLayoutConstraint *cardViewConstraint;
    __weak IBOutlet UIView *animationView;
    
    BOOL isRegistered;
    
    BOOL BLEIsReady;
    BOOL mobileCredentialIsLoaded;
    
    
    UserProvider *userProvider;
    User *currentUser;
    
    GetMobileCredential *mobileCard;
    
    
    NSTimer *resetTimer;
    NSTimer *failTimer;
    BOOL isPINDataSend; // 헤더와 카드 아이디만 요청받고 end 리퀘스트 왔을때 판단
    
    CAGradientLayer *gradientBackGround;
    
    ObjectMapper *mapper;
    InCodeMappingProvider *mappingProvider;
    LOTAnimationView *animation;
    __weak IBOutlet UILabel *errorLabel;
    __weak IBOutlet UILabel *testLabel;
    
    CBCentralManagerController *cbController;
}

@property (nonatomic, strong) CBPeripheral *cbPeripheral;

typedef void (^encrypt_card_callback)(NSData *data);
typedef void (^encrypt_error_callback)(NSError *error);


- (void)setMobileCardContent:(GetMobileCredential*)card user:(User*)user;
- (IBAction)moveToSetting:(id)sender;
- (IBAction)registMobileCredential:(id)sender;
- (IBAction)deleteMobileCredential:(id)sender;
- (void)isValidMobileCredential:(BOOL)isValid;
- (void)didFailToBLECommunication;
- (void)startAnimation;
- (void)stopAnimation;
- (void)setResetTimer;
- (void)setFailTimer;


- (void)checkAndStartBLEMonitoring;

- (double)getDistance:(int)rssi txPower:(int)txPower;
- (void)setCurrentUser:(User*)user;
- (void)getMobileCredential;
- (void)reqisterMobileCredential:(GetMobileCredential*)card;


@end
