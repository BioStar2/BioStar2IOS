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
    provider = [[UserProvider alloc] init];
    provider.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellDictionary:(NSDictionary*)dic
{
    userInfo = dic;
    if ([[dic objectForKey:@"selected"] boolValue])
    {
        [self.contentView setBackgroundColor:UIColorFromRGB(0xf7ce86)];
        [_checkView setHidden:NO];
    }
    else
    {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        [_checkView setHidden:YES];
    }
    
    _FPCount.text = [dic objectForKey:@"fingerprint_count"];
    if (nil == [dic objectForKey:@"name"] || [[dic objectForKey:@"name"] isEqualToString:@""])
        _name.text = [dic objectForKey:@"user_id"];
    else
        _name.text = [dic objectForKey:@"name"];
    
    _userIDLabel.text = [dic objectForKey:@"user_id"];
    
    
    if ([[dic objectForKey:@"card_count"] integerValue] == 0)
    {
        [_pinView setHidden:YES];
    }
    else
    {
        [_pinView setHidden:NO];
    }
    _cardCount.text = [dic objectForKey:@"card_count"];
    
    if ([[dic objectForKey:@"pin_exist"] boolValue])
        [_pinView setHidden:NO];
    else
        [_pinView setHidden:YES];

    
    // 사진 데이터 가져오기
    if ([[dic valueForKey:@"photo_exist"] boolValue])
    {
        NSString *userID = [dic valueForKey:@"user_id"];
        
        NSLog(@"name : %@ / user_id : %@",[dic objectForKey:@"name"] ,[dic valueForKey:@"user_id"]);
        
        NSString *userPhotoKey = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USER_PHOTO, userID]];
        
        UIImage *userPhoto = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:userPhotoKey];
        if (userPhoto)
        {
            _userImage.image = userPhoto;
            
            _userImage.layer.cornerRadius = _userImage.frame.size.height /2;
            _userImage.layer.masksToBounds = YES;
            _userImage.layer.borderWidth = 0;
        }
        else
        {
            _userImage.image = [UIImage imageNamed:@"user_thumb_default"];
            
            //[provider getUser:userID];
            [provider getUserPhoto:userID];
        }
    }
    else
    {
        _userImage.image = [UIImage imageNamed:@"user_thumb_default"];
    }

}

- (void)requestDidFinishGettingUserPhoto
{
    [self setCellDictionary:userInfo];
}


@end
