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

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "DeviceProvider.h"
#import "ImagePopupViewController.h"
#import "FingerprintTemplate.h"
#import "ListPopupViewController.h"
#import "ScanQualityPopupViewController.h"

@interface ScanPopupViewController : BaseViewController 
{
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIImageView *scanImage;
    __weak IBOutlet UILabel *descriptionLabel;
    __weak IBOutlet UIButton *confirmButton;
    __weak IBOutlet UIView *cardConfirmView;
    __weak IBOutlet UILabel *cardIDLabel;
    __weak IBOutlet UIView *contentView;

    
    DeviceProvider *deviceProvider;
    NSInteger scanIndex;
    NSString *errorMessage;
    FingerprintTemplate *scanFingerPrintTemplate;
}

typedef void (^ScanPopupTemplateBlock)(FingerprintTemplate *fingerprintTemplate);
typedef void (^ScanPopupLowQualityTemplateBlock)(FingerprintTemplate *fingerprintTemplate, NSString *errorMessage);
typedef void (^ScanPopupBOOLResponseBlock)(BOOL result);


@property (nonatomic, strong) ScanPopupTemplateBlock fingerprintTemplateBlock;
@property (nonatomic, strong) ScanPopupBOOLResponseBlock boolResponseBlock;
@property (nonatomic, strong) ScanPopupLowQualityTemplateBlock lowQualityBlock;

@property (assign, nonatomic) NSInteger scanCount;
@property (assign, nonatomic) NSInteger templateIndex;
@property (strong, nonatomic) NSString *deviceID;
@property (assign, nonatomic) NSUInteger scanQuality;

- (void)setFingerprint:(FingerprintTemplate*)fingerPrintTemplate;

- (void)getFingerPrintTemplate:(ScanPopupTemplateBlock)fingerprintTemplateBlock;

- (void)getBoolResponse:(ScanPopupBOOLResponseBlock)boolResponseBlock;

- (void)getLowQualityBlock:(ScanPopupLowQualityTemplateBlock)lowQualityBlock;

- (void)requestScanFingerprint:(NSString*)scanDeviceID scanQuality:(NSUInteger)quality;

- (void)requestVerifyFingerprint:(NSString*)scanDeviceID template:(FingerprintTemplate*)fingerprintTemplate;

- (void)setScanIndex:(NSInteger)index;

- (void)showScanMethodSelectPopup;

- (IBAction)confirmPopup:(id)sender;

@end
