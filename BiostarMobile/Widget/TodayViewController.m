//
//  TodayViewController.m
//  Widget
//
//  Created by 정의석 on 2017. 8. 3..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    settingLabel.text = NSBaseLocalizedString(@"ble_auto_scan", nil);
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
    // 카드가 없거나 저장된 카드 아이디와 서버에서 불러온 카드 ID 가 틀리면 유효하지 않은 카드라고 노출시키기
    [self checkValidMobileCredential];
    
    isValidMobileCredential = [self isValidMobileCredential];
    
    if ([self isSupportMobileCredential])
    {
        cbController = [[CBCentralManagerController alloc] init];
        cbController.delegate = self;
    }
    else
    {
        NSString *dec = [NSString stringWithFormat:@"2.4.1 %@", NSBaseLocalizedString(@"need_latest_server_version", nil)];
        
        [openButton setTitle:dec forState:UIControlStateNormal];
        [openButton setEnabled:NO];
        [settingSwitch setOn:NO];
        [settingSwitch setEnabled:NO];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSLog(@"viewWillDisappear");
    [cbController stopScan];
    cbController.delegate = nil;
    cbController = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (BOOL)isSupportMobileCredential
{
    NSString *version = [LocalDataManager getBiostarACVersion];
    if ([BLE_SUPPORT_VERSION compare:version options:NSNumericSearch] == NSOrderedDescending)
    {
        // V1
        return NO;
    }
    else
    {
        // SupportMobileCredential
        return YES;
    }
    
}

- (BOOL)isValidMobileCredential
{
    NSDictionary *mobileCredential = [LocalDataManager getMobileCredential];
    
    if (!mobileCredential || mobileCredential.count < 1)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)checkValidMobileCredential;
{
    if ([self isValidMobileCredential])
    {
        [openButton setTitle:NSBaseLocalizedString(@"tap_to_open", nil) forState:UIControlStateNormal];
        BOOL isAutoscanEnabled = [LocalDataManager getAutoscanStatus];
        [settingSwitch setOn:isAutoscanEnabled];
        
        [openButton setEnabled:!isAutoscanEnabled];
    }
    else
    {
        [openButton setTitle:NSBaseLocalizedString(@"invalid_card", nil) forState:UIControlStateNormal];
        [openButton setEnabled:NO];
    }
    
}

- (IBAction)scanBLE:(id)sender {
    
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    [cbController loadMobileCredential];
    [cbController scanBLE];
}

- (IBAction)setAutoscan:(id)sender {
    
    BOOL isOn = settingSwitch.isOn;
    [LocalDataManager setAutoscan:isOn];
    
    [self checkValidMobileCredential];
    
    if (isOn)
    {
        [cbController loadMobileCredential];
        [cbController scanBLE];
    }
    else
        [cbController stopScan];
}

- (void)BLEConnectionStatusChanged:(BLEConnectionStatus)connectionStatus
{
    if (isValidMobileCredential)
    {
        BOOL isAutoscanEnabled = [LocalDataManager getAutoscanStatus];

        switch (connectionStatus) {
            case POWER_OFF:
                break;
            case READY_TO_SCAN:
            {
                if (isAutoscanEnabled)
                {
                    [cbController loadMobileCredential];
                    [cbController scanBLE];
                    [openButton setTitle:NSBaseLocalizedString(@"tap_to_open", nil) forState:UIControlStateNormal];
                    [openButton setEnabled:NO];
                }
                else
                {
                    [cbController stopScan];
                    [openButton setTitle:NSBaseLocalizedString(@"tap_to_open", nil) forState:UIControlStateNormal];
                    [openButton setEnabled:YES];
                }

            }
                break;

            case SCANNING:
                NSLog(@"블루투스 스캔 시작");
                [openButton setTitle:NSBaseLocalizedString(@"tap_to_open", nil) forState:UIControlStateNormal];
                [openButton setEnabled:NO];
                break;

            case TRYING_TO_SCAN:

                break;

            case CONNECTING:

                break;
            case FAIL_TO_CONNECT:
                break;
            case CONNECTED:

                break;

            case DISCONNECTED:
                [openButton setTitle:NSBaseLocalizedString(@"tap_to_open", nil) forState:UIControlStateNormal];
                [openButton setEnabled:YES];
                break;
            case DISCONNECTED_WITH_ERROR:
                [openButton setTitle:NSBaseLocalizedString(@"tap_to_open", nil) forState:UIControlStateNormal];
                [openButton setEnabled:YES];
                break;
            case STATUS_NONE:

                break;

            case SUCCESS_TRANSACTION:

                break;
            case FAILED_TRANSACTION:

                break;
        }
    }
    else
    {
        [openButton setTitle:NSBaseLocalizedString(@"invalid_card", nil) forState:UIControlStateNormal];
        [openButton setEnabled:NO];
        [cbController stopScan];
    }
    
}
@end
