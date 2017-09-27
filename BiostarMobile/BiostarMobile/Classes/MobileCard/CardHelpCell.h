//
//  CardHelpCell.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 10. 4..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface CardHelpCell : UITableViewCell
{
    IBOutletCollection(UILabel) NSArray *titleLabels;
    IBOutletCollection(UILabel) NSArray *cardDecLabels;
    IBOutletCollection(UILabel) NSArray *cardNumberLabels;
    IBOutletCollection(UILabel) NSArray *credentialLabels;
    IBOutletCollection(UILabel) NSArray *accessGroupDecLabels;
    IBOutletCollection(UILabel) NSArray *accessGroupLabels;
    IBOutletCollection(UILabel) NSArray *periodDecLabels;
    IBOutletCollection(UILabel) NSArray *periodLabels;
    IBOutletCollection(UILabel) NSArray *nameLabels;
    IBOutletCollection(UIButton) NSArray *switchButtons;
    IBOutletCollection(UIImageView) NSArray *cardPhotos;
    IBOutletCollection(UILabel) NSArray *fingerPrintLabels;
    IBOutletCollection(UIView) NSArray *togleViews;
    IBOutletCollection(UILabel) NSArray *disabledDecLabels;
    IBOutletCollection(UILabel) NSArray *helpDecs;
    
    
    
    
    
    
    
    
    
    
    
    
}

@end
