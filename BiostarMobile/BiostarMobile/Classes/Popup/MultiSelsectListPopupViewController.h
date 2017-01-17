//
//  MultiSelsectListPopupViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 16..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "BaseViewController.h"
#import "RadioCell.h"
#import "FingerprintTemplate.h"
#import "SimpleModel.h"


@interface MultiSelsectListPopupViewController : BaseViewController
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UITableView *contentTableView;
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet NSLayoutConstraint *heightConstraint;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UIButton *confirmBtn;
    
    NSMutableArray *templates;
    NSMutableArray <NSNumber *>*fingerprintIndexs;
    NSUInteger maxCount;
}


typedef void (^SelectedIndexsBlock)(NSArray <NSNumber *> *fingerprintIndexs);


@property (nonatomic, strong) SelectedIndexsBlock selectedIndexsBlock;


- (IBAction)cancelCurrentPopup:(id)sender;
- (IBAction)confirmCurrentPopup:(id)sender;
- (void)setFingerprintTeaplatesCount:(NSInteger)count maxFingerprintCount:(NSInteger)maxFingerprintCount;
- (void)adjustHeight:(NSInteger)count;
- (void)getSelectedIndexsBlock:(SelectedIndexsBlock)selectedIndexsBlock;


@end
