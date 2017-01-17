//
//  CardCell.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 9. 29..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+EnumParser.h"
#import "User.h"
#import "CommonUtil.h"
#import "PreferenceProvider.h"

@protocol MobileCellDelegate <NSObject>

@optional

- (void)reauestRetisterOrReissue:(UITableViewCell*)cell;

@end

@interface CardCell : UITableViewCell
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *cardDecLabel;
    __weak IBOutlet UILabel *cardNumberLabel;
    __weak IBOutlet UILabel *credentialLabel;
    __weak IBOutlet UILabel *accessGroupDecLabel;
    __weak IBOutlet UILabel *accessGroupLabel;
    __weak IBOutlet UILabel *periodDecLabel;
    __weak IBOutlet UILabel *periodLabel;
    __weak IBOutlet UILabel *nameLabel;
    __weak IBOutlet UIButton *switchButton;
    __weak IBOutlet UIImageView *cardPhoto;
    __weak IBOutlet UILabel *fingerPrintLabel;
    __weak IBOutlet UIView *togleView;
    __weak IBOutlet UILabel *disabledDecLabel;
    
    BOOL isRegistered;
}

@property (nonatomic, weak) id <MobileCellDelegate> delegate;

- (void)setMobileCardContent:(Card*)card user:(User*)user;

@end
