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
    
    [blockButton setTitle:NSLocalizedString(@"block", nil) forState:UIControlStateNormal];
    [releaseButton setTitle:NSLocalizedString(@"unblock", nil) forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContent:(Card*)card mode:(BOOL)isDeleteMode viewMode:(BOOL)isProfile
{
    CardType cardType = [card.type cardTypeEnumFromString];
    
    switch (cardType) {
        case CSN:
            cardIDLabel.text = card.card_id;
            cardTypeLabel.text = NSLocalizedString(@"csn", nil);
            break;
        case CSN_WIEGAND:
        case WIEGAND:
            cardIDLabel.text = card.card_id;
            cardTypeLabel.text = NSLocalizedString(@"wiegand", nil);
            break;
            
        case SECURE_CREDENTIAL:
            if (card.is_mobile_credential)
            {
                cardTypeLabel.text = [NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"secure_card", nil) ,NSLocalizedString(@"mobile", nil)];
            }
            else
            {
                cardTypeLabel.text = NSLocalizedString(@"secure_card", nil);
            }
            cardIDLabel.text = ([card.issue_count integerValue] > 1) ? [NSString stringWithFormat:@"%@(%@ %@)", card.card_id, NSLocalizedString(@"issue_card_count", nil), card.issue_count ]: card.card_id;
            break;
            
        case ACCESS_ON:
            if (card.is_mobile_credential)
            {
                cardTypeLabel.text = [NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"access_on_card", nil) ,NSLocalizedString(@"mobile", nil)];
            }
            else
            {
                cardTypeLabel.text = NSLocalizedString(@"access_on_card", nil);
            }
            cardIDLabel.text = ([card.issue_count integerValue] > 1) ? [NSString stringWithFormat:@"%@(%@ %@)", card.card_id, NSLocalizedString(@"issue_card_count", nil), card.issue_count ]: card.card_id;
            break;
    }
    
    if (isDeleteMode)
    {
        UIColor *BGColor;
        if (card.is_blocked)
        {
            BGColor = card.isSelected ? UIColorFromRGB(0xf7ce86) : UIColorFromRGB(0xdcdcdc);
            [self.contentView setBackgroundColor:BGColor];
        }
        else
        {
            BGColor = card.isSelected ? UIColorFromRGB(0xf7ce86) : [UIColor whiteColor];
            [self.contentView setBackgroundColor:BGColor];
        }
        
        [checkImage setHidden:!card.isSelected];
        [blockButton setHidden:YES];
        [releaseButton setHidden:YES];
    }
    else
    {
        [checkImage setHidden:YES];
        UIColor *BGColor = card.is_blocked ? UIColorFromRGB(0xdcdcdc) : [UIColor whiteColor];
        [self.contentView setBackgroundColor:BGColor];
        [blockButton setHidden:card.is_blocked];
        [releaseButton setHidden:!card.is_blocked];
    }

    if (isProfile)
    {
        [blockButton setHidden:YES];
        [releaseButton setHidden:YES];
    }
}

- (IBAction)block:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(blockCard:)])
    {
        [self.delegate blockCard:self];
    }
}

- (IBAction)release:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(releaseCard:)])
    {
        [self.delegate releaseCard:self];
    }
}
@end
