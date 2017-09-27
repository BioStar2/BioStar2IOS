//
//  CardHelpCell.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 10. 4..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "CardHelpCell.h"

@implementation CardHelpCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    for (NSInteger i = 0; i < 2; i ++)
    {
        UILabel *titleLabel = [titleLabels objectAtIndex:i];
        titleLabel.text = NSBaseLocalizedString(@"access_on_card", nil);
        
        UILabel *cardDecLabel = [cardDecLabels objectAtIndex:i];
        cardDecLabel.text = NSBaseLocalizedString(@"card_id", nil);
        
        UILabel *cardNumberLabel = [cardNumberLabels objectAtIndex:i];
        cardNumberLabel.text = @"4292967295";
        
        UILabel *credentialLabel = [credentialLabels objectAtIndex:i];
        credentialLabel.text = NSBaseLocalizedString(@"credential", nil);
        
        UILabel *accessGroupDecLabel = [accessGroupDecLabels objectAtIndex:i];
        accessGroupDecLabel.text = NSBaseLocalizedString(@"access_group", nil);
        
        UILabel *accessGroupLabel = [accessGroupLabels objectAtIndex:i];
        accessGroupLabel.text = @"brunch Swedeng";
        
        UILabel *periodDecLabel = [periodDecLabels objectAtIndex:i];
        periodDecLabel.text = NSBaseLocalizedString(@"period", nil);
        
        UILabel *periodLabel = [periodLabels objectAtIndex:i];
        periodLabel.text = @"2016.01.01 - 2030.12.31";
        
        UILabel *nameLabel = [nameLabels objectAtIndex:i];
        nameLabel.text = @"Simona Morascag";
        
        UILabel *fingerPrintLabel = [fingerPrintLabels objectAtIndex:i];
        fingerPrintLabel.text = @"b2";
        
        UILabel *disabledDecLabel = [disabledDecLabels objectAtIndex:i];
        disabledDecLabel.text = NSBaseLocalizedString(@"disabled_card", nil);
        
        UILabel *helpDec = [helpDecs objectAtIndex:i];
        if (i == 0)
        {
            NSString *dec = [NSString stringWithFormat:@"%@\n%@",NSBaseLocalizedString(@"guide_register_mobile_card1", nil) ,NSBaseLocalizedString(@"guide_register_mobile_card3", nil)];
            helpDec.text = dec;
        }
        else
        {
            helpDec.text = NSBaseLocalizedString(@"guide_register_mobile_card3", nil);
        }
        
        
        UIView *togleView = [togleViews objectAtIndex:i];
        
        if (i == 0)
        {
            [togleView setHidden:YES];
        }
        else
        {
            [togleView setHidden:NO];
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
