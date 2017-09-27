//
//  CardCredentialCell.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 16..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "CardCredentialCell.h"

@implementation CardCredentialCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (CGFloat)getIDLabelHeight
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:cardIDLabel.font, NSFontAttributeName, nil];
    
    CGSize maximumLabelSize = CGSizeMake(319, FLT_MAX);
    CGRect expectedLabelSize = [cardID boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading attributes:attributes context:nil];
    
    
    if (cardIDLabel.frame.size.height < expectedLabelSize.size.height)
    {
        
        return expectedLabelSize.size.height;
    }
    else
    {
        if (cardIDLabel.frame.size.height >= expectedLabelSize.size.height)
        {
            return expectedLabelSize.size.height;
        }
        return 0;
    }
    
    
}

- (void)setContent:(Card*)card mode:(BOOL)isDeleteMode viewMode:(BOOL)isProfile
{
    CardType cardType = [card.type cardTypeEnumFromString];
    
    cardID = ([card.issue_count integerValue] > 1) ? [NSString stringWithFormat:@"%@(%@ %@)", card.card_id, NSBaseLocalizedString(@"issue_card_count", nil), card.issue_count ]: card.card_id;
    switch (cardType) {
        case CSN:
            cardIDLabel.text = card.card_id;
            cardTypeLabel.text = NSBaseLocalizedString(@"csn", nil);
            break;
        case CSN_WIEGAND:
        case WIEGAND:
            cardIDLabel.text = card.card_id;
            cardTypeLabel.text = NSBaseLocalizedString(@"wiegand", nil);
            break;
            
        case SECURE_CREDENTIAL:
            if (card.is_mobile_credential)
            {
                cardTypeLabel.text = [NSString stringWithFormat:@"%@(%@)",NSBaseLocalizedString(@"secure_card", nil) ,NSBaseLocalizedString(@"mobile", nil)];
            }
            else
            {
                cardTypeLabel.text = NSBaseLocalizedString(@"secure_card", nil);
            }
            cardIDLabel.text = ([card.issue_count integerValue] > 1) ? [NSString stringWithFormat:@"%@(%@ %@)", card.card_id, NSBaseLocalizedString(@"issue_card_count", nil), card.issue_count ]: card.card_id;
            break;
            
        case ACCESS_ON:
            if (card.is_mobile_credential)
            {
                cardTypeLabel.text = [NSString stringWithFormat:@"%@(%@)",NSBaseLocalizedString(@"access_on_card", nil) ,NSBaseLocalizedString(@"mobile", nil)];
            }
            else
            {
                cardTypeLabel.text = NSBaseLocalizedString(@"access_on_card", nil);
            }
            cardIDLabel.text = ([card.issue_count integerValue] > 1) ? [NSString stringWithFormat:@"%@(%@ %@)", card.card_id, NSBaseLocalizedString(@"issue_card_count", nil), card.issue_count ]: card.card_id;
            break;
    }
    
    if (isDeleteMode)
    {
        UIColor *BGColor;
        if (card.is_blocked)
        {
            BGColor = card.isSelected ? UIColorFromRGB(0xf7ce86) : [UIColor whiteColor];
            [self.contentView setBackgroundColor:BGColor];
        }
        else
        {
            if (cardType == ACCESS_ON)
            {
                [self.contentView setBackgroundColor:UIColorFromRGB(0xdcdcdc)];
            }
            else
            {
                BGColor = card.isSelected ? UIColorFromRGB(0xf7ce86) : [UIColor whiteColor];
                [self.contentView setBackgroundColor:BGColor];
            }
            
        }
        
        [checkImage setHidden:!card.isSelected];
        [statusSwitch setHidden:YES];
    }
    else
    {
        [checkImage setHidden:YES];
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        [statusSwitch setHidden:NO];
        [statusSwitch setOn:!card.is_blocked];
    }

    if (isProfile)
    {
        [statusSwitch setHidden:YES];
    }
}


- (IBAction)blockOrReleaseCard:(UISwitch *)sender
{
    if (sender.isOn)
    {
        if ([self.delegate respondsToSelector:@selector(releaseCard:)])
        {
            [self.delegate releaseCard:self];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(blockCard:)])
        {
            [self.delegate blockCard:self];
        }
    }
}
@end
