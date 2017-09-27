//
//  BLESwtichCell.h
//  BiostarMobile
//
//  Created by 정의석 on 2017. 8. 22..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BLESwtichCellDelegate <NSObject>

- (void)useStatusHasChanged:(UITableViewCell*)cell;

@end

@interface BLESwtichCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *settingSwitch;
@property (nonatomic, weak) id <BLESwtichCellDelegate> delegate;


- (void)setBLESwitchCellContent:(NSString*)title usage:(BOOL)usage;
- (IBAction)switchDidChange:(id)sender;



@end
