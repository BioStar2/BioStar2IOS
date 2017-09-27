//
//  TodayViewController.h
//  Widget
//
//  Created by 정의석 on 2017. 8. 3..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBCentralManagerController.h"
#import "LocalDataManager.h"
#import <AudioToolbox/AudioToolbox.h>

#define NSBaseLocalizedString(key,_comment) [[LocalizationHandlerUtil singleton] localizedString:key  comment:_comment]

@interface TodayViewController : UIViewController <CBManagerDelegate>
{
    CBCentralManagerController *cbController;
    __weak IBOutlet UILabel *settingLabel;
    __weak IBOutlet UIButton *openButton;
    __weak IBOutlet UISwitch *settingSwitch;
    
    BOOL isValidMobileCredential;
}

- (IBAction)scanBLE:(id)sender;
- (IBAction)setAutoscan:(id)sender;
- (void)checkValidMobileCredential;
- (BOOL)isValidMobileCredential;
- (BOOL)isSupportMobileCredential;
@end
