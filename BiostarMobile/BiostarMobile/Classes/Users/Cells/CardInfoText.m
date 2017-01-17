//
//  CardInfoText.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 8..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "CardInfoText.h"

@implementation CardInfoText

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    cardIDTextField.delegate = self;
    formatNames = [[NSMutableArray alloc] init];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCardInfoType:(RegistrationType)registrationType deviceMode:(DeviceMode)mode
{
    deviceMode = mode;
    switch (registrationType) {
        case NEW_CARD:
        case ASSIGNMENT:
            [contentLabel setHidden:NO];
            [accImage setHidden:YES];
            [cardIDTextField setHidden:YES];
            [PINTextField setHidden:YES];
            break;
            
        case INPUT:
            [contentLabel setHidden:YES];
            [accImage setHidden:NO];
            [cardIDTextField setHidden:NO];
            [cardIDTextField setSecureTextEntry:NO];
            [cardIDTextField setKeyboardType:UIKeyboardTypeNumberPad];
            [PINTextField setHidden:YES];
            break;
    }
}

- (void)setOnlyContent
{
    [PINTextField setHidden:YES];
    [contentLabel setHidden:NO];
    [accImage setHidden:YES];
    [cardIDTextField setHidden:YES];
}

- (void)setPinExist:(BOOL)pinExist
{
    if (pinExist)
    {
        [contentLabel setHidden:YES];
        [accImage setHidden:YES];
        [cardIDTextField setHidden:YES];
        [PINTextField setHidden:NO];
        PINTextField.text = @"1111";
    }
    else
    {
        [self setOnlyContent];
    }
    
}

- (void)setTitle:(NSString*)title content:(NSString*)content
{
    titleLabel.text = title;
    contentLabel.text = content;
}

- (void)setTitle:(NSString*)title smartCardType:(NSString*)cardType
{
    titleLabel.text = title;
    
    CardType type = [cardType cardTypeEnumFromString];
    
    NSString *typeStr;
    if (type == SECURE_CREDENTIAL)
    {
        typeStr = NSLocalizedString(@"secure_card", nil);
    }
    else
    {
        typeStr = NSLocalizedString(@"access_on_card", nil);
    }
    
    contentLabel.text = typeStr;
}

- (void)setTitle:(NSString*)title field:(NSString*)content
{
    titleLabel.text = title;
    cardIDTextField.text = content;
}

- (void)setTitle:(NSString*)title field:(NSString*)content maxValue:(NSInteger)value
{
    titleLabel.text = title;
    cardIDTextField.text = content;
    maxValue = value;
}

- (void)setStartDate:(NSString*)startDate andExpireDate:(NSString*)expireDate
{
    NSString *startDateStr =  [CommonUtil stringFromDateString:startDate originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'" transDateFormat:[PreferenceProvider getDateFormat]];
    
    NSString *expiryDateStr =  [CommonUtil stringFromDateString:expireDate originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'" transDateFormat:[PreferenceProvider getDateFormat]];
    
    
    contentLabel.text = [NSString stringWithFormat:@"%@ ~ %@",startDateStr ,expiryDateStr];
}

- (void)setWiegandFormat:(SearchResultDevice*)device
{
    [formatNames removeAllObjects];
    if (nil == device)
    {
        multiSelectContentLabel.text = @"";
        return;
    }
    
    [formatNames addObject:device.csn_wiegand_format.name];
    for (SimpleModel *format in device.wiegand_format_list)
    {
        [formatNames addObject:format.name];
    }
    
    
    
    if (formatNames.count > 1)
    {
        [multiSelectContentLabel setHidden:NO];
        [contentLabel setHidden:YES];
        multiSelectContentLabel.text = formatNames[0];
        [accImage setHidden:NO];
    }
    else
    {
        [multiSelectContentLabel setHidden:YES];
        [contentLabel setHidden:NO];
        contentLabel.text = formatNames[0];
        [accImage setHidden:YES];
    }
}


- (NSString*)getTitle
{
    return titleLabel.text;
}
#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (deviceMode == WIEGAND_CARD_MODE)
    {
        if ([self.delegate respondsToSelector:@selector(wiegandContentDidChanged:cell:)])
        {
            [self.delegate wiegandContentDidChanged:textField.text cell:self];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(textfieldContentDidChanged:)])
        {
            [self.delegate textfieldContentDidChanged:textField.text];
        }
    }
    
    
}


- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@""])
    {
        return YES;
    }
    
    if (string.length > 1)
    {
        return NO;
    }
    
    if (textField.text.length == 0)
    {
        if ([string integerValue] == 0)
        {
            if ([self.delegate respondsToSelector:@selector(zeroValueNotAllowed)])
            {
                [self.delegate zeroValueNotAllowed];
            }
            return NO;
        }
    }
    
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    // CSN
    if (deviceMode == CSN_CARD_MODE)
    {
        return newLength <= CSN_MAXLENGTH || returnKey;
    }
    else if (deviceMode == WIEGAND_CARD_MODE)
    {
        
        NSMutableString *strValue = [[NSMutableString alloc] init];
        [strValue appendString:textField.text];
        [strValue appendString:string];
        NSInteger value = [strValue integerValue];
        
        if (value > maxValue)
        {
            if ([self.delegate respondsToSelector:@selector(maxValueIsOver:)])
            {
                [self.delegate maxValueIsOver:maxValue];
            }
            
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else
    {
        // smart 24
        return newLength <= SMART_MAXLENGTH || returnKey;
    }
    
}

@end
