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

typedef enum
{
    FINGERPRINT_SCAN,
    CARD_SCAN,
    CARD_REGIST,
    
} ScanType;

@protocol ScanPopupViewControllerDelegate <NSObject>

@optional

- (void)fingerprintScanDidSuccess:(NSDictionary*)fingerprintTemplate;
- (void)fingerprintScanDidFail:(NSDictionary*)result currentFingerPrintDic:(NSMutableDictionary*)fingerdic currentScanCount:(NSInteger)scanCount;
- (void)fingerVerificationDidComplete:(BOOL)result;

- (void)cardScanDidSuccess:(NSDictionary*)cardInfo;
- (void)cardScanDidFail:(NSDictionary*)result;

- (void)cardRegistDidSuccess:(NSDictionary*)cardInfo;
- (void)cardRegistDidFail:(NSDictionary*)result;

@end

@interface ScanPopupViewController : BaseViewController <DeviceProviderDelegate>
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
    BOOL isRequesting;
    NSInteger scanIndex;
    NSDictionary *cardInfo;
    NSDictionary *registCardErrorDic;
    
}

@property (strong, nonatomic) NSMutableDictionary *fingerPrintDic;
@property (assign, nonatomic) NSInteger scanCount;
@property (assign, nonatomic) NSInteger templateIndex;
@property (assign, nonatomic) ScanType scanType;
@property (strong, nonatomic) NSString *deviceID;
@property (assign, nonatomic) id <ScanPopupViewControllerDelegate> delegate;


- (void)setScanIndex:(NSInteger)index;
- (void)scanFingerprint:(NSString*)deviceID;
- (IBAction)confirmPopup:(id)sender;

@end
