//
//  MobileCardViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 9. 29..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CustomLabel.h"
#import "CardCell.h"
#import "MobileCardHelpViewController.h"
#import "User.h"
#import "UserProvider.h"
#import "ImagePopupViewController.h"


@interface MobileCardViewController : BaseViewController <MobileCellDelegate>
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *totalCountLabel;
    __weak IBOutlet CustomLabel *totalDiscriptionLabel;
    __weak IBOutlet NSLayoutConstraint *discriptionConstraint;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UITableView *cardTableView;
    
    CGFloat cellHeight;
    UserProvider *userProvider;
    User *currentUser;
    NSMutableArray <Card*> *mobileCredintials;
}

- (void)setCurrentUser:(User*)user;
- (void)getMobileCredential;
- (void)reqisterMobileCredential:(NSString*)cardRecodID;
- (void)requestReissueMobileCredential:(NSString*)cardRecodID;
@end
