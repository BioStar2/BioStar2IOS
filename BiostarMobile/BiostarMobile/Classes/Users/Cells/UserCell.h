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
#import "UserProvider.h"
#import "CustomImageView.h"
#import "CommonUtil.h"
#import "Common.h"
#import "SDImageCache.h"
#import "PreferenceProvider.h"

@interface UserCell : UITableViewCell 
{
    UserProvider *provider;
    NSString *imagestr;
    
}

@property (weak, nonatomic) IBOutlet CustomImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UILabel *cardCount;
@property (weak, nonatomic) IBOutlet UIView *fingerView;
@property (weak, nonatomic) IBOutlet UILabel *FPCount;
@property (weak, nonatomic) IBOutlet UIView *pinView;
@property (weak, nonatomic) IBOutlet UIImageView *checkView;
@property (weak, nonatomic) IBOutlet UIImageView *accView;



- (void)setUser:(User*)user;
- (void)loadUserPhoto:(NSString*)userID;
@end
