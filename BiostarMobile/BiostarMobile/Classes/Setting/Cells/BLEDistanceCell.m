//
//  BLEDistanceCell.m
//  BiostarMobile
//
//  Created by 정의석 on 2017. 8. 29..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import "BLEDistanceCell.h"

@implementation BLEDistanceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)distanceHasChangedInside:(UISlider *)sender
{
    NSUInteger value = [self calculateCurrentDistance:sender.value];
    
    if ([self.delegate respondsToSelector:@selector(distanceHasChanged:)])
    {
        [self.delegate distanceHasChanged:value];
    }
    
    [self.contentView makeToast:[NSString stringWithFormat:@"%ld cm", value * 10] duration:1 position:CSToastPositionTop];
    
    [sender setValue:value animated:YES];
}

- (IBAction)distanceHasChangedOutside:(UISlider *)sender
{
    NSUInteger value = [self calculateCurrentDistance:sender.value];
    
    if ([self.delegate respondsToSelector:@selector(distanceHasChanged:)])
    {
        [self.delegate distanceHasChanged:value];
    }
    
    [self.contentView makeToast:[NSString stringWithFormat:@"%ld cm", value * 10] duration:1 position:CSToastPositionTop];
    
    [sender setValue:value animated:YES];
}

- (IBAction)distanceHasChanged:(id)sender
{
    
}

- (void)setDistanceLevel:(NSUInteger)distanceLevel withDiscance:(NSUInteger)distance
{
    [distanceSlider setMaximumValue:1.0];
    [distanceSlider setMaximumValue:distanceLevel];
    
    [distanceSlider setValue:distance animated:NO];
}

- (NSUInteger)calculateCurrentDistance:(float)value
{
    
    NSUInteger convertedValue = roundf(value);
    NSLog(@"%ld", (unsigned long)convertedValue);
    
    return convertedValue;
}
@end
