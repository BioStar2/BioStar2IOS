//
//  SideMenuCell.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 9. 19..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "SideMenuCell.h"

@implementation SideMenuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlightColor:(UIColor*)color
{
    self.contentView.backgroundColor = color;
    self.backgroundColor = color;
    
    
    if (color == [UIColor clearColor])
    {
        if (type == ALARM_BUTTON)
        {
            if ([countLable.text isEqualToString:@"0"])
            {
                [countImageView setImage:[UIImage imageNamed:@"list_normal_btn"]];
            }
            else
            {
                [countImageView setImage:[UIImage imageNamed:@"list_new_btn"]];
            }
        }
        else
        {
            [countImageView setImage:[UIImage imageNamed:@"list_normal_btn"]];
        }
    }
    else
    {
        [countImageView setImage:[UIImage imageNamed:@"list_btn_pre"]];
    }

}
    
- (void)setContent:(ButtonModel *)button
{
    type = button.type;
    menuIcon.image = button.icon;
    menuTitle.text = button.title;
    
    if (type == MONITORING_BUTTON || type == MOBILE_CARD_BUTTON)
    {
        [countView setHidden:YES];
    }
    else
    {
        [countView setHidden:NO];
        if (type == USER_BUTTON)
        {
            NSUInteger count = button.count;
            countLable.text = [NSString stringWithFormat:@"%ld", (long)count];
            
            NSInteger preUserCount = [LocalDataManager getUserCount];
            if (preUserCount > count)
            {
                [LocalDataManager setUserCount:count];
                // 뷰 색 변경
                [countImageView setImage:[UIImage imageNamed:@"list_new_btn"]];
            }
        }
        
        if (type == DOOR_BUTTON)
        {
            NSUInteger count = button.count;
            countLable.text = [NSString stringWithFormat:@"%ld", (long)count];
            
            NSInteger preDoorCount = [LocalDataManager getDoorCount];
            if (preDoorCount > count)
            {
                [LocalDataManager setDoorCount:count];
                // 뷰 색 변경
                [countImageView setImage:[UIImage imageNamed:@"list_new_btn"]];
            }
        }
        
        if (type == ALARM_BUTTON)
        {
            NSUInteger count = button.count;
            countLable.text = [NSString stringWithFormat:@"%ld", (long)count];
            
            if (count != 0)
            {
                [countImageView setImage:[UIImage imageNamed:@"list_new_btn"]];
            }
            else
            {
                [countImageView setImage:[UIImage imageNamed:@"list_normal_btn"]];
            }
            
            NSInteger badgeNumber = [countLable.text integerValue];
            
            if (badgeNumber > 999)
            {
                countLable.text = @"999+";
            }
            
        }

    }
}

@end
