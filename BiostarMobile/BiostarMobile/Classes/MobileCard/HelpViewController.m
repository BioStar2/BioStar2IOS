//
//  HelpViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 9. 23..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [continuouslyCloseButton setTitle:NSLocalizedString(@"donot_again", nil) forState:UIControlStateNormal];
    descriptionLabel.text = [NSString stringWithFormat:@"%@\n%@",NSLocalizedString(@"guide_register_mobile_card1", nil) ,NSLocalizedString(@"guide_register_mobile_card2", nil)];
    buttonDatas = [[NSMutableArray alloc] init];
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setMenuItems];
}

- (void)setMenuItems
{
    
    // 순서대로 user, monitoring, alarm, my profile, door
    if ([AuthProvider hasReadPermission:USER_PERMISSION])
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:
                                    @{@"LABEL" : NSLocalizedString(@"user_upper", nil),
                                      @"NORMAL_IMAGE" : [UIImage imageNamed:@"main_user_id"],
                                      @"HIGHLIGHTED_IMAGE" : [UIImage imageNamed:@"main_user_id_pre"],
                                      @"CELL_ICON" : [UIImage imageNamed:@"list_user_ic"],
                                      @"TYPE" : @"USER"}
                                    ];
        [buttonDatas addObject:dic];
    }
    
    if ([AuthProvider hasReadPermission:MONITORING_PERMISSION])
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:
                                    @{@"LABEL" : NSLocalizedString(@"monitoring_upper", nil),
                                      @"NORMAL_IMAGE" : [UIImage imageNamed:@"main_monitor_ic"],
                                      @"HIGHLIGHTED_IMAGE" : [UIImage imageNamed:@"main_monitor_ic_pre"],
                                      @"CELL_ICON" : [UIImage imageNamed:@"list_monitor_ic"],
                                      @"TYPE" : @"MONITORING"}
                                    ];
        
        [buttonDatas addObject:dic];
    }
    
    if ([AuthProvider hasWritePermission:DOOR_PERMISSION])
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:
                                    @{@"LABEL" : NSLocalizedString(@"alarm_upper", nil),
                                      @"NORMAL_IMAGE" : [UIImage imageNamed:@"main_alarm_ic"],
                                      @"HIGHLIGHTED_IMAGE" : [UIImage imageNamed:@"main_alram_ic_pre"],
                                      @"CELL_ICON" : [UIImage imageNamed:@"list_alram_ic"],
                                      @"TYPE" : @"ALARM"}
                                    ];
        
        [buttonDatas addObject:dic];
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:
                                @{@"LABEL" : NSLocalizedString(@"myprofile", nil),
                                  @"NORMAL_IMAGE" : [UIImage imageNamed:@"main_myprofile_ic"],
                                  @"HIGHLIGHTED_IMAGE" : [UIImage imageNamed:@"main_myprofile_ic_pre"],
                                  @"TYPE" : @"MYPROFILE"}
                                ];
    [buttonDatas addObject:dic];
    
    if ([AuthProvider hasReadPermission:DOOR_PERMISSION])
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:
                                    @{@"LABEL" : NSLocalizedString(@"door_upper", nil),
                                      @"NORMAL_IMAGE" : [UIImage imageNamed:@"main_door_ic"],
                                      @"HIGHLIGHTED_IMAGE" : [UIImage imageNamed:@"main_door_ic_pre"],
                                      @"CELL_ICON" : [UIImage imageNamed:@"list_door_ic"],
                                      @"TYPE" : @"DOOR"}
                                    ];
        
        [buttonDatas addObject:dic];
    }
#warning ble ad 원하는 OS 버전이면 스마트카드 메뉴 보이게
    if (YES)
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:
                                    @{@"LABEL" : NSLocalizedString(@"mobile_card_upper", nil),
                                      @"NORMAL_IMAGE" : [UIImage imageNamed:@"main_card_ic"],
                                      @"HIGHLIGHTED_IMAGE" : [UIImage imageNamed:@"main_card_ic_pre"],
                                      @"CELL_ICON" : [UIImage imageNamed:@"list_mobilecard_ic"],
                                      @"TYPE" : @"MOBILE_CARD"}
                                    ];
        
        [buttonDatas addObject:dic];
    }
    
    if (buttonDatas.count > 3)
    {
        // 두줄 배치
        bottomConstraint.constant = 0;
    }
    else
    {
        // 한줄 배치
        bottomConstraint.constant = -60;
    }
    
    buttonsTouchDown = @selector(buttonsTouchDown:);
    buttonsTouchUpOutside = @selector(buttonsTouchUpOutside:);
    buttonsTouchUpInside = @selector(buttonsTouchUpInside:);
    for (NSInteger i = 0; i < buttonDatas.count; i ++)
    {
        UILabel *label = [buttonLabels objectAtIndex:i];
        UIButton *button = [buttons objectAtIndex:i];
        UIImageView *dotImageView = [dotBoxes objectAtIndex:i];
        button.tag = i;
        label.tag = i;
        
        [button setImage:[[buttonDatas objectAtIndex:i] objectForKey:@"NORMAL_IMAGE"] forState:UIControlStateNormal];
        [button setImage:[[buttonDatas objectAtIndex:i] objectForKey:@"HIGHLIGHTED_IMAGE"] forState:UIControlStateHighlighted];
        [button addTarget:self action:buttonsTouchDown forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:buttonsTouchUpOutside forControlEvents:UIControlEventTouchUpOutside];
        [button addTarget:self action:buttonsTouchUpInside forControlEvents:UIControlEventTouchUpInside];
        
        
        if ([[[buttonDatas objectAtIndex:i] objectForKey:@"TYPE"] isEqualToString:@"MOBILE_CARD"])
        {
            [button addSubview:badgeAlertView];
            [badgeAlertView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [badgeAlertView setHidden:NO];
            [button addConstraint:[NSLayoutConstraint constraintWithItem:badgeAlertView
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:button
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:0.3
                                                                constant:0]];
            
            [button addConstraint:[NSLayoutConstraint constraintWithItem:badgeAlertView
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:button
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:0.3
                                                                constant:0]];
            
            
            [button addConstraint:[NSLayoutConstraint constraintWithItem:badgeAlertView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:button
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1
                                                                constant:0]];
            
            [button addConstraint:[NSLayoutConstraint constraintWithItem:badgeAlertView
                                                               attribute:NSLayoutAttributeTrailing
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:button
                                                               attribute:NSLayoutAttributeTrailing
                                                              multiplier:1
                                                                constant:0]];
            [dotImageView setHidden:NO];
        }
        else
        {
            [button setHidden:YES];
            [label setHidden:YES];
            [dotImageView setHidden:YES];
        }
        
        [label setText:[[buttonDatas objectAtIndex:i] objectForKey:@"LABEL"]];
        
    }
    
}

- (void)buttonsTouchDown:(UIButton*)sender
{
    NSInteger tag = sender.tag;
    UILabel *label = [buttonLabels objectAtIndex:tag];
    [label setTextColor:[UIColor colorWithRed:255/255.0 green:211/255.0 blue:131/255.0 alpha:1]];
    
}

- (void)buttonsTouchUpOutside:(UIButton*)sender
{
    NSInteger tag = sender.tag;
    UILabel *label = [buttonLabels objectAtIndex:tag];
    [label setTextColor:[UIColor colorWithRed:172/255.0 green:169/255.0 blue:161/255.0 alpha:1]];
    
}

- (void)buttonsTouchUpInside:(UIButton*)sender
{
    NSInteger tag = sender.tag;
    UILabel *label = [buttonLabels objectAtIndex:tag];
    [label setTextColor:[UIColor colorWithRed:172/255.0 green:169/255.0 blue:161/255.0 alpha:1]];
    
    NSString *buttonType = [[buttonDatas objectAtIndex:tag] objectForKey:@"TYPE"];
    
    if ([buttonType isEqualToString:@"MOBILE_CARD"])
    {
        if ([self.delegate respondsToSelector:@selector(mobileCardWasPressed)])
        {
            [self.delegate mobileCardWasPressed];
        }
    }
    
    [self closePopup:self parentViewController:self.parentViewController];
}

- (IBAction)closeHelpView:(id)sender
{
    [self closePopup:self parentViewController:self.parentViewController];
}

- (IBAction)closeHelpViewContinuously:(id)sender
{
    [self closePopup:self parentViewController:self.parentViewController];
}
@end
