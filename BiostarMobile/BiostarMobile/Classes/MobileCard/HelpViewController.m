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
    
    [continuouslyCloseButton setTitle:NSBaseLocalizedString(@"donot_again", nil) forState:UIControlStateNormal];
    descriptionLabel.text = [NSString stringWithFormat:@"%@\n%@",NSBaseLocalizedString(@"guide_register_mobile_card1", nil) ,NSBaseLocalizedString(@"guide_register_mobile_card2", nil)];
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
    
    [buttonDatas removeAllObjects];
    
    // 순서대로 my profile, user, door, monitoring, alarm,
    
    ButtonModel *model = [[ButtonModel alloc] init];
    model.title = NSBaseLocalizedString(@"myprofile_upper", nil);
    model.normalImage = [UIImage imageNamed:@"main_myprofile_ic"];
    model.highlightedImage = [UIImage imageNamed:@"main_myprofile_ic_pre"];
    model.type = MYPROFILE_BUTTON;
    
    [buttonDatas addObject:model];
    
    if ([AuthProvider hasReadPermission:USER_PERMISSION])
    {
        ButtonModel *model = [[ButtonModel alloc] init];
        model.title = NSBaseLocalizedString(@"user_upper", nil);
        model.normalImage = [UIImage imageNamed:@"main_user_id"];
        model.highlightedImage = [UIImage imageNamed:@"main_user_id_pre"];
        model.icon = [UIImage imageNamed:@"list_user_ic"];
        model.type = USER_BUTTON;
        
        [buttonDatas addObject:model];
    }
    
    if ([AuthProvider hasReadPermission:DOOR_PERMISSION])
    {
        ButtonModel *model = [[ButtonModel alloc] init];
        model.title = NSBaseLocalizedString(@"door_upper", nil);
        model.normalImage = [UIImage imageNamed:@"main_door_ic"];
        model.highlightedImage = [UIImage imageNamed:@"main_door_ic_pre"];
        model.icon = [UIImage imageNamed:@"list_door_ic"];
        model.type = DOOR_BUTTON;
        
        [buttonDatas addObject:model];
    }

    if ([AuthProvider hasReadPermission:MONITORING_PERMISSION])
    {
        ButtonModel *model = [[ButtonModel alloc] init];
        model.title = NSBaseLocalizedString(@"monitoring_upper", nil);
        model.normalImage = [UIImage imageNamed:@"main_monitor_ic"];
        model.highlightedImage = [UIImage imageNamed:@"main_monitor_ic_pre"];
        model.icon = [UIImage imageNamed:@"list_monitor_ic"];
        model.type = MONITORING_BUTTON;
        
        [buttonDatas addObject:model];
    }
    
    if ([AuthProvider hasReadPermission:MONITORING_PERMISSION])
    {
        ButtonModel *model = [[ButtonModel alloc] init];
        model.title = NSBaseLocalizedString(@"alarm_upper", nil);
        model.normalImage = [UIImage imageNamed:@"main_alarm_ic"];
        model.highlightedImage = [UIImage imageNamed:@"main_alram_ic_pre"];
        model.icon = [UIImage imageNamed:@"list_alram_ic"];
        model.count = [AuthProvider getLoginUserInfo].unread_notification_count;
        model.type = ALARM_BUTTON;
        
        [buttonDatas addObject:model];
    }
    
    if ([PreferenceProvider isSupportMobileCredentialAndFaceTemplate])
    {
        ButtonModel *model = [[ButtonModel alloc] init];
        model.title = NSBaseLocalizedString(@"mobile_card_upper", nil);
        model.normalImage = [UIImage imageNamed:@"main_card_ic"];
        model.highlightedImage = [UIImage imageNamed:@"main_card_ic_pre"];
        model.icon = [UIImage imageNamed:@"list_mobilecard_ic"];
        model.type = MOBILE_CARD_BUTTON;
        
        [buttonDatas addObject:model];
    }
    
    if (buttonDatas.count > 3)
    {
        // 두줄 배치
        //bottomConstraint.constant = 0;
        stackViewBottomConstraint.constant = 0;
    }
    else
    {
        // 한줄 배치
        //bottomConstraint.constant = -60;
        stackViewBottomConstraint.constant = -100;
    }
    
    buttonsTouchDown = @selector(buttonsTouchDown:);
    buttonsTouchUpOutside = @selector(buttonsTouchUpOutside:);
    buttonsTouchUpInside = @selector(buttonsTouchUpInside:);
    
    BOOL isFourButtons = NO;
    if (buttonDatas.count < 6)
    {
        if (buttonDatas.count == 4)
        {
            isFourButtons = YES;
        }
        
        for (int i = 0; i < 6 - buttonDatas.count; i++)
        {
            ButtonModel *model = [[ButtonModel alloc] init];
            model.title = @"";
            model.normalImage = nil;
            model.highlightedImage = nil;
            model.icon = nil;
            model.type = EMPTY_BUTTON;
            [buttonDatas addObject:model];
        }
    }
    
    
    for (NSInteger i = 0; i < buttonDatas.count; i ++)
    {
        //        UILabel *label = [buttonLabels objectAtIndex:i];
        //        UIButton *button = [buttons objectAtIndex:i];
        
        UILabel *label = [stackViewLabels objectAtIndex:i];
        UIButton *button = [stackViewButtons objectAtIndex:i];
        UIImageView *dotBox = [stackDotBoxes objectAtIndex:i];
        [dotBox setHidden:NO];
        button.tag = i;
        label.tag = i;
        
        ButtonModel *model = [buttonDatas objectAtIndex:i];
        [button setImage:model.normalImage forState:UIControlStateNormal];
        [button setImage:model.highlightedImage forState:UIControlStateHighlighted];
        [button addTarget:self action:buttonsTouchDown forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:buttonsTouchUpOutside forControlEvents:UIControlEventTouchUpOutside];
        [button addTarget:self action:buttonsTouchUpInside forControlEvents:UIControlEventTouchUpInside];
        
        if (!isFourButtons)
        {
            UIView *buttonView = [buttonViews objectAtIndex:i];
            if (model.type == EMPTY_BUTTON)
            {
                [buttonView setHidden:YES];
            }
            else
            {
                [buttonView setHidden:NO];
            }
        }
        
        if (model.type == MOBILE_CARD_BUTTON)
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
        }
        else
        {
            [button setHidden:YES];
            [label setHidden:YES];
            [dotBox setHidden:YES];
        }
        
        [label setText:model.title];
        
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
    [LocalDataManager confirmShowHelpView];
    [self closePopup:self parentViewController:self.parentViewController];
}

- (IBAction)closeHelpViewContinuously:(id)sender
{
    [self closePopup:self parentViewController:self.parentViewController];
}

- (IBAction)closeView:(id)sender
{
    [self closePopup:self parentViewController:self.parentViewController];
}
@end
