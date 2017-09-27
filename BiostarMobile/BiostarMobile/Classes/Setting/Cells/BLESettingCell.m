//
//  BLESettingCell.m
//  BiostarMobile
//
//  Created by 정의석 on 2017. 3. 6..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import "BLESettingCell.h"

@implementation BLESettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    titleLabel.text = NSBaseLocalizedString(@"BLE", nil);
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)setUseMobileCredential:(UISwitch *)sender
{
    if ([self.delegate respondsToSelector:@selector(BLEuseStatusHasChanged:)])
    {
        [self.delegate BLEuseStatusHasChanged:sender.isOn];
    }
    
}

- (void)setBLEUsage:(BOOL)usage
{
    [settingSwitch setOn:usage];
}

@end
