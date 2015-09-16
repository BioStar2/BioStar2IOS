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

#import "UserDetailAcclCell.h"

#define ID_MAXLENGTH 10
#define NAME_MAXLENGTH 48
#define LOGIN_ID_MAXLENGTH 32

@implementation UserDetailAcclCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellContent:(NSDictionary*)userInfoDic cellType:(CellType)type viewMode:(DetailType)mode
{
    _type = type;
    switch (_type)
    {
        case CELL_USER_NAME:
            _titleLabel.text = NSLocalizedString(@"name", nil);
            _contentField.text = [userInfoDic objectForKey:@"name"];
            [_contentField setEnabled:YES];
            [_contentField setKeyboardType:UIKeyboardTypeDefault];
            [_contentField setSecureTextEntry:NO];
            break;
            
        case CELL_USER_ID:
        {
            _titleLabel.text = NSLocalizedString(@"user_id", nil);
            _contentField.text = [userInfoDic objectForKey:@"user_id"];
            [_contentField setKeyboardType:UIKeyboardTypeNumberPad];
            [_contentField setSecureTextEntry:NO];
            
            if (mode == MODIFY_MODE)
            {
                [_contentField setEnabled:NO];
            }
            else
            {
                [_contentField setEnabled:YES];
            }
        }
            break;
        case CELL_USER_EMAIL:
            _titleLabel.text = NSLocalizedString(@"email", nil);
            [_contentField setKeyboardType:UIKeyboardTypeEmailAddress];
            _contentField.text = [userInfoDic objectForKey:@"email"];
            [_contentField setSecureTextEntry:NO];
            
            if (mode == VIEW_MODE)
                [_contentField setEnabled:NO];
            else
                [_contentField setEnabled:YES];
                
            break;
        case CELL_USER_TELEPHONE:
            _titleLabel.text = NSLocalizedString(@"telephone", nil);
            _contentField.text = [userInfoDic objectForKey:@"phone_number"];
            [_contentField setSecureTextEntry:NO];
            [_contentField setKeyboardType:UIKeyboardTypePhonePad];
            
            if (mode == VIEW_MODE)
                [_contentField setEnabled:NO];
            else
                [_contentField setEnabled:YES];
            
            break;
        case CELL_USER_LOGIN_ID:
            _titleLabel.text = NSLocalizedString(@"login_id", nil);
            _contentField.text = [userInfoDic objectForKey:@"login_id"];
            [_contentField setEnabled:YES];
            [_contentField setSecureTextEntry:NO];

            break;
        case CELL_USER_PASSWORD:
        {
            _titleLabel.text = NSLocalizedString(@"password", nil);
            if ([[userInfoDic objectForKey:@"password_exist"] boolValue])
            {
                NSString *password = [userInfoDic objectForKey:@"password"];
                if (nil != password && ![password isEqualToString:@""])
                {
                    _contentField.text = [userInfoDic objectForKey:@"password"];
                }
                else
                {
                    _contentField.text = @"12345678";
                }
            }
            else
            {
                _contentField.text = @"";
            }
//            NSString *password = [userInfoDic objectForKey:@"password"];
//            if (nil != password && ![password isEqualToString:@""])
//            {
//                _contentField.text = [userInfoDic objectForKey:@"password"];
//            }
//            else
//            {
//                _contentField.text = @"";
//            }
            
            [_contentField setEnabled:NO];
            [_contentField setSecureTextEntry:YES];
        }
            break;
        case CELL_USER_GROUP:
            _titleLabel.text = NSLocalizedString(@"group", nil);
            _contentField.text = [[userInfoDic objectForKey:@"user_group"] objectForKey:@"name"];
            [_contentField setEnabled:NO];
            [_contentField setSecureTextEntry:NO];

            break;
            
        case CELL_USER_ACCESS_GROUP:
            _titleLabel.text = NSLocalizedString(@"access_group", nil);
            
            NSInteger count = 0;
            count += (unsigned long)[[userInfoDic objectForKey:@"access_groups"] count];
            count += (unsigned long)[[userInfoDic objectForKey:@"access_groups_in_user_group"] count];
            
            _contentField.text = [NSString stringWithFormat:@"%lu", (long)count];
            [_contentField setEnabled:NO];
            [_contentField setSecureTextEntry:NO];
            break;
    }
}

- (void)setCellContent:(NSDictionary*)userInfoDic cellType:(CellType)type viewMode:(DetailType)mode hasOperator:(BOOL)hasOperator
{
    if (hasOperator)
    {
        _titleLabel.text = NSLocalizedString(@"login_id", nil);
        _contentField.text = [userInfoDic objectForKey:@"login_id"];
        [_contentField setEnabled:YES];
        
    }
    else
    {
        _titleLabel.text = NSLocalizedString(@"group", nil);
        if (nil != [[userInfoDic objectForKey:@"user_group"] objectForKey:@"name"])
        {
            _contentField.text = [[userInfoDic objectForKey:@"user_group"] objectForKey:@"name"];
        }
        else
        {
            _contentField.text = NSLocalizedString(@"all_users", nil);
        }
        
        [_contentField setEnabled:NO];
    }
    [_contentField setSecureTextEntry:NO];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (_type)
    {
        case CELL_USER_NAME:
            if ([self.delegate respondsToSelector:@selector(userNameDidChange:)])
            {
                [self.delegate userNameDidChange:_contentField.text];
            }
            break;

        case CELL_USER_ID:
            if ([self.delegate respondsToSelector:@selector(userIDDidChange:)])
            {
                [self.delegate userIDDidChange:_contentField.text];
            }
            break;
        case CELL_USER_EMAIL:
            if ([self.delegate respondsToSelector:@selector(userEmailDidChange:)])
            {
                [self.delegate userEmailDidChange:_contentField.text];
            }
            break;
        case CELL_USER_TELEPHONE:
            if ([self.delegate respondsToSelector:@selector(userTelephoneDidChange:)])
            {
                [self.delegate userTelephoneDidChange:_contentField.text];
            }
            break;
        case CELL_USER_LOGIN_ID:
            if ([self.delegate respondsToSelector:@selector(userLogin_IDDidChange:)])
            {
                [self.delegate userLogin_IDDidChange:_contentField.text];
            }
            break;
        case CELL_USER_PASSWORD:
            if ([self.delegate respondsToSelector:@selector(userPasswordDidChange:)])
            {
                [self.delegate userPasswordDidChange:_contentField.text];
            }
            break;
            
        default:
            break;
    }
}


- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    if (_type == CELL_USER_ID)
    {
        return newLength <= ID_MAXLENGTH || returnKey;
    }
    else if (_type == CELL_USER_NAME)
    {
        return newLength <= NAME_MAXLENGTH || returnKey;
    }
    else if (_type == CELL_USER_LOGIN_ID)
    {
        return newLength <= LOGIN_ID_MAXLENGTH || returnKey;
    }
    else
        return YES;
}

@end
