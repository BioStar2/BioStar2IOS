//
//  AccessGroupPopupViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 2..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "BaseViewController.h"
#import "AccessGroupProvider.h"
#import "ImagePopupViewController.h"
#import "RadioCell.h"

@interface AccessGroupPopupViewController : BaseViewController
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
    
    AccessGroupProvider *accessProvider;
    NSMutableArray <AccessGroupItem *>*userAccessGroups;        // 사용자에 설정된 액세스 그룹
    NSMutableArray <AccessGroupItem *>*accessGroups;            // 서버에서 받아온 액세스 그룹
    NSMutableArray <AccessGroupItem *>*selectedAccessGroups;    // 선택된 액세스 그룹 (추가할)
    AccessGroupItem *accessGroup;                               // 교체할 엑세스 그룹
    NSInteger selectedIndex;
    BOOL isMenuSelected;
    BOOL canMultiSelect;
    BOOL isLimited;
    NSUInteger limitCount;
    NSInteger totalCount;
}

typedef enum{
    EXCHANGE_ACCESS_GROUP,      // 사용자 편집에서 액세스 그룹 변경
    ADD_ACCESS_GROUP,           // 사용자 편집에서 액세스 그룹 추가
    
} AccessGroupPopupType;

typedef void (^AccessGroupsPopupBlock)(NSArray <AccessGroupItem*> *accessGroups);
typedef void (^AccessGroupPopupBlock)(AccessGroupItem *accessGroup);

@property (assign, nonatomic) AccessGroupPopupType type;
@property (nonatomic, strong) AccessGroupsPopupBlock accessGroupsPopupBlock;
@property (nonatomic, strong) AccessGroupPopupBlock accessGroupPopupBlock;


- (void)setUserAccessGroups:(NSArray <UserItemAccessGroup*>*)savedAccessGroups;
- (void)getAccessGroupsBlock:(AccessGroupsPopupBlock)accessGroupsPopupBlock;
- (void)getAccessGroupBlock:(AccessGroupPopupBlock)accessGroupPopupBlock;


@end
