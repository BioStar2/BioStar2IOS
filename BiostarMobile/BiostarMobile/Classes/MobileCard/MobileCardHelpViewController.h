//
//  MobileCardHelpViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 10. 4..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CardHelpCell.h"

@interface MobileCardHelpViewController : BaseViewController
{
    __weak IBOutlet UIButton *continuouslyCloseButton;
    __weak IBOutlet UIView *contentView;
    CGFloat cellHeight;
}

- (IBAction)closeHelpView:(id)sender;
- (IBAction)closeHelpViewContinuously:(id)sender;
- (IBAction)closeViewContinuously:(id)sender;

@end
