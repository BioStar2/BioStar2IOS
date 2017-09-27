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
#import "RadioCell.h"
#import "CardProvider.h"
#import "ImagePopupViewController.h"
#import "SelectModel.h"
#import "BioStarSetting.h"

@interface ListPopupViewController :BaseViewController
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UITableView *contentTableView;
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet NSLayoutConstraint *heightConstraint;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UIButton *confirmBtn;
    
    CardProvider *cardProvider;
    NSInteger selectedIndex;
    NSMutableArray <SelectModel*>*contentListArray;
    
}

typedef enum{
    
    CARD_OPTION,                    // 사용자 편집에서 카드 선택 옵션
    PEROID,                         // 사용자 편집에서 시작 만료 시간
    CARD_TYPE,
    SCAN_METHOD,
    REGISTRATION_POPUP,
    SMART_CARD_POPUP,
    WIGAND_CARD_POPUP
    
} PopupType;

typedef void (^ListPopupIndexResponseBlock)(NSInteger index);
typedef void (^ListPopupModelResponseBlock)(SelectModel *model);
typedef void (^ListPopupCancelBlock)();

@property (assign, nonatomic) PopupType type;
@property (nonatomic, strong) ListPopupIndexResponseBlock indexResponseBlock;
@property (nonatomic, strong) ListPopupModelResponseBlock modelResponseBlock;
@property (nonatomic, strong) ListPopupCancelBlock cancelBlock;
@property (nonatomic, strong) BioStarSetting *setiing;

- (IBAction)cancelCurrentPopup:(id)sender;
- (IBAction)confirmCurrentPopup:(id)sender;
- (void)addOptions:(NSArray <NSString*> *)names;
- (void)adjustHeight:(NSInteger)count;
- (void)getIndexResponseBlock:(ListPopupIndexResponseBlock)responseBlock;
- (void)getModelResponseBlock:(ListPopupModelResponseBlock)responseBlock;
- (void)getCancelBlock:(ListPopupCancelBlock)cancelBlock;
- (void)getWiegandCardFormats;
@end
