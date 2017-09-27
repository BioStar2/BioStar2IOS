//
//  MobileCredentialCell.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 16..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"
#import "NSString+EnumParser.h"
#import "Common.h"


@protocol MobileCredentialCellDelegate <NSObject>

@optional

- (void)blockCard:(UITableViewCell*)cell;
- (void)releaseCard:(UITableViewCell*)cell;
- (void)requestReregisterMobileCard:(Card*)card;

@end

@interface MobileCredentialCell : UITableViewCell
{
    __weak IBOutlet UISwitch *statusSwitch;
    __weak IBOutlet UILabel *cardTypeLabel;
    __weak IBOutlet UILabel *cardIDLabel;
    __weak IBOutlet UIImageView *checkImage;
    __weak IBOutlet UIButton *statusButton;
    Card *currentCard;
}

@property (nonatomic, weak) id <MobileCredentialCellDelegate> delegate;

- (void)setContent:(Card*)card mode:(BOOL)isDeleteMode viewMode:(BOOL)isProfile;
- (IBAction)blockOrReleaseCard:(UISwitch *)sender;
- (IBAction)requestReregisterMobileCard:(id)sender;
- (CGFloat)getIDLabelHeight;
@end
