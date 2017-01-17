//
//  CardRadioCell.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 1..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"
#import "Common.h"

@interface CardRadioCell : UITableViewCell

- (void)checkSelected:(BOOL)isSelected;
- (void)checkSelected:(BOOL)isSelected isLimited:(BOOL)isLimited;
- (void)setCardType:(DeviceMode)addType card:(Card*)card isSelected:(BOOL)isSelected;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkImage;



@end
