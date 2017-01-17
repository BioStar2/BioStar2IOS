//
//  ScanQualityPopupViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 14..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "BaseViewController.h"

@interface ScanQualityPopupViewController : BaseViewController
{
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UILabel *qualityLabel;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UIButton *confirmBtn;
    
    
    BOOL isRequesting;
    NSUInteger currentQuality;
    
}


typedef void (^QualityPopupResponseBlock)(NSUInteger quality);
typedef void (^QualityPopupCancelBlock)();

@property (nonatomic, strong) QualityPopupResponseBlock qualityResponse;
@property (nonatomic, strong) QualityPopupCancelBlock cancelResponse;

@property (assign, nonatomic) NSInteger scanCount;
@property (assign, nonatomic) NSInteger templateIndex;
@property (assign, nonatomic) long deviceID;



- (void)getResponse:(QualityPopupResponseBlock)responseBlock;
- (void)getCancelResponse:(QualityPopupCancelBlock)cancelBlock;


- (NSUInteger)calculateCurrentQuality:(float)value;
- (IBAction)confirmPopup:(id)sender;
- (IBAction)cancelPopup:(id)sender;

@end
