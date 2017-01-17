//
//  SideMenuCell.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 9. 19..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButtonModel.h"
#import "LocalDataManager.h"

@interface SideMenuCell : UITableViewCell
{
    __weak IBOutlet UIImageView *menuIcon;
    __weak IBOutlet UILabel *menuTitle;
    __weak IBOutlet UIView *countView;
    __weak IBOutlet UILabel *countLable;
    __weak IBOutlet UIImageView *countImageView;
    ButtonType type;
}

- (void)setContent:(ButtonModel *)button;
- (void)setHighlightColor:(UIColor*)color;
@end
