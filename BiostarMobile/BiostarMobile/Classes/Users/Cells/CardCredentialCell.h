//
//  CardCredentialCell.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 16..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"
#import "NSString+EnumParser.h"
#import "Common.h"

@protocol CardCredentialCellDelegate <NSObject>

@optional

- (void)blockCard:(UITableViewCell*)cell;
- (void)releaseCard:(UITableViewCell*)cell;

@end


@interface CardCredentialCell : UITableViewCell
{
    __weak IBOutlet UIButton *blockButton;
    __weak IBOutlet UIButton *releaseButton;
    __weak IBOutlet UILabel *cardTypeLabel;
    __weak IBOutlet UILabel *cardIDLabel;
    __weak IBOutlet UIImageView *checkImage;
    
}

@property (nonatomic, weak) id <CardCredentialCellDelegate> delegate;

- (void)setContent:(Card*)card mode:(BOOL)isDeleteMode viewMode:(BOOL)isProfile;
- (IBAction)block:(id)sender;
- (IBAction)release:(id)sender;

@end
