//
//  DevicePopupViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 3..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "BaseViewController.h"
#import "RadioCell.h"
#import "DeviceProvider.h"
#import "ImagePopupViewController.h"

@interface DevicePopupViewController : BaseViewController
{
    __weak IBOutlet NSLayoutConstraint *containerHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *tableViewTopConstraint;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *searchTotalCountLabel;
    __weak IBOutlet UITableView *listTableView;
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UIView *multiSelectSearchView;
    __weak IBOutlet UIView *textView;
    __weak IBOutlet UITextField *searchTextField;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UIButton *confirmBtn;
    
    DeviceProvider *deviceProvider;
    NSMutableArray <SearchResultDevice*> *devices;
    NSMutableArray <SearchResultDevice*> *selectedDevices;
    SearchResultDevice *selectedDevice;
    NSString *query;
    NSInteger offset;
    NSInteger limit;
    
    BOOL multiSelect;
    BOOL hasNextPage;
    BOOL isForSearch;
    DeviceMode mode;
    NSInteger loadedItemCount;
}

typedef void (^DevicesBlock)(NSArray <SearchResultDevice*> *devices);
typedef void (^DeviceBlock)(SearchResultDevice *device);


@property (assign, nonatomic) DeviceMode deviceMode;
@property (nonatomic, strong) DevicesBlock devicesBlock;
@property (nonatomic, strong) DeviceBlock deviceBlock;


- (void)getDevices:(DevicesBlock)devicesBlock;

- (void)getDevice:(DeviceBlock)deviceBlock;

- (void)getDevice:(NSString *)searchQuery limit:(NSInteger)searchLimit offset:(NSInteger)searchOffset mode:(DeviceMode)deviceMode;

- (IBAction)showSearchTextFieldView:(id)sender;


- (IBAction)cancelSearch:(id)sender;

- (void)adjustHeight:(NSInteger)count;

- (IBAction)cancelCurrentPopup:(id)sender;

- (IBAction)confirmCurrentPopup:(id)sender;


@end
