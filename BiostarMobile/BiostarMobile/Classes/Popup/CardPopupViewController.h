//
//  CardPopupViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 15..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "BaseViewController.h"
#import "CardRadioCell.h"
#import "CardProvider.h"
#import "ImagePopupViewController.h"
#import "NSString+EnumParser.h"
#import "PreferenceProvider.h"

@interface CardPopupViewController : BaseViewController
{
    __weak IBOutlet NSLayoutConstraint *containerHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *tableViewTopConstraint;
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
    NSMutableArray <Card*> *cards;
    
    Card *selectedCard;
    NSString *query;
    NSInteger offset;
    NSInteger limit;
    NSInteger loadedItemCount;
    BOOL hasNextPage;
    BOOL isForSearch;
    DeviceMode deviceMode;
}


typedef void (^CardBlock)(Card *card);

@property (nonatomic, strong) CardBlock cardBlock;

- (void)setCardType:(DeviceMode)type;

- (void)getCardBlock:(CardBlock)cardBlock;

- (void)getCSNCards:(NSString*)searchQuery limit:(NSInteger)searchLimit offset:(NSInteger)searchOffset;

- (void)getWiegandCards:(NSString*)searchQuery limit:(NSInteger)searchLimit offset:(NSInteger)searchOffset;

- (void)getSmartCards:(NSString*)searchQuery limit:(NSInteger)searchLimit offset:(NSInteger)searchOffset;


- (IBAction)showSearchTextFieldView:(id)sender;

- (IBAction)cancelSearch:(id)sender;

- (void)adjustHeight:(NSInteger)count;

- (IBAction)cancelCurrentPopup:(id)sender;

- (IBAction)confirmCurrentPopup:(id)sender;


@end
