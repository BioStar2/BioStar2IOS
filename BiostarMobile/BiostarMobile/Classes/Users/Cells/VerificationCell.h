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
#import "UserItemAccessGroup.h"
#import "Common.h"

@interface VerificationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *checkImage;
@property (weak, nonatomic) IBOutlet UIImageView *accImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (void)setAccessGroup:(UserItemAccessGroup*)accessGroup isEditMode:(BOOL)isEditMode;
- (void)setCheckSeleted:(BOOL)isSelected;
- (NSString*)getTitle;

@end
