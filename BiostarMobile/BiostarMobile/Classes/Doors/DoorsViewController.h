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
#import "DoorCell.h"
#import "BaseViewController.h"
#import "DoorProvider.h"
#import "ImagePopupViewController.h"
#import "DoorDetailViewController.h"

@interface DoorsViewController : BaseViewController <DoorProviderDelegate, ImagePopupDelegate, DoorDetailViewControllerDelegate>
{
    __weak IBOutlet UITableView *doorsTableView;
    __weak IBOutlet UIView *countView;
    __weak IBOutlet UILabel *totalCountLabel;
    __weak IBOutlet UIView *textFieldView;
    __weak IBOutlet NSLayoutConstraint *tableViewHeight;
    __weak IBOutlet UIButton *scrollButton;
    
    NSMutableArray *doors;
    DoorProvider *provider;
    BOOL isMainRequest;
    NSString *query;
    BOOL canScrollTop;
    float firstYPosition;
    float secondYPosition;
    NSInteger limit;
    NSInteger offset;
    NSInteger totalCount;
    BOOL hasNextPage;
}

- (IBAction)showTextFieldView:(id)sender;
- (IBAction)cancelSearch:(id)sender;
- (IBAction)moveToBack:(id)sender;
- (IBAction)scrollTopOrBottom:(id)sender;
- (void)refreshDoors;
@end
