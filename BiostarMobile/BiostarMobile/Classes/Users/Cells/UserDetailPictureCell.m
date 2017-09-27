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

#import "UserDetailPictureCell.h"

@implementation UserDetailPictureCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    self.faceLabel.text = NSBaseLocalizedString(@"face", nil);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (UIImage*)getScaledImage:(NSString*)photoString
{
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:photoString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *serverImage = [UIImage imageWithData:imageData];
    UIImage* scaledImage = [CommonUtil imageCompress:serverImage fileSize:MAX_IMAGE_FILE_SIZE];
    
    return scaledImage;
}

- (void)setTopCell:(User*)user mode:(DetailType)mode
{
    if (nil == user) {
        return;
    }
    
    if (user.pin_exist)
    {
        [_pinView setHidden:NO];
    }
    else
    {
        [_pinView setHidden:YES];
    }
    
    switch (mode)
    {
        case VIEW_MODE:
            
            [_cameraButton setImage:nil forState:UIControlStateNormal];
            [_cameraButton setImage:nil forState:UIControlStateHighlighted];
            [_cameraButton setHidden:YES];
            [_defaultImageView setHidden:NO];
            
            if (nil != user.photo && ![user.photo isEqualToString:@""])
            {
                UIImage *userPhotoImage = [self getScaledImage:user.photo];
                NSString *userPhotoKey = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USER_PHOTO, user.user_id]];
                [[SDImageCache sharedImageCache] storeImage:userPhotoImage forKey:userPhotoKey toDisk:YES];
    
                _defaultImageView.image = userPhotoImage;
                [_defaultImageView setHidden:NO];
                [_blurView setHidden:NO];
                _backgroundImage.image = _defaultImageView.image;
                
            }
            else
            {
                _defaultImageView.image = [UIImage imageNamed:@"user_photo_bg"];
                [_blurView setHidden:YES];
            }
            
            [_userImageBackground setBackgroundColor:[UIColor clearColor]];
            _backgroundImage.image = [UIImage imageNamed:@"background1"];
            break;
            
        case MODIFY_MODE:
        case CREATE_MODE:
        case PROFILE_MODE:
            
            [_cameraButton setImage:[UIImage imageNamed:@"ic_camera_nor"] forState:UIControlStateNormal];
            [_cameraButton setImage:[UIImage imageNamed:@"ic_camera_pre"] forState:UIControlStateHighlighted];
            [_cameraButton setHidden:NO];
            
            
            if (nil != user.photo && ![user.photo isEqualToString:@""])
            {
                UIImage *userPhotoImage = [self getScaledImage:user.photo];
                NSString *userPhotoKey = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USER_PHOTO, user.user_id]];
                [[SDImageCache sharedImageCache] storeImage:userPhotoImage forKey:userPhotoKey toDisk:YES];
                
                _defaultImageView.image = userPhotoImage;
                [_defaultImageView setHidden:NO];
                [_blurView setHidden:NO];
                
                [_userImageBackground setBackgroundColor:[UIColor clearColor]];
                
                [_cameraButton setImage:nil forState:UIControlStateNormal];
                [_cameraButton setImage:nil forState:UIControlStateHighlighted];
                _backgroundImage.image = _defaultImageView.image;
            }
            else
            {
                _defaultImageView.image = [UIImage imageNamed:@"user_photo_bg"];
                [_blurView setHidden:YES];
                [_defaultImageView setHidden:YES];
                
                [_userImageBackground setBackgroundColor:[UIColor clearColor]];
                _backgroundImage.image = [UIImage imageNamed:@"background1"];
            }
            
            break;
        
    }
    
    _userName.text = user.name ? user.name : @"";
    _userID.text = user.user_id ? user.user_id : @"";
    
    
    if ([PreferenceProvider isUpperVersion])
    {
        _fingerCount.text = user.fingerprint_template_count;
        _faceCountLabel.text =  [NSString stringWithFormat:@"%ld", (long)user.face_template_count];
    }
    else
    {
        if (user.fingerprint_count == 0)
        {
            _fingerCount.text = @"0";
        }
        else
        {
            _fingerCount.text = [NSString stringWithFormat:@"%ld", (long)user.fingerprint_count];
        }
        
        [_faceView setHidden:YES];
    }
    
    if (user.card_count == 0)
    {
        _cardCount.text = @"0";
    }
    else
    {
        _cardCount.text = [NSString stringWithFormat:@"%ld", (long)user.card_count];
    }
    
    if (user.pin_exist)
    {
        [_pinView setHidden:NO];
        [_pinDevideView setHidden:NO];
    }
    else
    {
        [_pinView setHidden:YES];
        [_pinDevideView setHidden:YES];
    }
    
}




@end
