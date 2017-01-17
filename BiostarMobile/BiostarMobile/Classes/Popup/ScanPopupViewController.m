/*
 * Copyright 2015 Suprema(biostar2@suprema.co.kr)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ScanPopupViewController.h"

@interface ScanPopupViewController ()

@end

@implementation ScanPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSharedViewController:self];
    // Do any additional setup after loading the view.
    [self showPopupAnimation:containerView];
    deviceProvider = [[DeviceProvider alloc] init];
    
    [confirmButton setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    if (nil == scanFingerPrintTemplate)
    {
        scanFingerPrintTemplate = [FingerprintTemplate new];
    }
    
    [self requestScanFingerprint:self.deviceID scanQuality:self.scanQuality];
    
    if (scanIndex == 0)
    {
        titleLabel.text = NSLocalizedString(@"1st_fingerprint", nil);
    }
    else if (scanIndex == 1)
    {
        titleLabel.text = NSLocalizedString(@"2nd_fingerprint", nil);
    }
    else if (scanIndex == 2)
    {
        titleLabel.text = NSLocalizedString(@"3rd_fingerprint", nil);
    }
    else
    {
        titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%ldth_fingerprint", nil), scanIndex + 1];
    }
    
    descriptionLabel.text = NSLocalizedString(@"finger_on_device", nil);
    
    if (_scanCount == 1)
    {
        scanImage.image = [UIImage imageNamed:@"user_fp2"];
        descriptionLabel.text = NSLocalizedString(@"finger_on_device_same", nil);
    }
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

- (void)setFingerprint:(FingerprintTemplate*)fingerPrintTemplate
{
    scanFingerPrintTemplate = fingerPrintTemplate;
    if (nil == scanFingerPrintTemplate.template0)
    {
        self.scanCount = 0;
    }
    else
    {
        self.scanCount = 1;
    }
}

- (void)getLowQualityBlock:(ScanPopupLowQualityTemplateBlock)lowQualityBlock
{
    self.lowQualityBlock = lowQualityBlock;
}

- (void)getFingerPrintTemplate:(ScanPopupTemplateBlock)fingerprintTemplateBlock
{
    self.fingerprintTemplateBlock = fingerprintTemplateBlock;
}

- (void)getBoolResponse:(ScanPopupBOOLResponseBlock)boolResponseBlock
{
    self.boolResponseBlock = boolResponseBlock;
}

- (void)requestScanFingerprint:(NSString*)scanDeviceID scanQuality:(NSUInteger)quality
{
    [deviceProvider scanFingerprint:scanDeviceID quality:quality scanBlock:^(FingerprintScanResult *result) {
        
        if (_scanCount == 1)
        {
            scanFingerPrintTemplate.template1 = result.template0;
            
            NSString *description = [NSString stringWithFormat:@"%@\n%@"
                                     , NSLocalizedString(@"verify_finger", nil)
                                     ,[NSString stringWithFormat:NSLocalizedString(@"quality %ld", nil), result.enroll_quality]];
            descriptionLabel.text = description;
            [self showPopupAnimation:containerView];
            
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //code to be executed on the main queue after delay
                
                // verify_fingerprint api 호출
                [self requestVerifyFingerprint:self.deviceID template:scanFingerPrintTemplate];
            });
        }
        else
        {
            // 스캔 받은 정보로 2가지 템블릿으로 만들기
            scanFingerPrintTemplate.template0 = result.template0;
            
            _scanCount++;
            scanImage.image = [UIImage imageNamed:@"user_fp2"];
            NSString *description = [NSString stringWithFormat:@"%@\n%@"
                                     ,[NSString stringWithFormat:NSLocalizedString(@"quality %ld", nil), result.enroll_quality]
                                     ,NSLocalizedString(@"finger_on_device_same", nil)];
            
            descriptionLabel.text = description;
            
            [self showPopupAnimation:containerView];
            [self requestScanFingerprint:self.deviceID scanQuality:quality];
            
        }
        
    } onError:^(Response *error) {
        
        if ([error.status_code isEqualToString:@"SCAN_QUALITY_IS_LOW"])
        {
            // 재 스캔 방법 팝업 띄우기
            errorMessage = error.message;
            [self showScanMethodSelectPopup];
        }
        else
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
            imagePopupCtrl.type = MAIN_REQUEST_FAIL;
            imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
            [imagePopupCtrl setContent:error.message];
            
            [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
            
            [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
                if (isConfirm)
                {
                    [self showPopupAnimation:containerView];
                    [self requestScanFingerprint:self.deviceID scanQuality:quality];
                }
                else
                {
                    [self closePopup:self parentViewController:self.parentViewController];
                }
            }];
        }
        
    }];
    
    
    
}

- (void)requestVerifyFingerprint:(NSString*)scanDeviceID template:(FingerprintTemplate*)fingerprintTemplate
{
    
    [deviceProvider verifyFingerprint:scanDeviceID firstTemplate:fingerprintTemplate.template0 secondTemplate:fingerprintTemplate.template1 verifyBlock:^(VerifyFingerprintResult *result) {
        
        if (result.verify_result)
        {
            scanImage.image = [UIImage imageNamed:@"user_fp3"];
            descriptionLabel.text = NSLocalizedString(@"scan_success", nil);
            [confirmButton setHidden:NO];
        }
        else
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
            imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
            [imagePopupCtrl setContent:result.message];
            
            [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
            [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
                if (isConfirm)
                {
                    [self showPopupAnimation:containerView];
                    [self requestScanFingerprint:self.deviceID scanQuality:self.scanQuality];
                }
                else
                {
                    if (self.boolResponseBlock)
                    {
                        self.boolResponseBlock(result.verify_result);
                        self.boolResponseBlock = nil;
                    }
                    [self closePopup:self parentViewController:self.parentViewController];
                }
            }];
        }
        
    } onError:^(Response *error) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self showPopupAnimation:containerView];
                [self requestScanFingerprint:self.deviceID scanQuality:self.scanQuality];
            }
            else
            {
                [self closePopup:self parentViewController:self.parentViewController];
            }
        }];
        
    }];
    
    
}

- (void)showScanMethodSelectPopup
{
    if (self.lowQualityBlock)
    {
        self.lowQualityBlock(scanFingerPrintTemplate, errorMessage);
        self.lowQualityBlock = nil;
    }
    [self closePopup:self parentViewController:self.parentViewController];
}

- (IBAction)confirmPopup:(id)sender
{
    if (self.fingerprintTemplateBlock)
    {
        self.fingerprintTemplateBlock(scanFingerPrintTemplate);
        self.fingerprintTemplateBlock = nil;
    }
    [self closePopup:self parentViewController:self.parentViewController];
}

- (void)setScanIndex:(NSInteger)index
{
    scanIndex = index;
    
}


@end
