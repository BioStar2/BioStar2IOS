//
//  CardAddInfoCell.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 4..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardAddInfoCell : UITableViewCell
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIImageView *accImage;
    __weak IBOutlet UILabel *contentLabel;
    
}




- (void)setTitle:(NSString*)title content:(NSString*)content;
- (NSString*)getTitle;

@end
