//
//  BLESwtichCell.m
//  BiostarMobile
//
//  Created by 정의석 on 2017. 8. 22..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import "BLESwtichCell.h"

@implementation BLESwtichCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBLESwitchCellContent:(NSString*)title usage:(BOOL)usage
{
    _titleLabel.text = title;
    _settingSwitch.on = usage;
}

- (IBAction)switchDidChange:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(useStatusHasChanged:)])
    {
        [self.delegate useStatusHasChanged:self];
    }
}

@end
