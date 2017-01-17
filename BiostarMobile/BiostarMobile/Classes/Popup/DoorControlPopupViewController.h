//
//  DoorControlPopupViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 10. 31..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "BaseViewController.h"
#import "DoorControlMenu.h"
#import "RadioCell.h"

@interface DoorControlPopupViewController : BaseViewController
{
    __weak IBOutlet NSLayoutConstraint *containerHeightConstraint;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *totalCountLabel;
    __weak IBOutlet UITableView *listTableView;
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UIButton *confirmBtn;
    __weak IBOutlet UILabel *totalDecLabel;
    
    NSMutableArray <DoorControlMenu *> *doorControlMenus;
    NSInteger selectedIndex;
    BOOL isMenuSelected;
}

typedef void (^DoorControlPopupIndexResponseBlock)(NSInteger index);

@property (nonatomic, strong) DoorControlPopupIndexResponseBlock indexResponseBlock;

- (void)adjustHeight:(NSInteger)count;
- (void)getIndexResponse:(DoorControlPopupIndexResponseBlock)indexResponseBlock;

@end
