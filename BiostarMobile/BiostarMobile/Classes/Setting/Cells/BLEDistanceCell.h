//
//  BLEDistanceCell.h
//  BiostarMobile
//
//  Created by 정의석 on 2017. 8. 29..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalDataManager.h"
#import "Common.h"
#import "UIView+Toast.h"

@protocol BLEDistanceCellDelegate <NSObject>

- (void)distanceHasChanged:(NSUInteger)distance;

@end

@interface BLEDistanceCell : UITableViewCell
{
    __weak IBOutlet UISlider *distanceSlider;
    
}

@property (nonatomic, weak) id <BLEDistanceCellDelegate> delegate;

- (IBAction)distanceHasChangedInside:(UISlider *)sender;
- (IBAction)distanceHasChangedOutside:(UISlider *)sender;
- (IBAction)distanceHasChanged:(id)sender;
- (NSUInteger)calculateCurrentDistance:(float)value;
- (void)setDistanceLevel:(NSUInteger)distanceLevel withDiscance:(NSUInteger)distance;
@end
