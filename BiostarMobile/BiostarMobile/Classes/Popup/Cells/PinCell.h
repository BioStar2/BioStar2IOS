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

@protocol PinCellDelegate <NSObject>

@optional

- (void)textFieldValueChanged:(NSString*)value cell:(UITableViewCell*)theCell;

@end

#define PIN_MAXLENGTH   16
#define PASSWORD_MAXLENGTH 32

@interface PinCell : UITableViewCell
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UITextField *pinVialue;
    BOOL pinMode;
}

@property (assign, nonatomic) id <PinCellDelegate> delegate;

- (void)setCellContent:(NSInteger)row content:(NSDictionary*)dic isPin:(BOOL)isPin;
- (void)setFirstResponder;
- (IBAction)pinValueDidChange:(id)sender;
@end
