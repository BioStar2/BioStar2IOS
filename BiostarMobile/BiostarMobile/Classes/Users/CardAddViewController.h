//
//  CardAddViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 4..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "BaseViewController.h"
#import "CardAddInfoCell.h"
#import "ListPopupViewController.h"
#import "DevicePopupViewController.h"
#import "ScanCardPopupViewController.h"
#import "WiegandFormatListPopupViewController.h"
#import "CardPopupViewController.h"
#import "LayoutPopupViewController.h"
#import "FingerPrintPopupViewController.h"
#import "CardInfoText.h"
#import "SimpleModel.h"
#import "CardProvider.h"
#import "UserProvider.h"
#import "FingerprintTemplate.h"
#import "User.h"
#import "MobileCredential.h"
#import "OneButtonPopupViewController.h"



#define MOBILE_CARD 0

@protocol CardAddViewControllerDelegate <NSObject>

@optional

- (void)addedCard:(Card*)card;

@end


@interface CardAddViewController : BaseViewController <CardInfoTextCellDelegate>
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UITableView *contentTableView;
    __weak IBOutlet NSLayoutConstraint *tableViewConstraint;
    __weak IBOutlet UIButton *saveButton;
    
    User *currentUser;
    Card *addedCard;
    NSArray<Card*> *userCards;
    BOOL isCardAdded;
    
    DeviceProvider *deviceProvider;
    CardProvider *cardProvider;
    UserProvider *userProvider;
    SearchResultDevice *selectedDevice;
    DeviceMode deviceMode;
    RegistrationType registrationType;
    
    Card *scanedCard;
    WiegandCard *wiegandCard;
    
    NSMutableArray <WiegandCardID*> *wiegandCardFormats;
    NSString *inputCardID;
    
    WiegandFormat *WIEGANDFormat;
    SimpleModel *smartCardType;
    SmartCardLayout *currentCardLayout;
    MobileCredential *mobileCredential;
    SecureCredential *secureCredential;
    AccessOnCredential *accessOnCredential;
    
}

@property (nonatomic, assign) id <CardAddViewControllerDelegate> delegate;

- (void)showListPopup:(PopupType)popupType;
- (void)showInvalidCardTypeToast;
- (void)showScanCardPopup;
- (void)showSmartCardScanCardPopup;
- (void)showDevicePopup;
- (void)showSmartCardPopup;
- (void)showWIEGANDCardDataTypePopup;
- (void)showUnassignedCardPopup;
- (void)showCardLayoutPopup;
- (void)showFingerPrintSelectPopup;
- (void)setUserVeryfications:(User*)user userCards:(NSArray<Card*>*)cards;
- (void)makeCSNCard:(NSString*)cardID;
- (void)assignCard:(Card*)card;
- (void)assignCSNCard;
- (void)assignWIEGANDCard;
- (void)assignSecureCard;
- (void)assignAccessOnCard;
- (void)issueMobileCredential;


- (UITableViewCell*)makeCSNCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell*)makeWIEGANDCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell*)makeSmartCardCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell*)makeMobileCardCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell*)makeCardReadingCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
