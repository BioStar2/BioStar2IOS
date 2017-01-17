//
//  CardAddInfoCell.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 4..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "CardAddInfoCell.h"
#import "Common.h"

@implementation CardAddInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
    
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted)
    {
        [self.contentView setBackgroundColor:UIColorFromRGB(0xf7ce86)];
    }
    else
    {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)setTitle:(NSString*)title content:(NSString*)content
{
    titleLabel.text = title;
    contentLabel.text = content;
}

- (NSString*)getTitle
{
    return titleLabel.text;
}
@end
