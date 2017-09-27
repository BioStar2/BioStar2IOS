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
#import "UserRole.h"
#import "Common.h"

@interface UserDetailOperatorCell : UITableViewCell
{
    __weak IBOutlet NSLayoutConstraint *numberViewWidth;
    __weak IBOutlet UIView *numberView;
    __weak IBOutlet UILabel *numberLabel;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *contentLabel;
    __weak IBOutlet NSLayoutConstraint *contentTrailConstraint;
    __weak IBOutlet NSLayoutConstraint *numberTrailConstraint;
    __weak IBOutlet UIImageView *accImageView;
}

- (void)setOperatorCellContent:(NSArray*)operators isEditMode:(BOOL)flag;
- (void)setPermission:(NSString*)name isEditMode:(BOOL)flag;
- (NSString*)getTitle;


@end
