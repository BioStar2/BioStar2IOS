//
//  ScanQualityPopupViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 14..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "ScanQualityPopupViewController.h"

@interface ScanQualityPopupViewController ()

- (IBAction)finishedCualityValue:(UISlider *)sender;
- (IBAction)qualityValueHasChanged:(UISlider *)sender;

@end

@implementation ScanQualityPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSharedViewController:self];
    // Do any additional setup after loading the view.
    
    [cancelBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    
    [self showPopupAnimation:containerView];
    
    titleLabel.text = NSLocalizedString(@"rescan_change", nil);
    
    currentQuality = 80;
    qualityLabel.text = [NSString stringWithFormat:@"%ld", (long)currentQuality];
    
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


- (void)getResponse:(QualityPopupResponseBlock)responseBlock
{
    self.qualityResponse = responseBlock;
}

- (void)getCancelResponse:(QualityPopupCancelBlock)cancelBlock
{
    self.cancelResponse = cancelBlock;
}

- (IBAction)confirmPopup:(id)sender
{
    if (self.qualityResponse)
    {
        self.qualityResponse(currentQuality);
        self.qualityResponse = nil;
    }
    [self closePopup:self parentViewController:self.parentViewController];
}

- (IBAction)cancelPopup:(id)sender {
    if (self.cancelResponse)
    {
        self.cancelResponse();
        self.cancelResponse = nil;
    }
    
    [self closePopup:self parentViewController:self.parentViewController];
}

- (NSUInteger)calculateCurrentQuality:(float)value
{
    NSUInteger finalValue = 0;
    if (20 <= value && value <= 30)
    {
        finalValue = 20;
    }
    else if (30 < value && value <= 40)
    {
        finalValue = 40;
    }
    else if (40 < value && value <= 50)
    {
        finalValue = 40;
    }
    else if (50 < value && value <= 60)
    {
        finalValue = 60;
    }
    else if (60 < value && value <= 70)
    {
        finalValue = 60;
    }
    else if (70 < value && value <= 80)
    {
        finalValue = 80;
    }
    else if (80 < value && value <= 90)
    {
        finalValue = 80;
    }
    else if (90 < value && value <= 100)
    {
        finalValue = 100;
    }
    
    return finalValue;
}

- (IBAction)finishedCualityValue:(UISlider *)sender
{
    NSUInteger value = [self calculateCurrentQuality:sender.value];
    [sender setValue:value animated:YES];
    currentQuality = value;
    qualityLabel.text = [NSString stringWithFormat:@"%ld", (long)currentQuality];
}


- (IBAction)qualityValueHasChanged:(UISlider *)sender
{
    //NSLog(@"qualityValueHasChanged");
}

- (IBAction)finishedOutsideQualityValue:(UISlider *)sender {
    NSUInteger value = [self calculateCurrentQuality:sender.value];
    [sender setValue:value animated:YES];
    currentQuality = value;
    qualityLabel.text = [NSString stringWithFormat:@"%ld", (long)currentQuality];
}


@end
