//
//  MobileCardViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 9. 29..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "MobileCardViewController.h"

@interface MobileCardViewController ()


@end

@implementation MobileCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    titleLabel.text = NSLocalizedString(@"mobile_card", nil);
    totalDiscriptionLabel.text = NSLocalizedString(@"total", nil);
    
    userProvider = [[UserProvider alloc] init];
    NSLog(@"%f", [totalDiscriptionLabel getWidthForText]);
    
    if (IS_IPHONE_6_PLUS)
    {
        cellHeight = 250;
    }
    else if (IS_IPHONE_6)
    {
        cellHeight = 220;
    }
    else if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        cellHeight = 195;
    }
    mobileCredintials = [[NSMutableArray alloc] init];
    [self getMobileCredential];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MobileCardHelpViewController *helpController = [storyboard instantiateViewControllerWithIdentifier:@"MobileCardHelpViewController"];
    
    [self showPopup:helpController parentViewController:self parentView:self.view];
    //helpController.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    discriptionConstraint.constant = [totalDiscriptionLabel getWidthForText] + 5;
}

- (void)setCurrentUser:(User*)user
{
    currentUser = user;
}

- (void)getMobileCredential
{
    
    [self startLoading:self];
    
    [userProvider getUserMobileCredentials:currentUser.user_id resultBlock:^(MobileCredentialList *result) {
        
        [self finishLoading];
        
        [mobileCredintials removeAllObjects];
        
        totalCountLabel.text = [NSString stringWithFormat:@"%ld", result.mobile_credential_list.count];
        
        [mobileCredintials addObjectsFromArray:result.mobile_credential_list];
        
        [cardTableView reloadData];
        
    } onErrorBlock:^(Response *error) {
        
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = MAIN_REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self getMobileCredential];
            }
        }];
    }];
}


- (void)reqisterMobileCredential:(NSString*)cardRecodID
{
    [self startLoading:self];
    
    [userProvider registerMobileCredential:cardRecodID UUID:[CommonUtil getUUID] responseBlock:^(MobileCredentialRegisterResponse *response) {
        
        [self finishLoading];
        
        [self getMobileCredential];
        
    } onErrorBlock:^(Response *error) {
        
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = MAIN_REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self getMobileCredential];
            }
        }];
        
    }];
}

- (void)requestReissueMobileCredential:(NSString*)cardRecodID
{
    [self startLoading:self];
    
    [userProvider requestMobileCredentialReissue:cardRecodID responseBlock:^(Response *response) {
        
        [self finishLoading];
        
        [self getMobileCredential];
        
    } onErrorBlock:^(Response *error) {
        
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = MAIN_REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self getMobileCredential];
            }
        }];
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)moveToBack:(id)sender
{
    [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return mobileCredintials.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.delegate = self;
    Card *card = [mobileCredintials objectAtIndex:indexPath.row];
    [cell setMobileCardContent:card user:currentUser];
    
    return cell;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return cellHeight;
}

#pragma mark - MobileCellDelegate

- (void)reauestRetisterOrReissue:(UITableViewCell*)cell
{
    NSIndexPath *indexPath = [cardTableView indexPathForCell:cell];
    
    Card *card = [mobileCredintials objectAtIndex:indexPath.row];
    
    if (card.is_registered)
    {
        [self requestReissueMobileCredential:card.id];
    }
    else
    {
        [self reqisterMobileCredential:card.id];
    }
}

@end
