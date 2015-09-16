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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self adjustPhotoViewFrame];
}

- (void)adjustPhotoViewFrame
{
    _userImageBackground.layer.cornerRadius = _userImageBackground.frame.size.height /2;
    _userImageBackground.layer.masksToBounds = YES;
    _userImageBackground.layer.borderWidth = 3;
    _userImageBackground.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (void)setTopCell:(NSDictionary*)infoDic mode:(DetailType)mode
{
    if ([[infoDic objectForKey:@"pin_exist"] boolValue])
    {
        [_pinView setHidden:NO];
    }
    else
    {
        [_pinView setHidden:YES];
    }
    
    id userPhoto = [infoDic objectForKey:@"photo"];
    
    switch (mode)
    {
        case VIEW_MODE:
            if ([AuthProvider hasReadPermission:@"MONITORING"])
            {
                [_logImageButton setHidden:NO];
                [_logLabel setHidden:NO];
                [_logLabelButton setHidden:NO];
            }
            else
            {
                [_logImageButton setHidden:YES];
                [_logLabel setHidden:YES];
                [_logLabelButton setHidden:YES];
            }
            
            
            
            [_cameraButton setImage:nil forState:UIControlStateNormal];
            [_cameraButton setImage:nil forState:UIControlStateHighlighted];
            [_cameraButton setHidden:YES];
            [_defaultImageView setHidden:NO];
            
            //if (nil != userPhoto)
            if ([userPhoto isKindOfClass:[UIImage class]])
            {
                [_blurView setHidden:NO];
                _defaultImageView.image = userPhoto;
            }
            else
            {
                _defaultImageView.image = [UIImage imageNamed:@"user_photo_bg"];
                [_blurView setHidden:YES];
            }
            
            [_userImageBackground setBackgroundColor:[UIColor clearColor]];
            break;
            
        case MODIFY_MODE:
        case CREATE_MODE:
        case PROFILE_MODE:
            [_logImageButton setHidden:YES];
            [_logLabel setHidden:YES];
            [_logLabelButton setHidden:YES];
            [_cameraButton setImage:[UIImage imageNamed:@"ic_camera_nor"] forState:UIControlStateNormal];
            [_cameraButton setImage:[UIImage imageNamed:@"ic_camera_pre"] forState:UIControlStateHighlighted];
            [_cameraButton setHidden:NO];
            
            
            if ([userPhoto isKindOfClass:[UIImage class]])
            {
                [_blurView setHidden:NO];
                UIImage *userImage = userPhoto;
                NSData *imgData = UIImageJPEGRepresentation(userImage, 0);
                NSLog(@"Size of Image(bytes):%lu",(unsigned long)[imgData length]);
                _defaultImageView.image = userImage;
                [_defaultImageView setHidden:NO];
                
                [_userImageBackground setBackgroundColor:[UIColor clearColor]];
                
                [_cameraButton setImage:nil forState:UIControlStateNormal];
                [_cameraButton setImage:nil forState:UIControlStateHighlighted];
            }
            else
            {
                _defaultImageView.image = [UIImage imageNamed:@"user_photo_bg"];
                [_blurView setHidden:YES];
                [_defaultImageView setHidden:YES];
                
                [_userImageBackground setBackgroundColor:[UIColor clearColor]];
            }
            [_userImageBackground setNeedsLayout];
            [_userImageBackground layoutIfNeeded];
            break;
        
    }
    
    
    
    
    _defaultImageView.layer.cornerRadius = _defaultImageView.frame.size.height /2;
    _defaultImageView.layer.masksToBounds = YES;
    _defaultImageView.layer.borderWidth = 0;
    _defaultImageView.layer.borderWidth = 3;
    _defaultImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    
    if (nil != [infoDic objectForKey:@"name"])
    {
        _userName.text = [infoDic objectForKey:@"name"];
    }
    
    if (nil != [infoDic objectForKey:@"user_id"])
    {
        _userID.text = [infoDic objectForKey:@"user_id"];
    }
    
    if ([userPhoto isKindOfClass:[UIImage class]])
    {
        _backgroundImage.image = userPhoto;
    }
    else
    {
        _backgroundImage.image = [UIImage imageNamed:@"background1"];
    }
    
    NSArray *fingerprintTemplates = [infoDic objectForKey:@"fingerprint_templates"];
    NSInteger fingerprintCount;
    if (nil == fingerprintTemplates)
    {
        fingerprintCount = 0;
    }
    else
    {
        fingerprintCount = fingerprintTemplates.count;
    }
    
    if (fingerprintCount == 0)
    {
        _fingerCount.text = @"";
    }
    else
    {
        _fingerCount.text = [NSString stringWithFormat:@"%ld", (long)fingerprintCount];
    }
    
    
    NSArray *cards = [infoDic objectForKey:@"cards"];
    NSInteger cardsCount;
    
    if (nil == cards)
    {
        cardsCount = 0;
    }
    else
    {
        cardsCount = cards.count;
    }
    
    if (cardsCount == 0)
    {
        _cardCount.text = @"";
    }
    else
    {
        _cardCount.text = [NSString stringWithFormat:@"%ld", (long)cardsCount];
    }
    
    if ([[infoDic objectForKey:@"pin_exist"] boolValue])
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

- (IBAction)logButtonTouchTown:(id)sender {
    [_logButtonImage setImage:[UIImage imageNamed:@"ic_viewlog_pre"]];
}

- (IBAction)logButtonTouchUpInside:(id)sender {
    [_logButtonImage setImage:[UIImage imageNamed:@"ic_viewlog_nor"]];
}

- (IBAction)logButtonTouchUpOutside:(id)sender {
    [_logButtonImage setImage:[UIImage imageNamed:@"ic_viewlog_nor"]];
}
@end
