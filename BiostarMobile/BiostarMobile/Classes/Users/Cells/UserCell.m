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

#import "UserCell.h"
#import "PreferenceProvider.h"

@implementation UserCell 

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    provider = [[UserProvider alloc] init];
    
    _userImage.isThumbNail = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setUser:(User*)user isEditMode:(BOOL)isEditMode
{
    if (isEditMode)
    {
        [_accView setHidden:YES];
        
        if (user.isSelected)
        {
            [self.contentView setBackgroundColor:UIColorFromRGB(0xf7ce86)];
            [_checkView setHidden:NO];
        }
        else
        {
            if ([PermissionProvider isEnableDeleteUser:user])
            {
                [self.contentView setBackgroundColor:[UIColor whiteColor]];
            }
            else
            {
                [self.contentView setBackgroundColor:[UIColor lightGrayColor]];
            }
            
            [_checkView setHidden:YES];
        }
    }
    else
    {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        [_accView setHidden:NO];
        [_checkView setHidden:YES];
    }
    
    
    if ([user.fingerprint_template_count integerValue] > 0)
    {
        [_fingerView setHidden:NO];
    }
    else
    {
        [_fingerView setHidden:YES];
    }
    
    if (user.card_count > 0)
    {
        [_cardView setHidden:NO];
    }
    else
    {
        [_cardView setHidden:YES];
    }
    
    if (user.face_template_count > 0)
    {
        [_faceView setHidden:NO];
    }
    else
    {
        [_faceView setHidden:YES];
    }
    
    if (user.pin_exist)
        [_pinView setHidden:NO];
    else
        [_pinView setHidden:YES];
    
    
    if (nil == user.name || [user.name isEqualToString:@""])
        _name.text = user.user_id;
    else
        _name.text = user.name;
    
    _userIDLabel.text = user.user_id;
    
    
    
    
    
    
    // 사진 데이터 가져오기
    if (user.photo_exist)
    {
        [self loadUserPhoto:user.user_id];
    }
    else
    {
        _userImage.image = [UIImage imageNamed:@"user_thumb_default"];
    }
}

- (void)loadUserPhoto:(NSString*)userID
{
    NSString *userPhotoKey = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USER_PHOTO, userID]];
    
    UIImage *userPhoto = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:userPhotoKey];
    if (userPhoto)
    {
        _userImage.image = userPhoto;
    }
    else
    {
        _userImage.image = [UIImage imageNamed:@"user_thumb_default"];
    }
}



@end
