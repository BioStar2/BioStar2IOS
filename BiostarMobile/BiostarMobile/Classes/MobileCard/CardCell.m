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
    cardDecLabel.text = NSBaseLocalizedString(@"card_id", nil);
    credentialLabel.text = NSBaseLocalizedString(@"credential", nil);
    accessGroupDecLabel.text = NSBaseLocalizedString(@"access_group", nil);
    periodDecLabel.text = NSBaseLocalizedString(@"period", nil);
    disabledDecLabel.text = NSBaseLocalizedString(@"disabled_card", nil);
    
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

- (void)setMobileCardContent:(GetMobileCredential*)card user:(User*)user status:(NSString*)status
{
    if (nil != user.photo && ![user.photo isEqualToString:@""])
    {
        NSData *imageData = [NSData base64DataFromString:user.photo];
        UIImage *userImage = [UIImage imageWithData:imageData];
        
        UIImage *image = [CommonUtil imageCompress:userImage fileSize:MAX_IMAGE_FILE_SIZE];
        if (image)
        {
            cardPhoto.image = image;
        }
        
    }
    
    //[togleView setHidden:card.is_registered];
    
    cardNumberLabel.text = card.card_id;
    
    fingerPrintLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)card.fingerprint_index_list.count];
    nameLabel.text = card.user.name;
    accessGroupLabel.text = card.access_groups.count ? card.access_groups[0].name : NSBaseLocalizedString(@"none", nil);
    
    NSString *startDateStr =  [CommonUtil stringFromDateString:card.start_datetime originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'" transDateFormat:[NSString stringWithFormat:@"%@ %@", [LocalDataManager getDateFormat], [LocalDataManager getTimeFormat]]];


    NSString *expiryDateStr =  [CommonUtil stringFromDateString:card.expiry_datetime originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'" transDateFormat:[NSString stringWithFormat:@"%@ %@", [LocalDataManager getDateFormat], [LocalDataManager getTimeFormat]]];
    
    periodLabel.text = [NSString stringWithFormat:@"%@ - %@", startDateStr, expiryDateStr];
    
    CardType cardType = [card.type cardTypeEnumFromString];
    if (cardType == SECURE_CREDENTIAL)
    {
        titleLabel.text = NSBaseLocalizedString(@"secure_card", nil);
        [periodLabel setHidden:YES];
        [periodDecLabel setHidden:YES];
        [accessGroupLabel setHidden:YES];
        [accessGroupDecLabel setHidden:YES];
    }
    else
    {
        titleLabel.text = NSBaseLocalizedString(@"access_on_card", nil);
        [periodLabel setHidden:NO];
        [periodDecLabel setHidden:NO];
        [accessGroupLabel setHidden:NO];
        [accessGroupDecLabel setHidden:NO];
    }
    
    if (card.is_registered)
    {
        [switchButton setImage:[UIImage imageNamed:@"toggle2_on"] forState:UIControlStateNormal];
    }
    else
    {
        [switchButton setImage:[UIImage imageNamed:@"toggle2_off"] forState:UIControlStateNormal];
    }
    
//    BLEStatus bleStatus = [status BLEStatusTypeEnumFromString];
//    switch (bleStatus) {
//        case BROADCAST_BLE_SUCESS:
//            titleLabel.textColor = UIColorFromRGB(0x000000);
//            break;
//            
//        case BROADCAST_BLE_ERROR_CONNECT:
//            titleLabel.textColor = UIColorFromRGB(0xaca9a1);
//            break;
//        case BROADCAST_BLE_ERROR_DATA:
//            titleLabel.textColor = UIColorFromRGB(0xff2d55);
//            break;
//        case BROADCAST_BLE_CONNECT:
//            titleLabel.textColor = UIColorFromRGB(0x52b2b8);
//            break;
//        case BROADCAST_NONE:
//            titleLabel.textColor = UIColorFromRGB(0x594B4F);
//            break;
//    }
}
@end
