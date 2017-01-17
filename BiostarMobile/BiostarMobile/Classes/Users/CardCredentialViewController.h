//
//  CardCredentialViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 16..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "BaseViewController.h"
#import "CardProvider.h"
#import "FingerprintTemplate.h"
#import "CardAddViewController.h"
#import "MobileCredentialCell.h"
#import "CardCredentialCell.h"
#import "UserProvider.h"
#import "AuthProvider.h"

@protocol CardCredentialDelegate <NSObject>

@optional

- (void)cardDidChanged:(NSArray<Card*>*)cards;

@end

@interface CardCredentialViewController : BaseViewController <MobileCredentialCellDelegate, CardCredentialCellDelegate, CardAddViewControllerDelegate>
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UITableView *contentTableView;
    __weak IBOutlet UILabel *totalCountLabel;
    __weak IBOutlet UIView *totalCountView;
    __weak IBOutlet UILabel *totalCount;
    __weak IBOutlet UIView *verificationSelectView;
    __weak IBOutlet UIView *editButtonView;
    __weak IBOutlet UIView *doneButtonView;
    __weak IBOutlet UIButton *selectAllButton;
    __weak IBOutlet UILabel *totalDecLabel;
    __weak IBOutlet UILabel *selectTotalDecLabel;
    
    User *currentUser;
    BOOL isCardChanged;
    NSMutableArray <FingerprintTemplate *>*fingerPrintTemplates;        // 지문 정보들(스마트 카드에서 사용할때)
    NSMutableArray <Card*> *userCards;
    NSMutableArray <Card* >*toDeleteArray;
    Card *mobileCard;
    CardProvider *cardProvider;
    UserProvider *userProvier;
    
    BOOL isDeleteMode;
    BOOL isSelectedAll;
    BOOL isForSwitchIndex;
}


@property (assign, nonatomic) BOOL isProfileMode;
@property (weak, nonatomic) id <CardCredentialDelegate> delegate;


- (IBAction)addVerification:(id)sender;
- (IBAction)moveToBack:(id)sender;
- (IBAction)deleteVerification:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)selectAll:(UIButton *)sender;
- (void)setUserVeryfications:(User*)user;
- (void)getUserCards;
- (void)checkToBeDeletedCard;
- (void)deleteMobileCard;
- (void)updateUserCards;
- (void)blockCurrentCard:(Card*)card;
- (void)releaseCurrentCard:(Card*)card;
- (void)reissueMobileCard:(Card*)card;
@end
