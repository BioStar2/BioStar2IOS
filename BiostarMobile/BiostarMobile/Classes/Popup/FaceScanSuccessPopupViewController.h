//
//  FaceScanSuccessPopupViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2017. 3. 13..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import "BaseViewController.h"
#import "UserProvider.h"
#import "ImagePopupViewController.h"

@interface FaceScanSuccessPopupViewController : BaseViewController
{
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIImageView *scanImage;
    __weak IBOutlet UILabel *descriptionLabel;
    __weak IBOutlet UIButton *confirmButton;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UILabel *useStatusLabel;
    
    BOOL useProfileImage;
    UserProvider *userProvider;
}


@property (assign, nonatomic) NSInteger templateIndex;
@property (strong, nonatomic) NSString *currentUserID;
@property (assign, nonatomic) NSUInteger index;
@property (strong, nonatomic) NSString *photo;


- (IBAction)useProfile:(id)sender;
- (IBAction)confirmPopup:(id)sender;
- (void)setStatusLabelIcon:(BOOL)useImage;
- (void)updateUser;
@end
