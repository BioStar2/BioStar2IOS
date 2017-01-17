//
//  FingerPrintPopupViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 29..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "BaseViewController.h"
#import "RadioCell.h"
#import "SimpleModel.h"

@interface FingerPrintPopupViewController : BaseViewController
{
    __weak IBOutlet NSLayoutConstraint *containerHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *tableViewTopConstraint;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *searchTotalCountLabel;
    __weak IBOutlet UITableView *listTableView;
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UIView *multiSelectSearchView;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UIButton *confirmBtn;
    __weak IBOutlet UILabel *totalDecLabel;
    
    NSMutableArray *templates;
    NSMutableArray <NSNumber *>*fingerprintIndexs;
    NSUInteger maxCount;
    BOOL isLimited;
}


typedef void (^SelectedIndexsBlock)(NSArray <NSNumber *> *fingerprintIndexs);


@property (nonatomic, strong) SelectedIndexsBlock selectedIndexsBlock;


- (IBAction)cancelCurrentPopup:(id)sender;
- (IBAction)confirmCurrentPopup:(id)sender;
- (void)setFingerprintTeaplatesCount:(NSInteger)count maxFingerprintCount:(NSInteger)maxFingerprintCount;
- (void)adjustHeight:(NSInteger)count;
- (void)getSelectedIndexsBlock:(SelectedIndexsBlock)selectedIndexsBlock;


@end
