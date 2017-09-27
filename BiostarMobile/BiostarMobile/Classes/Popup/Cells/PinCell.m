/*
 * Copyright 2015 Suprema(biostar2@suprema.co.kr)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "PinCell.h"


@implementation PinCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellContent:(NSInteger)row content:(NSDictionary*)dic isPin:(BOOL)isPin
{
    pinMode = isPin;
    if (isPin)
    {
        pinVialue.tag = row;
        if (row == 0)
        {
            titleLabel.text = NSBaseLocalizedString(@"password", nil);
            [pinVialue becomeFirstResponder];
        }
        else
        {
            titleLabel.text = NSBaseLocalizedString(@"password_confirm", nil);
        }
    }
    else
    {
        [pinVialue setKeyboardType:UIKeyboardTypeDefault];
        switch (row)
        {
            case 1:
                titleLabel.text = NSBaseLocalizedString(@"password", nil);
                [pinVialue becomeFirstResponder];
                break;
                
            case 2:
                titleLabel.text = NSBaseLocalizedString(@"password_confirm", nil);
                break;
        }
    }
    
}

- (void)setFirstResponder
{
    [pinVialue becomeFirstResponder];
}

- (IBAction)pinValueDidChange:(id)sender
{
    UITextField *textField = (UITextField*)sender;
    
    if ([self.delegate respondsToSelector:@selector(textFieldValueChanged:cell:)])
    {
        [self.delegate textFieldValueChanged:textField.text cell:self];
    }
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    if (pinMode)
    {
        return newLength <= PIN_MAXLENGTH || returnKey;
    }
    else
        return newLength <= PASSWORD_MAXLENGTH || returnKey;
    
}

@end
