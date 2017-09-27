//
//  MobileCredentialCell.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 16..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "MobileCredentialCell.h"

@implementation MobileCredentialCell

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
    CGRect expectedLabelSize = [cardIDLabel.text boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading attributes:attributes context:nil];
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
    currentCard = card;
    cardIDLabel.text = ([card.issue_count integerValue] > 1) ? [NSString stringWithFormat:@"%@(%@ %@)", card.card_id, NSBaseLocalizedString(@"issue_card_count", nil), card.issue_count ]: card.card_id;
    
    CardType cardType = [card.type cardTypeEnumFromString];
    
    switch (cardType) {
        case CSN:
            cardTypeLabel.text = NSBaseLocalizedString(@"csn", nil);
            break;
            
        case WIEGAND:
        case CSN_WIEGAND:
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
            
            break;
    }
    
    [statusSwitch setOn:!card.is_blocked];
    
    if (isDeleteMode)
    {
        UIColor *BGColor;
        if (!card.is_blocked)
        {
            if (cardType == ACCESS_ON)
            {
                BGColor = card.isSelected ? UIColorFromRGB(0xf7ce86) : UIColorFromRGB(0xdcdcdc);
                [self.contentView setBackgroundColor:BGColor];
            }
            else
            {
                BGColor = card.isSelected ? UIColorFromRGB(0xf7ce86) : [UIColor whiteColor];
                [self.contentView setBackgroundColor:BGColor];
            }
            
        }
        else
        {
            BGColor = card.isSelected ? UIColorFromRGB(0xf7ce86) : [UIColor whiteColor];
            [self.contentView setBackgroundColor:BGColor];
        }
        
        [checkImage setHidden:!card.isSelected];
        [statusSwitch setHidden:YES];
        
        [statusButton setHidden:YES];
    }
    else
    {
        [checkImage setHidden:YES];
        
//        UIColor *BGColor = card.is_blocked ? UIColorFromRGB(0xdcdcdc) : [UIColor whiteColor];
//        [self.contentView setBackgroundColor:BGColor];
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        
        [statusSwitch setHidden:NO];
        [statusButton setHidden:NO];
        
        if (card.is_registered)
        {
            [statusButton setImage:[UIImage imageNamed:@"ic_card_used"] forState:UIControlStateNormal];
        }
        else
        {
            [statusButton setImage:[UIImage imageNamed:@"ic_card_request"] forState:UIControlStateNormal];
        }
    }
    
    if (isProfile)
    {
        [statusSwitch setEnabled:NO];
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

- (IBAction)requestReregisterMobileCard:(id)sender
{
//    if (currentCard.is_registered)
//    {
//        if ([self.delegate respondsToSelector:@selector(requestReregisterMobileCard:)])
//        {
//            [self.delegate requestReregisterMobileCard:currentCard];
//        }
//    }
}

@end
