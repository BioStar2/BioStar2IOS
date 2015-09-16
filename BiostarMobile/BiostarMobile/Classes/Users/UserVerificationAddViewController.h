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
#import "DeviceProvider.h"
#import "ListPopupViewController.h"
#import "ScanPopupViewController.h"
#import "VerificationCell.h"
#import "ListSubInfoPopupViewController.h"
#import "ImagePopupViewController.h"
#import "OneButtonPopupViewController.h"

typedef enum
{
    FINGERPRINT,
    CARD,
    ACCESS_GROUPS,
    OPERATOR,
    
} VerificationType;


@protocol UserVerificationAddViewControllerDelegate <NSObject>

@optional

- (void)fingerprintDidAdd:(NSArray*)fingerprintTemplates;
- (void)cardDidAdd:(NSArray*)cards;
- (void)accessGroupDidChange:(NSArray*)groups;
- (void)operatorValueDidChange:(NSArray*)operators;
@end

@interface UserVerificationAddViewController : BaseViewController <ListPopupViewControllerDelegate, ScanPopupViewControllerDelegate, DeviceProviderDelegate, ListSubInfoPopupDelegate, ImagePopupDelegate>
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
    
    NSMutableDictionary *infoDic;
    NSMutableDictionary *fingerPrintDic;    // 지문 정보 딕션어리
    NSMutableArray *verificationInfos;      // 카드, 지문 정보들(화면에 테이블로 뿌려주기 위한)
    NSMutableArray *toDeleteArray;
    DeviceProvider *deviceProvider;
    NSInteger fingerPrintScanCount;                    // 지문 스캔 카운트 (실패했을때 저장하기 위한 용도)
    NSInteger scanIndex;                    // 스캔 팝업에 몇번째인지 노출될 변수
    NSInteger maxFingerprintIndex;          // 지문 인덱스 중복을 막기위해 제일 높은 인덱스 + 1
    NSInteger toBeSwitchedIndex;            // 지문 인덱스 선택으로 바뀔 인덱스
    BOOL isSelectedAll;
    BOOL isForSwitchIndex;
    BOOL isForAPIRetry;
}

@property (assign, nonatomic) BOOL isProfileMode;
@property (assign, nonatomic) VerificationType type;
@property (assign, nonatomic) id <UserVerificationAddViewControllerDelegate> delegate;

- (IBAction)addVerification:(id)sender;
- (IBAction)moveToBack:(id)sender;
- (IBAction)deleteVerification:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)selectAll:(UIButton *)sender;
- (void)setVerificationInfo:(NSArray*)infos;
- (void)setAccessGroup:(NSArray*)accessGroup withUserGroup:(NSArray*)userGroup;
- (void)showScanPopup:(VerificationType)type;
- (void)setOperators:(NSArray*)operators;
@end
