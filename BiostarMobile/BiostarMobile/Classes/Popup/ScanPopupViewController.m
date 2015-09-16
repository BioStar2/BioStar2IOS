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
    // Do any additional setup after loading the view.
    [self showPopupAnimation:containerView];
    deviceProvider = [[DeviceProvider alloc] init];
    deviceProvider.delegate = self;
    
    switch (_scanType)
    {
        case FINGERPRINT_SCAN:
            if (nil == _fingerPrintDic)
            {
                _fingerPrintDic = [[NSMutableDictionary alloc] init];
            }
            
            [deviceProvider scanFingerprint:_deviceID];
            //[self startLoading:self];
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
            
            break;
            
        case CARD_SCAN:
            titleLabel.text = NSLocalizedString(@"add_card", nil);
            descriptionLabel.text = NSLocalizedString(@"card_on_device", nil);
            scanImage.image = [UIImage imageNamed:@"user_card1"];
            [deviceProvider scanCard:_deviceID];
            break;
            
        default:
            break;
    }
    
    isRequesting = YES;
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

- (IBAction)confirmPopup:(id)sender
{
    switch (_scanType)
    {
        case FINGERPRINT_SCAN:
            if ([self.delegate respondsToSelector:@selector(fingerprintScanDidSuccess:)])
            {
                [self.delegate fingerprintScanDidSuccess:_fingerPrintDic];
                [self closePopup:self parentViewController:self.parentViewController];
            }
            break;
            
        case CARD_SCAN:
            _scanType = CARD_REGIST;
            if ([self.delegate respondsToSelector:@selector(cardRegistDidSuccess:)])
            {
                [self.delegate cardRegistDidSuccess:cardInfo];
            }
            [self closePopup:self parentViewController:self.parentViewController];
            break;
            
        default:
            break;
    }
    
}

- (void)scanFingerprint:(NSString*)deviceID
{
    [deviceProvider scanFingerprint:deviceID];
}

- (void)setScanIndex:(NSInteger)index
{
    scanIndex = index;
    
}

#pragma mark - DeviceProviderDelegate

- (void)requestRegisterCardDidFinish:(NSDictionary*)dic
{
    cardInfo = dic;
    [self finishLoading];
    
    if ([self.delegate respondsToSelector:@selector(cardRegistDidSuccess:)])
    {
        [self.delegate cardRegistDidSuccess:cardInfo];
    }

    [self closePopup:self parentViewController:self.parentViewController];
}

- (void)requestScanCardDidFinish:(NSDictionary*)dic
{
    cardIDLabel.text = [dic objectForKey:@"card_id"];
    isRequesting = NO;
    
    [cardConfirmView setHidden:NO];
    [scanImage setHidden:YES];
    [confirmButton setHidden:NO];
    
    cardInfo = [[NSDictionary alloc] initWithDictionary:dic];
}

- (void)requestScanFingerprintDidFinish:(NSDictionary*)dic
{
    //[self finishLoading];
    
    isRequesting = NO;
    
    [_fingerPrintDic setObject:[NSNumber numberWithInteger:_templateIndex] forKey:@"finger_index"];
    [_fingerPrintDic setObject:[NSNumber numberWithBool:NO] forKey:@"finger_mask"];
    
    if (_scanCount == 1)
    {
        if ([[dic objectForKey:@"enroll_quality"] integerValue] > 40)
        {
            [_fingerPrintDic setObject:[dic objectForKey:@"template0"] forKey:@"template1"];
            [_fingerPrintDic setObject:[dic objectForKey:@"template_image0"] forKey:@"template_image1"];
            
            // verify_fingerprint api 호출
            NSString *description = [NSString stringWithFormat:@"%@\n%@"
                                        , NSLocalizedString(@"verify_finger", nil)
                                        ,[NSString stringWithFormat:NSLocalizedString(@"quality %ld", nil), [[dic objectForKey:@"enroll_quality"] integerValue]]];
            descriptionLabel.text = description;
            [deviceProvider verifyFingerprint:_deviceID firstTemplate:[_fingerPrintDic objectForKey:@"template0"] secondTemplate:[_fingerPrintDic objectForKey:@"template1"]];

        }
        else
        {
           
            descriptionLabel.text = NSLocalizedString(@"finger_on_device_same", nil);
            
            [deviceProvider scanFingerprint:_deviceID];
            //[self startLoading:self];
        }
    }
    else
    {
        
        // 스캔 받은 정보로 2가지 템블릿으로 만들기
        
        [_fingerPrintDic setObject:[dic objectForKey:@"template0"] forKey:@"template0"];
        [_fingerPrintDic setObject:[dic objectForKey:@"template_image0"] forKey:@"template_image0"];
        
        if ([[dic objectForKey:@"enroll_quality"] integerValue] > 40)
        {
            _scanCount++;
            scanImage.image = [UIImage imageNamed:@"user_fp2"];
            NSString *description = [NSString stringWithFormat:@"%@\n%@"
                                     ,[NSString stringWithFormat:NSLocalizedString(@"quality %ld", nil), [[dic objectForKey:@"enroll_quality"] integerValue]]
                                     ,NSLocalizedString(@"finger_on_device_same", nil)];

            descriptionLabel.text = description;
        }
        
        [deviceProvider scanFingerprint:_deviceID];
    }
    
}

- (void)requestVerifyFingerprint:(NSDictionary*)dic
{
    if ([[dic objectForKey:@"verify_result"] boolValue])
    {
        scanImage.image = [UIImage imageNamed:@"user_fp3"];
        descriptionLabel.text = NSLocalizedString(@"scan_success", nil);
        [confirmButton setHidden:NO];
    }
    else
    {
        [self closePopup:self parentViewController:self.parentViewController];
    }
    if ([self.delegate respondsToSelector:@selector(fingerVerificationDidComplete:)])
    {
        [self.delegate fingerVerificationDidComplete:[[dic objectForKey:@"verify_result"] boolValue]];
    }
}

- (void)requestGetCardsDidFinish:(NSDictionary *)cardColletion
{
    [self finishLoading];
    
    if (![[cardColletion objectForKey:@"rows"] isKindOfClass:[NSArray class]])
    {
        // 일치하는 카드 없을때 실패로 리턴시켜주기
        if ([self.delegate respondsToSelector:@selector(cardRegistDidFail:)])
        {
            [self.delegate cardRegistDidFail:registCardErrorDic];
        }
        [self closePopup:self parentViewController:self.parentViewController];
        return;
    }
    
    NSArray *cards = [cardColletion objectForKey:@"rows"];
    switch (cards.count)
    {
        case 0:
            // 일치하는 카드 없을때 실패로 리턴시켜주기
            if ([self.delegate respondsToSelector:@selector(cardRegistDidFail:)])
            {
                [self.delegate cardRegistDidFail:registCardErrorDic];
            }
            break;
        case 1:
            // 하나만 일치하면 그 카드로 추가
            if ([self.delegate respondsToSelector:@selector(cardRegistDidSuccess:)])
            {
                [self.delegate cardRegistDidSuccess:[cards objectAtIndex:0]];
            }
            break;
        default:
            // 하나 이상일때 아이디 비교해서 동일한 카드 추가
            for (NSDictionary *card in cardColletion)
            {
                NSInteger cardID = [[card objectForKey:@"card_id"] integerValue];
                if ([[cardInfo objectForKey:@"card_id"] integerValue] == cardID)
                {
                    if ([self.delegate respondsToSelector:@selector(cardRegistDidSuccess:)])
                    {
                        [self.delegate cardRegistDidSuccess:card];
                        break;
                    }
                }
            }
            break;
    }
    [self closePopup:self parentViewController:self.parentViewController];
   
}

- (void)requestDeviceProviderDidFail:(NSDictionary*)errDic
{
    [self finishLoading];
    
    isRequesting = NO;
    
    switch (_scanType)
    {
        case FINGERPRINT_SCAN:
            if ([self.delegate respondsToSelector:@selector(fingerprintScanDidFail:currentFingerPrintDic:currentScanCount:)])
            {
                [self.delegate fingerprintScanDidFail:errDic currentFingerPrintDic:_fingerPrintDic currentScanCount:_scanCount];
            }
            break;
           
        case CARD_SCAN:
            if ([self.delegate respondsToSelector:@selector(cardScanDidFail:)])
            {
                [self.delegate cardScanDidFail:errDic];
            }
            break;
           
        case CARD_REGIST:
            if ([[errDic objectForKey:@"code"] integerValue] == 65651)
            {
                //가져온 카드 목록중에서 카드가 존재하는지 비교후에 존재하면 그 카드 어레인지
                registCardErrorDic = errDic;
                [deviceProvider getCard:[[cardInfo objectForKey:@"card_id"] integerValue]];

                [self startLoading:self];
                return;
            }
            if ([self.delegate respondsToSelector:@selector(cardRegistDidFail:)])
            {
                [self.delegate cardRegistDidFail:errDic];
            }
            break;
            
        default:
            break;
    }
    
    [self closePopup:self parentViewController:self.parentViewController];
}

@end
