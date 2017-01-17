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
#import "LocalDataManager.h"

#define AnimationDuration       0.3



@interface BaseViewController : UIViewController <SessionPopupDelete>
{
    LoadingViewController *loadingViewController;
    
    UIRefreshControl *refreshControl;
    BOOL isLoading;
    UIViewController *currentController;
}

@property (nonatomic, strong) SessionExpiredPopupController *sessionPopupController;

- (void)setSharedViewController:(BaseViewController*)controller;

/**
 *  Show loading view
 *
 *  @param parentViewController        the view controller which call the method
 */
- (void)startLoading:(UIViewController*)parentViewController;


/**
 *  Hide loading view
 *
 */
- (void)finishLoading;


/**
 *  Push view controller
 *
 *  @param childViewController          the view controller which will be pushed
 *  @param parentViewController         the view controller which call the method
 *  @param contentView                  parentViewController's view
 *  @param animated                     YES if it want to be animated like navigation controller
 */
- (void)pushChildViewController:(UIViewController*)childViewController parentViewController:(UIViewController*)parentViewController contentView:(UIView*)contentView animated:(BOOL)animated;


/**
 *  Pop view controller
 *
 *  @param childViewController          the view controller which call the moehod
 *  @param parentViewController         childViewController's parent controller
 *  @param animated                     YES if it want to be animated like navigation controller
 */
- (void)popChildViewController:(UIViewController*)childViewController parentViewController:(UIViewController*)parentViewController animated:(BOOL)animated;


/**
 *  Pop to root view controller
 *
 */
- (void)popToRootViewController;


/**
 *  Show popup view controller
 *
 *  @param childViewController          the view controller which will be shown as a popup
 *  @param parentViewController         the view controller which call the method
 *  @param contentView                  parentViewController's view
 */
- (void)showPopup:(UIViewController*)popupViewController parentViewController:(UIViewController*)parentViewController parentView:(UIView*)parentView;


/**
 *  Close popup
 *
 *  @param popupViewController          the view controller which is shown as a popup
 *  @param parentViewController         the view controller which call the method
 */
- (void)closePopup:(UIViewController*)popupViewController parentViewController:(UIViewController*)parentViewController;


/**
 *  Hide Popup Alpha back ground view
 *
 *  @param contentView          Black alpha back ground view
 *  
 *  @note This method have to be called at viewDidAppear on PopupViewController
 */
- (void)popupViewDidAppear:(UIView*)contentView;

- (void)popToMainViewController;


/**
 *  View animation when popup is shown.
 *
 *  @param view          Popup view
 *
 *  @note This method have to be called at viewDidAppear on PopupViewController
 */
- (void)showPopupAnimation:(UIView*)view;

/**
 *  When sessin is expired to show session expired popup the messod is called
 */

+ (void)sessionExpired;
@end
