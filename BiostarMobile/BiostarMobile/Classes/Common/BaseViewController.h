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

#import <UIKit/UIKit.h>
#import "Common.h"
#import "CommonUtil.h"
#import "LoadingViewController.h"
#import "SessionExpiredPopupController.h"
#import "UIView+Toast.h"

#define AnimationDuration       0.3

@interface BaseViewController : UIViewController <SessionPopupDelete>
{
    LoadingViewController *loadingViewController;
    SessionExpiredPopupController *sessionPopupController;
    UIRefreshControl *refreshControl;
    BOOL isLoading;
    UIViewController *currentController;
}

- (void)startLoading:(UIViewController*)parentViewController;
- (void)finishLoading;

- (void)pushChildViewController:(UIViewController*)childViewController parentViewController:(UIViewController*)parentViewController contentView:(UIView*)contentView animated:(BOOL)animated;
- (void)popChildViewController:(UIViewController*)childViewController parentViewController:(UIViewController*)parentViewController animated:(BOOL)animated;
- (void)popToRootViewController;


- (void)showPopup:(UIViewController*)popupViewController parentViewController:(UIViewController*)parentViewController parentView:(UIView*)parentView;
- (void)closePopup:(UIViewController*)popupViewController parentViewController:(UIViewController*)parentViewController;
- (void)popupViewDidAppear:(UIView*)contentView;

- (void)popToMainViewController;

- (void)showPopupAnimation:(UIView*)view;
@end
