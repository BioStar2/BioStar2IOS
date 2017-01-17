/*
 * Copyright 2015 Suprema(biostar2@suprema.co.kr)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "AuthProvider.h"
#import "UserProvider.h"
#import "ScanPopupViewController.h"
#import "VerificationCell.h"
#import "ListSubInfoPopupViewController.h"
#import "AccessGroupPopupViewController.h"
#import "ImagePopupViewController.h"
#import "DevicePopupViewController.h"
#import "CardPopupViewController.h"
#import "ScanQualityPopupViewController.h"
#import "ScanCardPopupViewController.h"

@protocol UserVerificationAddViewControllerDelegate <NSObject>

@optional

- (void)fingerprintWasChanged:(NSArray<FingerprintTemplate*>*)fingerprintTemplates;
- (void)accessGroupDidChange:(NSArray<UserItemAccessGroup*>*)groups;
- (void)cardWasChanged:(NSArray<Card*>*)cards;
@end

@interface UserVerificationAddViewController : BaseViewController
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
    
    NSMutableArray <FingerprintTemplate *>*fingerPrintTemplates;        // 지문 정보들(화면에 테이블로 뿌려주기 위한)
    NSMutableArray <UserItemAccessGroup*> *userAccessGroups;            // access groups
    NSMutableArray <Card*> *userCards;                                  // user cards
    
    FingerprintTemplate *userFingerPrintTemplate;                       // 스캔 후에 verify 까지 끝난 정보
    FingerprintTemplate *fingerPrintResult;                           // 성공한 첫번째 스캔정보
    NSMutableArray *toDeleteArray;
    UserProvider *userProvider;
    User *currentUser;
    
    NSInteger fingerPrintScanCount;                                     // 지문 스캔 카운트 (실패했을때 저장하기 위한 용도)
    NSInteger scanIndex;                                                // 스캔 팝업에 몇번째인지 노출될 변수
    NSInteger maxFingerprintIndex;                                      // 지문 인덱스 중복을 막기위해 제일 높은 인덱스 + 1
    NSInteger toBeSwitchedIndex;                                        // 지문 인덱스 선택으로 바뀔 인덱스
    BOOL isSelectedAll;
    BOOL isForSwitchIndex;
    
    NSUInteger scanQuality;
    
    SearchResultDevice *selectedDevice;                                 // 지문 카드스캔을 위한 선택한 디바이스
    
}

typedef enum
{
    FINGERPRINT,
    ACCESS_GROUPS,
    CARD
    
} VerificationType;

@property (assign, nonatomic) BOOL isProfileMode;
@property (assign, nonatomic) VerificationType type;
@property (assign, nonatomic) id <UserVerificationAddViewControllerDelegate> delegate;

- (IBAction)addVerification:(id)sender;
- (IBAction)moveToBack:(id)sender;
- (IBAction)deleteVerification:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)selectAll:(UIButton *)sender;

- (void)setUserInfo:(User*)user;
- (void)deleteFingerprintTemplates;
- (void)getUserFingerprintTemplates;
- (void)updateFingerprintTemplages:(FingerprintTemplate*)fingerprintTemplate;
- (void)addFingerprint;
- (void)replaceFingerprint:(NSIndexPath*)indexPath;
- (void)addCard;
- (void)replaceCard:(NSIndexPath*)indexPath;
- (void)addAccessGroup;
- (void)replaceAccessGroup:(NSIndexPath*)indexPath;
- (BOOL)hasEqualCard:(Card*)card;
- (void)setFingerPrintTemplates:(NSArray<FingerprintTemplate*>*)templates;
- (void)setCards:(NSArray<Card*>*)cards;
- (void)setAccessGroup:(NSArray*)accessGroups withUserGroup:(NSArray*)userGroups;
- (void)showFingerprintScanPopup;


@end
