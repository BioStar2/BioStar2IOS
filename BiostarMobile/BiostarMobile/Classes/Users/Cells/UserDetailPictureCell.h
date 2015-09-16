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

#import <UIKit/UIKit.h>
#import "AuthProvider.h"
#import "Common.h"
#import "SDImageCache.h"

@interface UserDetailPictureCell : UITableViewCell
{
}

@property (weak, nonatomic) IBOutlet UIImageView *defaultImageView;
@property (weak, nonatomic) IBOutlet UIView *backGroundView;
@property (weak, nonatomic) IBOutlet UIView *userImageBackground;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userID;
@property (weak, nonatomic) IBOutlet UIView *fingerView;
@property (weak, nonatomic) IBOutlet UILabel *fingerCount;
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UILabel *cardCount;
@property (weak, nonatomic) IBOutlet UIView *pinView;
@property (weak, nonatomic) IBOutlet UILabel *pinCount;
@property (weak, nonatomic) IBOutlet UIView *pinDevideView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;
@property (weak, nonatomic) IBOutlet UIImageView *logButtonImage;
@property (weak, nonatomic) IBOutlet UIButton *logImageButton;
@property (weak, nonatomic) IBOutlet UILabel *logLabel;
@property (weak, nonatomic) IBOutlet UIButton *logLabelButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

- (void)setTopCell:(NSDictionary*)infoDic mode:(DetailType)mode;
- (void)adjustPhotoViewFrame;
- (IBAction)logButtonTouchTown:(id)sender;
- (IBAction)logButtonTouchUpInside:(id)sender;
- (IBAction)logButtonTouchUpOutside:(id)sender;
@end
