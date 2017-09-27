//
//  MornitoringPopupViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2017. 2. 9..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import "BaseViewController.h"
#import "EventLogResult.h"
#import "EventProvider.h"
#import "PreferenceProvider.h"

@interface MornitoringPopupViewController : BaseViewController
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UIButton *confirmBtn;
    __weak IBOutlet UITextView *contentTextView;
    
    
}


- (IBAction)closePopup:(id)sender;
- (void)setContent:(EventLogResult*)event;
- (NSString*)getDiscription:(EventType *)eventType;
- (NSString*)getDate:(EventLogResult *)event;
@end
