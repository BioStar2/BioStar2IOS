//
//  MornitoringPopupViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2017. 2. 9..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import "MornitoringPopupViewController.h"

@interface MornitoringPopupViewController ()

@end

@implementation MornitoringPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    titleLabel.text = NSBaseLocalizedString(@"view_log", nil);
    [confirmBtn setTitle:NSBaseLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    [containerView setHidden:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [super popupViewDidAppear:contentView];
    [containerView setHidden:NO];
    [self showPopupAnimation:containerView];
}

-(void)viewDidLayoutSubviews {
    [contentTextView setContentOffset:CGPointZero animated:NO];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



- (IBAction)closePopup:(id)sender
{
    [self closePopup:self parentViewController:self.parentViewController];
}

- (void)setContent:(EventLogResult*)event;
{
    SimpleUser *user = event.user;
    SimpleModel *device = event.device;
    
    EventType *eventType = event.event_type;
    
    NSString *description = [self getDiscription:eventType];
    NSString *date;
    
    if (nil == user.user_id)
    {
        // 2줄 또는 3줄
        if (nil == device.id)
        {
            NSString *content = [NSString stringWithFormat:@"%@\n\n\n",description];
            contentTextView.text = content;
        }
        else
        {
            // 3줄
            date = [self getDate:event];
            
            NSString *extraDescription;
            if (!device.name)
            {
                extraDescription = [NSString stringWithFormat:@"%@ / %@",
                                    device.id,
                                    device.id];
            }
            else
            {
                extraDescription = [NSString stringWithFormat:@"%@ / %@",
                                    device.id,
                                    device.name];
            }
            
            NSString *content = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n\n\n",description ,date, NSBaseLocalizedString(@"device", nil), extraDescription];
            
            contentTextView.text = content;
        }
    }
    else
    {
        // 4줄
        date = [self getDate:event];
        
        NSString *extraDescription = [NSString stringWithFormat:@"%@ / %@",
                                      device.id,
                                      device.name];
        
        NSString *userName = user.name;
        NSString *userID = user.user_id;
        NSString *IDLabelText;
        if (nil == userName || [userName isEqualToString:@""])
        {
            IDLabelText = [NSString stringWithFormat:@"%@ / %@", userID, userID];
        }
        else
        {
            IDLabelText = [NSString stringWithFormat:@"%@ / %@", userID, userName];
        }
        
        NSString *content = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@\n\n\n",
                             description ,
                             date,
                             NSBaseLocalizedString(@"user", nil),
                             IDLabelText,
                             NSBaseLocalizedString(@"device", nil),
                             extraDescription];
        
        contentTextView.text = content;
    }
    
}

- (NSString*)getDiscription:(EventType *)eventType
{
    NSString *description;
    
    if (nil == eventType.event_type_description)
    {
        NSInteger code = eventType.code;
        if (code > 4095 && code < 4110)
        {
            code = 4096;
        }
        else if (code > 4351 && code < 4360)
        {
            code = 4352;
        }
        else if (code > 4607 && code < 4622)
        {
            code = 4608;
        }
        else if (code > 4863 && code < 4869)
        {
            code = 4864;
        }
        else if (code > 5119 && code < 5128)
        {
            code = 5120;
        }
        
        NSString *detail = [EventProvider convertEventCodeToDescription:code];
        if (nil == detail)
        {
            description = [NSString stringWithFormat:@"%ld", (unsigned long)code];
        }
        else
        {
            description = detail;
        }
    }
    else
    {
        description = eventType.event_type_description;
    }
    
    return description;
}

- (NSString*)getDate:(EventLogResult *)event
{
    NSString *date;
    NSDate *calculatedDate = [CommonUtil localDateFromString:event.datetime originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    
    NSString *timeFormat;
    
    if ([[LocalDataManager getTimeFormat] isEqualToString:@"hh:mm a"])
    {
        timeFormat = [NSString stringWithFormat:@"%@ %@",[LocalDataManager getDateFormat], @"hh:mm:ss a"];
    }
    else
    {
        timeFormat = [NSString stringWithFormat:@"%@ %@:ss",[LocalDataManager getDateFormat], [LocalDataManager getTimeFormat]];
    }
    
    date = [NSString stringWithFormat:@"%@",
            [CommonUtil stringFromCurrentLocaleDateString:[calculatedDate description]
                                         originDateFormat:@"YYYY-MM-dd HH:mm:ss z"
                                          transDateFormat:timeFormat]];
    
    return date;
}
@end
