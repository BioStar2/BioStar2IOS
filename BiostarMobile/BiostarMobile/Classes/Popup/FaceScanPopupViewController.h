//
//  FaceScanPopupViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2017. 3. 9..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import "BaseViewController.h"
#import "DeviceProvider.h"
#import "ImagePopupViewController.h"
#import "FaceTemplate.h"

@interface FaceScanPopupViewController : BaseViewController
{
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIImageView *scanImage;
    __weak IBOutlet UILabel *descriptionLabel;
    __weak IBOutlet UIView *contentView;
    
    
    DeviceProvider *deviceProvider;
    NSInteger scanIndex;
    NSString *errorMessage;
    FaceTemplate *scanedFaceTemplate;
}

typedef void (^FaceScanPopupTemplateBlock)(FaceTemplate *scanedFaceTemplate);
typedef void (^FaceScanErrorBlock)(Response *error);


@property (nonatomic, strong) FaceScanPopupTemplateBlock faceTemplateBlock;
@property (nonatomic, strong) FaceScanErrorBlock faceScanErrorBlock;


@property (assign, nonatomic) NSInteger templateIndex;
@property (strong, nonatomic) NSString *deviceID;
@property (assign, nonatomic) NSUInteger scanQuality;



- (void)getFaceTemplate:(FaceScanPopupTemplateBlock)faceTemplateBlock;

- (void)getErrorBlock:(FaceScanErrorBlock)faceScanErrorBlock;

- (void)requestScanFace:(NSString*)scanDeviceID scanQuality:(NSUInteger)quality;

- (void)setScanIndex:(NSInteger)index;

- (void)showSuccessPopup;


@end
