//
//  WiegandFormatListPopupViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 19..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "BaseViewController.h"
#import "CardProvider.h"
#import "ImagePopupViewController.h"
#import "RadioCell.h"

@interface WiegandFormatListPopupViewController : BaseViewController
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UITableView *contentTableView;
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet NSLayoutConstraint *heightConstraint;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UIButton *confirmBtn;
    
    CardProvider *cardProvider;
    
    NSMutableArray <WiegandFormat*>*contentListArray;
    WiegandFormat *selectedFormat;
}



typedef void (^WiegandPopupModelResponseBlock)(WiegandFormat *model);



@property (nonatomic, strong) WiegandPopupModelResponseBlock modelResponseBlock;

- (IBAction)cancelCurrentPopup:(id)sender;
- (IBAction)confirmCurrentPopup:(id)sender;

- (void)adjustHeight:(NSInteger)count;



- (void)getModelResponseBlock:(WiegandPopupModelResponseBlock)modelResponseBlock;
- (void)getWiegandCardFormats;

@end
