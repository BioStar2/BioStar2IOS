//
//  HelpViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 9. 23..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "AuthProvider.h"
#import "UsersViewController.h"

@protocol HelpDelegate <NSObject>

- (void)mobileCardWasPressed;

@end

@interface HelpViewController : BaseViewController
{
    __weak IBOutlet UILabel *descriptionLabel;
    __weak IBOutlet UIButton *continuouslyCloseButton;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UIImageView *badgeAlertView;
    IBOutletCollection(UIButton) NSArray *buttons;
    IBOutletCollection(UILabel) NSArray *buttonLabels;
    __weak IBOutlet NSLayoutConstraint *bottomConstraint;
    IBOutletCollection(UIImageView) NSArray *dotBoxes;
    
    NSMutableArray *buttonDatas;
    
    SEL buttonsTouchDown;
    SEL buttonsTouchUpOutside;
    SEL buttonsTouchUpInside;
    
}

@property (nonatomic, weak) id <HelpDelegate> delegate;

- (IBAction)closeHelpView:(id)sender;
- (IBAction)closeHelpViewContinuously:(id)sender;
- (void)setMenuItems;

@end
