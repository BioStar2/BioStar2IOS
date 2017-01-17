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
        titleLabel.text = NSLocalizedString(@"access_on_card", nil);
        
        UILabel *cardDecLabel = [cardDecLabels objectAtIndex:i];
        cardDecLabel.text = NSLocalizedString(@"card_id", nil);
        
        UILabel *cardNumberLabel = [cardNumberLabels objectAtIndex:i];
        cardNumberLabel.text = @"4292967295";
        
        UILabel *credentialLabel = [credentialLabels objectAtIndex:i];
        credentialLabel.text = NSLocalizedString(@"credential", nil);
        
        UILabel *accessGroupDecLabel = [accessGroupDecLabels objectAtIndex:i];
        accessGroupDecLabel.text = NSLocalizedString(@"access_group", nil);
        
        UILabel *accessGroupLabel = [accessGroupLabels objectAtIndex:i];
        accessGroupLabel.text = @"brunch Swedeng";
        
        UILabel *periodDecLabel = [periodDecLabels objectAtIndex:i];
        periodDecLabel.text = NSLocalizedString(@"period", nil);
        
        UILabel *periodLabel = [periodLabels objectAtIndex:i];
        periodLabel.text = @"2016.01.01 - 2030.12.31";
        
        UILabel *nameLabel = [nameLabels objectAtIndex:i];
        nameLabel.text = @"Simona Morascag";
        
        UILabel *fingerPrintLabel = [fingerPrintLabels objectAtIndex:i];
        fingerPrintLabel.text = @"b2";
        
        UILabel *disabledDecLabel = [disabledDecLabels objectAtIndex:i];
        disabledDecLabel.text = NSLocalizedString(@"disabled_card", nil);
        
        UILabel *helpDec = [helpDecs objectAtIndex:i];
        if (i == 0)
        {
            helpDec.text = NSLocalizedString(@"issue_dec", nil);
        }
        else
        {
            helpDec.text = NSLocalizedString(@"stop_dec", nil);
        }
        
        
        
        UIButton *button = [switchButtons objectAtIndex:i];
        
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
