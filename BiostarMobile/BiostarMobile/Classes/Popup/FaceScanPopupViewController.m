//
//  FaceScanPopupViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2017. 3. 9..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import "FaceScanPopupViewController.h"

@interface FaceScanPopupViewController ()

@end

@implementation FaceScanPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSharedViewController:self];
    // Do any additional setup after loading the view.
    [self showPopupAnimation:containerView];
    deviceProvider = [[DeviceProvider alloc] init];
    
    if (nil == scanedFaceTemplate)
    {
        scanedFaceTemplate = [FaceTemplate new];
    }
    
    if (scanIndex == 0)
    {
        titleLabel.text = [NSString stringWithFormat:@"%ld%@ %@",
                           (long)scanIndex + 1, NSBaseLocalizedString(@"st", nil), NSBaseLocalizedString(@"face", nil)];
    }
    else if (scanIndex == 1)
    {
        titleLabel.text = [NSString stringWithFormat:@"%ld%@ %@",
                           (long)scanIndex + 1, NSBaseLocalizedString(@"nd", nil), NSBaseLocalizedString(@"face", nil)];
    }
    else if (scanIndex == 2)
    {
        titleLabel.text = [NSString stringWithFormat:@"%ld%@ %@",
                           (long)scanIndex + 1, NSBaseLocalizedString(@"rd", nil), NSBaseLocalizedString(@"face", nil)];
    }
    else
    {
        titleLabel.text = [NSString stringWithFormat:@"%ld%@ %@",
                           (long)scanIndex + 1, NSBaseLocalizedString(@"th", nil), NSBaseLocalizedString(@"face", nil)];
    }
    
    descriptionLabel.text = NSBaseLocalizedString(@"face_on_device", nil);
    
    [self requestScanFace:self.deviceID scanQuality:self.scanQuality];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [super popupViewDidAppear:contentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



- (void)getFaceTemplate:(FaceScanPopupTemplateBlock)faceTemplateBlock
{
    self.faceTemplateBlock = faceTemplateBlock;
}

- (void)getErrorBlock:(FaceScanErrorBlock)faceScanErrorBlock
{
    self.faceScanErrorBlock = faceScanErrorBlock;
}

- (void)requestScanFace:(NSString*)scanDeviceID scanQuality:(NSUInteger)quality
{
    [deviceProvider scanFace:scanDeviceID quality:quality scanBlock:^(FaceTemplate *faceTemplate) {
        
        scanedFaceTemplate = faceTemplate;
        
        [self showSuccessPopup];
        
    } onError:^(Response *error) {
        
        if (self.faceScanErrorBlock)
        {
            self.faceScanErrorBlock(error);
            self.faceScanErrorBlock = nil;
        }
        [self closePopup:self parentViewController:self.parentViewController];
        
    }];
    
}



- (void)showSuccessPopup
{
    if (self.faceTemplateBlock)
    {
        self.faceTemplateBlock(scanedFaceTemplate);
        self.faceTemplateBlock = nil;
    }
    [self closePopup:self parentViewController:self.parentViewController];
}


- (void)setScanIndex:(NSInteger)index
{
    scanIndex = index;
    
}

@end
