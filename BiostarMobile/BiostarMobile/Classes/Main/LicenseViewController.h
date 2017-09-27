//
//  LicenseViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2017. 3. 22..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import "BaseViewController.h"

@interface LicenseViewController : BaseViewController
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UITextView *licenseContentView;
    
}

- (IBAction)moveToBack:(id)sender;

@end
