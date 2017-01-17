//
//  CardCell.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 9. 29..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "CardCell.h"


@implementation CardCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    cardDecLabel.text = NSLocalizedString(@"card_id", nil);
    credentialLabel.text = NSLocalizedString(@"credential", nil);
    accessGroupDecLabel.text = NSLocalizedString(@"access_group", nil);
    periodDecLabel.text = NSLocalizedString(@"period", nil);
    disabledDecLabel.text = NSLocalizedString(@"disabled_card", nil);
    
    [switchButton addTarget:self action:@selector(disableCardTemporarily) forControlEvents:UIControlEventTouchUpInside];
}

- (void)disableCardTemporarily;
{
    isRegistered = !isRegistered;
    
    if (isRegistered)
    {
        [switchButton setImage:[UIImage imageNamed:@"toggle2_on"] forState:UIControlStateNormal];
    }
    else
    {
        [switchButton setImage:[UIImage imageNamed:@"toggle2_off"] forState:UIControlStateNormal];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)requestRegisterMobileCredential:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(reauestRetisterOrReissue:)])
    {
        [self.delegate reauestRetisterOrReissue:self];
    }
}

- (void)setMobileCardContent:(Card*)card user:(User*)user
{
    [togleView setHidden:card.is_registered];
    
    cardNumberLabel.text = card.card_id;
    
    fingerPrintLabel.text = [NSString stringWithFormat:@"%ld", user.fingerprint_count];
    nameLabel.text = user.name;
    accessGroupLabel.text = user.access_groups.count ? user.access_groups[0].name : NSLocalizedString(@"none", nil);
    
    NSString *startDateStr =  [CommonUtil stringFromDateString:user.start_datetime originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'" transDateFormat:[PreferenceProvider getDateFormat]];


    NSString *expiryDateStr =  [CommonUtil stringFromDateString:user.expiry_datetime originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'" transDateFormat:[PreferenceProvider getDateFormat]];
    
    periodLabel.text = [NSString stringWithFormat:@"%@ - %@", startDateStr, expiryDateStr];
    
    CardType cardType = [card.type cardTypeEnumFromString];
    if (cardType == SECURE_CREDENTIAL)
    {
        titleLabel.text = NSLocalizedString(@"secure_card", nil);
    }
    else
    {
        titleLabel.text = NSLocalizedString(@"access_on_card", nil);
    }
    
    if (card.is_registered)
    {
        [switchButton setImage:[UIImage imageNamed:@"toggle2_on"] forState:UIControlStateNormal];
    }
    else
    {
        [switchButton setImage:[UIImage imageNamed:@"toggle2_off"] forState:UIControlStateNormal];
    }
}
@end
