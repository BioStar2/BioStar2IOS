//
//  CardRadioCell.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 1..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "CardRadioCell.h"

@implementation CardRadioCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)checkSelected:(BOOL)isSelected
{
    if (isSelected)
    {
        [self.contentView setBackgroundColor:UIColorFromRGB(0xf7ce86)];
        [_checkImage setHidden:NO];
    }
    else
    {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        [_checkImage setHidden:YES];
    }
    
}

- (void)checkSelected:(BOOL)isSelected isLimited:(BOOL)isLimited
{
    if (!isLimited)
    {
        [self checkSelected:isSelected];
    }
    else
    {
        if (isSelected)
        {
            [self.contentView setBackgroundColor:UIColorFromRGB(0xf7ce86)];
            [_checkImage setHidden:NO];
        }
        else
        {
            [self.contentView setBackgroundColor:[UIColor grayColor]];
            [_checkImage setHidden:YES];
        }
    }
}

- (void)setCardType:(DeviceMode)addType card:(Card*)card isSelected:(BOOL)isSelected
{
    
    CardType cardType = [card.type cardTypeEnumFromString];
    
    
    switch (addType) {
        case CSN_CARD_MODE:
            if (cardType == CSN)
            {
                [self checkSelected:isSelected];
            }
            else
            {
                [self.contentView setBackgroundColor:[UIColor grayColor]];
                [_checkImage setHidden:YES];
            }
            break;
            
        case WIEGAND_CARD_MODE:
            if (cardType == WIEGAND || cardType == CSN_WIEGAND)
            {
                [self checkSelected:isSelected];
            }
            else
            {
                [self.contentView setBackgroundColor:[UIColor grayColor]];
                [_checkImage setHidden:YES];
            }
            break;
            
        case SMART_CARD_MODE:
            if (cardType == SECURE_CREDENTIAL || cardType == ACCESS_ON)
            {
                [self checkSelected:isSelected];
            }
            else
            {
                [self.contentView setBackgroundColor:[UIColor grayColor]];
                [_checkImage setHidden:YES];
            }
            break;
            
        default:
            break;
    }
}
@end
