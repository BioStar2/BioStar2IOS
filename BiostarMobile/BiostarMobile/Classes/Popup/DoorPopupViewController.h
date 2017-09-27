//
//  DoorPopupViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2017. 2. 10..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import "BaseViewController.h"
#import "RadioCell.h"
#import "DoorProvider.h"
#import "ImagePopupViewController.h"
#import "PreferenceProvider.h"

@interface DoorPopupViewController : BaseViewController
{
    __weak IBOutlet NSLayoutConstraint *containerHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *tableViewTopConstraint;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *totalDecLabel;
    __weak IBOutlet UILabel *searchTotalCountLabel;
    __weak IBOutlet UITableView *listTableView;
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UIView *multiSelectSearchView;
    __weak IBOutlet UIView *textView;
    __weak IBOutlet UITextField *searchTextField;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UIButton *confirmBtn;
    
    DoorProvider *doorProvider;
    
    
    NSMutableArray <ListDoorItem*> *doors;
    NSMutableArray <ListDoorItem*> *selectedDoors;
    
    NSString *query;
    NSInteger offset;
    NSInteger limit;
    
    BOOL multiSelect;
    BOOL hasNextPage;
    BOOL isForSearch;
    
    NSInteger loadedItemCount;
}

typedef void (^DoorsBlock)(NSArray <ListDoorItem*> *doors);

@property (nonatomic, strong) DoorsBlock doorsBlock;


- (void)getDoors:(DoorsBlock)doorsBlock;


- (void)getDoors:(NSString *)searchQuery limit:(NSInteger)searchLimit offset:(NSInteger)searchOffset;

- (IBAction)showSearchTextFieldView:(id)sender;


- (IBAction)cancelSearch:(id)sender;

- (void)adjustHeight:(NSInteger)count;

- (IBAction)cancelCurrentPopup:(id)sender;

- (IBAction)confirmCurrentPopup:(id)sender;


@end
