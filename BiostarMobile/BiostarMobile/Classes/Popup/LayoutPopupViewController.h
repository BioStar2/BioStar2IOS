//
//  LayoutPopupViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 16..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "BaseViewController.h"
#import "RadioCell.h"
#import "CardProvider.h"
#import "ImagePopupViewController.h"

@interface LayoutPopupViewController : BaseViewController
{
    __weak IBOutlet NSLayoutConstraint *containerHeightConstraint;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *searchTotalCountLabel;
    __weak IBOutlet UITableView *listTableView;
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UIView *multiSelectSearchView;
    __weak IBOutlet UIView *textView;
    __weak IBOutlet UITextField *searchTextField;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UIButton *confirmBtn;
    
    CardProvider *cardProvider;
    NSMutableArray <SmartCardLayout*> *cardLayouts;
    
    SmartCardLayout *selectedCardLayout;
    NSString *query;
    NSInteger offset;
    NSInteger limit;
    
    BOOL hasNextPage;
    BOOL isForSearch;
}


typedef void (^LayoutBlock)(SmartCardLayout *cardLayout);

@property (nonatomic, strong) LayoutBlock layoutBlock;

- (void)getCardLayoutBlock:(LayoutBlock)layoutBlock;

- (void)getCardLayouts:(NSString*)searchQuery limit:(NSInteger)searchLimit offset:(NSInteger)searchOffset;


- (IBAction)showSearchTextFieldView:(id)sender;

- (IBAction)cancelSearch:(id)sender;

- (void)adjustHeight:(NSInteger)count;

- (IBAction)cancelCurrentPopup:(id)sender;

- (IBAction)confirmCurrentPopup:(id)sender;


@end
