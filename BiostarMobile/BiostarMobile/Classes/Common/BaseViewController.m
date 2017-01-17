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

#import "BaseViewController.h"

NSInteger popupCount = 0;

static BaseViewController *sharedInstance = nil;

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    loadingViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoadingViewController"];
    isLoading = NO;
    
    self.sessionPopupController = [storyboard instantiateViewControllerWithIdentifier:@"SessionExpiredPopupController"];
    self.sessionPopupController.delegate = self;
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

- (void)setSharedViewController:(BaseViewController*)controller
{
    sharedInstance = controller;
}

- (void)startLoading:(UIViewController*)parentViewController
{
    if (isLoading)
    {
        return;
    }
    
    [parentViewController addChildViewController:loadingViewController];
    [parentViewController.view addSubview:loadingViewController.view];
    [loadingViewController didMoveToParentViewController:parentViewController];
    [loadingViewController startLoading];
    isLoading = YES;
}

- (void)finishLoading
{
    if (!isLoading)
    {
        return;
    }
    
    [loadingViewController willMoveToParentViewController:loadingViewController.parentViewController];
    [loadingViewController.view removeFromSuperview];
    [loadingViewController removeFromParentViewController];
    [loadingViewController stopLoading];
    isLoading = NO;
}

- (void)pushChildViewController:(UIViewController*)childViewController parentViewController:(UIViewController*)parentViewController contentView:(UIView*)contentView animated:(BOOL)animated
{
    currentController = childViewController;
    parentViewController.parentViewController.view.userInteractionEnabled = NO;
    parentViewController.view.userInteractionEnabled = NO;

    [parentViewController addChildViewController:childViewController];
    
    childViewController.view.frame = CGRectMake(childViewController.view.frame.size.width, 0, childViewController.view.frame.size.width, childViewController.view.frame.size.height);
    
    [contentView addSubview:childViewController.view];
    
    if (animated)
    {
        [UIView animateWithDuration:AnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            childViewController.view.frame = parentViewController.view.frame;
            
        } completion:^(BOOL finished) {
            [childViewController didMoveToParentViewController:parentViewController];
            parentViewController.view.userInteractionEnabled = YES;
            parentViewController.parentViewController.view.userInteractionEnabled = YES;
            
        }];
    }
    else
    {
        childViewController.view.frame = parentViewController.view.frame;
        [childViewController didMoveToParentViewController:parentViewController];
        parentViewController.view.userInteractionEnabled = YES;
        parentViewController.parentViewController.view.userInteractionEnabled = YES;
        for (UIViewController *viewController in parentViewController.childViewControllers)
        {
            viewController.view.userInteractionEnabled = YES;
        }
    }
    
}

- (void)popChildViewController:(UIViewController*)childViewController parentViewController:(UIViewController*)parentViewController animated:(BOOL)animated
{
    currentController = childViewController;
    parentViewController.view.userInteractionEnabled = NO;
    
    [childViewController willMoveToParentViewController:parentViewController];
    
    if (animated)
    {
        [UIView animateWithDuration:AnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            childViewController.view.frame = CGRectMake(childViewController.view.frame.size.width, 0, childViewController.view.frame.size.width, childViewController.view.frame.size.height);
            
        } completion:^(BOOL finished) {
            [childViewController.view removeFromSuperview];
            [childViewController removeFromParentViewController];
            
            parentViewController.view.userInteractionEnabled = YES;
        }];
    }
    else
    {
        childViewController.view.frame = CGRectMake(childViewController.view.frame.size.width, 0, childViewController.view.frame.size.width, childViewController.view.frame.size.height);
        [childViewController.view removeFromSuperview];
        [childViewController removeFromParentViewController];
        
        parentViewController.view.userInteractionEnabled = YES;
    }
    
    
}

- (void)popToRootViewController
{
    popupCount = 0;
    NSLog(@"popToRootViewController %lu", (unsigned long)self.childViewControllers.count);
    
    for (UIViewController *viewController in self.childViewControllers)
    {
        [viewController willMoveToParentViewController:nil];
        
        //2. Remove the DetailViewController's view from the Container
        [viewController.view removeFromSuperview];
        
        //3. Update the hierarchy"
        //   Automatically the method didMoveToParentViewController: will be called on the detailViewController)
        [viewController removeFromParentViewController];
        
        NSLog(@"removeCurrentViewController");
    }
    
}

- (void)showPopup:(UIViewController*)popupViewController parentViewController:(UIViewController*)parentViewController parentView:(UIView*)parentView
{
    popupCount++;
    
    [parentViewController addChildViewController:popupViewController];
    
    [parentView addSubview:popupViewController.view];
    
    [popupViewController didMoveToParentViewController:parentViewController];
    
}


- (void)closePopup:(UIViewController*)popupViewController parentViewController:(UIViewController*)parentViewController
{
    popupCount--;
    
    if ([popupViewController.childViewControllers count] > 0)
    {
        for (UIViewController* childViewController in popupViewController.childViewControllers)
        {
            [childViewController willMoveToParentViewController:parentViewController];
            
            [childViewController.view removeFromSuperview];
            [childViewController removeFromParentViewController];
        }
    }
    [popupViewController willMoveToParentViewController:parentViewController];
    
    [popupViewController.view removeFromSuperview];
    [popupViewController removeFromParentViewController];
}

- (void)popupViewDidAppear:(UIView*)contentView
{
    if (popupCount > 1)
    {
        [contentView setHidden:YES];
    }
}

- (void)popToMainViewController
{
    [self popChildViewController:currentController parentViewController:currentController.parentViewController animated:YES];
}

- (void)showPopupAnimation:(UIView*)view
{
    view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        view.transform = CGAffineTransformMakeScale(1.2, 1.2);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            view.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
            
        }];
        
    }];
}

+ (void)sessionExpired
{
    [sharedInstance finishLoading];
    
    [LocalDataManager deleteLocalCookies];
    
    [sharedInstance.sessionPopupController setMessage:NSLocalizedString(@"login_expire", nil)];
    [sharedInstance showPopup:sharedInstance.sessionPopupController parentViewController:sharedInstance.sessionPopupController.parentViewController parentView:sharedInstance.view];
}

- (void)didComplete
{
    [self popToMainViewController];
}


#pragma mark - SessionPopupDelete

- (void)needToMoveStartController
{
    popupCount = 0;
    [self closePopup:self.sessionPopupController parentViewController:self.sessionPopupController.parentViewController];
    [self popToRootViewController];
    [self.navigationController popToRootViewControllerAnimated:YES];
    //self.sessionPopupController = nil;
}
@end
