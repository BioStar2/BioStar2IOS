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
    
    [cancelBtn setTitle:NSBaseLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSBaseLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    
    [self showPopupAnimation:containerView];
    
    titleLabel.text = NSBaseLocalizedString(@"rescan_change", nil);
    
    if (self.scanType == FACE_SCAN)
    {
        currentQuality = 4;
        qualitySlider.maximumValue = 9;
        qualitySlider.minimumValue = 0;
    }
    else
    {
        currentQuality = 80;
        qualitySlider.maximumValue = 100;
        qualitySlider.minimumValue = 20;
    }
    
    [qualitySlider setValue:currentQuality animated:NO];
    
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
    
    if (self.scanType == FACE_SCAN)
    {
        if (0 <= value && value <= 0.5)
        {
            finalValue = 0;
        }
        else if (0.5 < value && value <= 1)
        {
            finalValue = 1;
        }
        else if (1 < value && value <= 1.5)
        {
            finalValue = 1;
        }
        else if (1.5 < value && value <= 2)
        {
            finalValue = 2;
        }
        else if (2 < value && value <= 2.5)
        {
            finalValue = 2;
        }
        else if (2.5 < value && value <= 3)
        {
            finalValue = 3;
        }
        else if (3 < value && value <= 3.5)
        {
            finalValue = 3;
        }
        else if (3.5 < value && value <= 4)
        {
            finalValue = 4;
        }
        else if (4 < value && value <= 4.5)
        {
            finalValue = 4;
        }
        else if (4.5 < value && value <= 5)
        {
            finalValue = 5;
        }
        else if (5 < value && value <= 5.5)
        {
            finalValue = 5;
        }
        else if (5.5 < value && value <= 6)
        {
            finalValue = 6;
        }
        else if (6 < value && value <= 6.5)
        {
            finalValue = 6;
        }
        else if (6.5 < value && value <= 7)
        {
            finalValue = 7;
        }
        else if (7 < value && value <= 7.5)
        {
            finalValue = 7;
        }
        else if (7.5 < value && value <= 8)
        {
            finalValue = 8;
        }
        else if (8.5 < value && value <= 9)
        {
            finalValue = 9;
        }
        else if (9 < value)
        {
            finalValue = 9;
        }
        
        
    }
    else
    {
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
