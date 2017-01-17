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
#import "SelectModel.h"

typedef enum
{
    MORNITORING,
    PHOTO,
} OneButtonTablePopupType;


@interface OneButtonTablePopupViewController : BaseViewController
{
    __weak IBOutlet UITableView *radioTableView;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UIButton *confirmBtn;
    
    NSMutableArray <SelectModel*> *contentListArray;
    NSInteger selectedIndex;
    
    SelectModel *selectedModel;
}

typedef void (^TablePopupModelResponseBlock)(SelectModel *selectedModel);
typedef void (^TablePopupIndexResponseBlock)(NSInteger index);

@property (assign, nonatomic) OneButtonTablePopupType type;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) TablePopupModelResponseBlock modelResponseBlock;
@property (nonatomic, strong) TablePopupIndexResponseBlock indexResponseBlock;


- (void)setContentModelArray:(NSArray<SelectModel*>*)array;
- (void)setContentStringArray:(NSArray<NSString*>*)names;
- (void)getIndexResponse:(TablePopupIndexResponseBlock)responseBlock;
- (void)getModelResponse:(TablePopupModelResponseBlock)responseBlock;
- (IBAction)confirmSelection:(id)sender;
- (IBAction)cancelCurrentPopup:(id)sender;

@end
