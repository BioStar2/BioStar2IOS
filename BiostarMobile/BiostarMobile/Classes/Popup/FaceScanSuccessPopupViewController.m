//
//  FaceScanSuccessPopupViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2017. 3. 13..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import "FaceScanSuccessPopupViewController.h"

@interface FaceScanSuccessPopupViewController ()

@end

@implementation FaceScanSuccessPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSharedViewController:self];
    // Do any additional setup after loading the view.
    [self showPopupAnimation:containerView];
    [confirmButton setTitle:NSBaseLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    
    descriptionLabel.text = NSBaseLocalizedString(@"success", nil);
    
    useProfileImage = NO;
    
    userProvider = [UserProvider new];
    
    if (self.photo)
    {
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:self.photo options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *serverImage = [UIImage imageWithData:imageData];
        UIImage* scaledImage = [CommonUtil imageCompress:serverImage fileSize:MAX_IMAGE_FILE_SIZE];
        scanImage.image = scaledImage;
    }
    
    if (self.index == 0)
    {
        titleLabel.text = [NSString stringWithFormat:@"%ld%@ %@",
                           (long)self.index + 1, NSBaseLocalizedString(@"st", nil), NSBaseLocalizedString(@"face", nil)];
    }
    else if (self.index == 1)
    {
        titleLabel.text = [NSString stringWithFormat:@"%ld%@ %@",
                           (long)self.index + 1, NSBaseLocalizedString(@"nd", nil), NSBaseLocalizedString(@"face", nil)];
    }
    else if (self.index == 2)
    {
        titleLabel.text = [NSString stringWithFormat:@"%ld%@ %@",
                           (long)self.index + 1, NSBaseLocalizedString(@"rd", nil), NSBaseLocalizedString(@"face", nil)];
    }
    else
    {
        titleLabel.text = [NSString stringWithFormat:@"%ld%@ %@",
                           (long)self.index + 1, NSBaseLocalizedString(@"th", nil), NSBaseLocalizedString(@"face", nil)];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [super popupViewDidAppear:contentView];
    [self setStatusLabelIcon:useProfileImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (void)updateUser
{
    [self startLoading:self];
    
    [userProvider updateUserPhoto:self.currentUserID photo:self.photo completeHandler:^(Response *response) {
        [self finishLoading];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:USE_FACE_TEMPLATE
                                                            object:@{@"userID" :self.currentUserID,
                                                                     @"photo" : self.photo}];
        
        [self closePopup:self parentViewController:self.parentViewController];
        
    } onErrorBlock:^(Response *error) {
        
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = MAIN_REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self showPopupAnimation:containerView];
                [self updateUser];
            }
            else
            {
                [self closePopup:self parentViewController:self.parentViewController];
            }
        }];

        
    }];
}



- (void)setStatusLabelIcon:(BOOL)useImage
{
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    
    UIImage *icon;
    
    if (useImage)
    {
        icon = [UIImage imageNamed:@"check_box"];
    }
    else
    {
        icon = [UIImage imageNamed:@"check_box_blank"];
    }
    
    attachment.image = icon;
    attachment.bounds = CGRectMake(0, (-(icon.size.height / 2) - useStatusLabel.font.descender), icon.size.width, icon.size.height);
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSMutableAttributedString *decString= [[NSMutableAttributedString alloc] initWithString:NSBaseLocalizedString(@"use_profile_image", nil)];

    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] init];
    
    [myString appendAttributedString:attachmentString];
    [myString appendAttributedString:decString];
    
    useStatusLabel.attributedText = myString;
}

- (IBAction)useProfile:(id)sender
{
    useProfileImage = !useProfileImage;
    
    [self setStatusLabelIcon:useProfileImage];
    
}

- (IBAction)confirmPopup:(id)sender
{
    if (useProfileImage)
    {
        [self updateUser];
    }
    else
    {
        [self closePopup:self parentViewController:self.parentViewController];
    }
    
}




@end
