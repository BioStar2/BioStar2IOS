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
#import "Common.h"
#import "User.h"
#import "PreferenceProvider.h"

@protocol UserDetailAccCellDelegate <NSObject>

@optional

- (void)userNameDidChange:(NSString*)userName;
- (void)userIDDidChange:(NSString*)userID;
- (void)userEmailDidChange:(NSString*)email;
- (void)userTelephoneDidChange:(NSString*)telephone;
- (void)userLogin_IDDidChange:(NSString*)loginID;
- (void)maxValueIsOver;
- (void)loginIDInvalid;
- (void)phoneNumberIsInvalid;
@end

#define ID_MAXLENGTH 10
#define ALPHABET_ID_MAXLENGTH 32
#define NAME_MAXLENGTH 48
#define LOGIN_ID_MAXLENGTH 32
#define TEHEPHONE_MAXLENGTH 32
#define EMAIL_MAXLENGTH 128

@interface UserDetailAcclCell : UITableViewCell
{
    User* currentUser;
    __weak IBOutlet UIImageView *arrowImage;
}

@property (assign, nonatomic) id <UserDetailAccCellDelegate> delegate;
@property (assign, nonatomic) CellType type;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *contentField;

- (void)setCellContent:(User*)user cellType:(CellType)type viewMode:(DetailType)mode;
- (void)setCellContent:(User*)user cellType:(CellType)type viewMode:(DetailType)mode hasOperator:(BOOL)hasOperator;
- (BOOL)validateLoginID:(NSString*)string;
- (BOOL)validateUserID:(NSString*)string;
- (BOOL)validatePhoenNumber:(NSString*)string;
- (NSString*)getTitle;

@end
