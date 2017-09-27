//
//  DevicePopupViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 3..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "DevicePopupViewController.h"

@interface DevicePopupViewController ()

@end

@implementation DevicePopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    [self setSharedViewController:self];

    [cancelBtn setTitle:NSBaseLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSBaseLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    totalDecLabel.text = NSBaseLocalizedString(@"total", nil);
    
    devices = [[NSMutableArray alloc] init];
    selectedDevices = [[NSMutableArray alloc] init];
    [containerView setHidden:YES];
    hasNextPage = NO;
    
    offset = 0;
    limit = 50;
    loadedItemCount = 0;
    multiSelect = NO;
    
    listTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    deviceProvider = [[DeviceProvider alloc] init];
    switch (_deviceMode)
    {
        case FINGERPRINT_MODE:
        case CARD_MODE:
        case CSN_CARD_MODE:
        case WIEGAND_CARD_MODE:
        case SMART_CARD_MODE:
        case READING_CARD_MODE:
        case FACE_TEMPLATE:
            titleLabel.text = NSBaseLocalizedString(@"select_device_orginal", nil);
            break;
            
        case ALL_DEVICES_MODE:
            
            multiSelect = YES;
            titleLabel.text = NSBaseLocalizedString(@"select_device_orginal", nil);
            break;
        default:
            break;
    }
    [self getDevice:query limit:limit offset:offset mode:_deviceMode];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [super popupViewDidAppear:contentView];
    
    if ([PreferenceProvider isUpperVersion])
    {
//        if (!multiSelect)
//        {
//            tableViewTopConstraint.constant = - multiSelectSearchView.frame.size.height;
//        }
    }
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



- (void)getDevice:(NSString *)searchQuery limit:(NSInteger)searchLimit offset:(NSInteger)searchOffset mode:(DeviceMode)deviceMode
{
    mode = deviceMode;
    [self startLoading:self];
    
    [deviceProvider getDevices:searchQuery limit:searchLimit offset:searchOffset mode:deviceMode deviceBlock:^(SearchDeviceListResult *result, NSArray *responseArray) {
        [self finishLoading];
        
        searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)responseArray.count];
        
        [self adjustHeight:responseArray.count];
        
        if (offset == 0)
        {
            [devices removeAllObjects];
        }

        
        [devices addObjectsFromArray:responseArray];

        loadedItemCount += result.records.count;
        if (responseArray.count == 0)
        {
            loadedItemCount = 0;
        }
        // 다음 페이지 체크
        if (result.total > loadedItemCount)
        {
            hasNextPage = YES;
            offset += limit;
        }
        else
        {
            hasNextPage = NO;
        }
        
        [listTableView reloadData];
    } onError:^(Response *error) {
        
        [self finishLoading];
        
        // 재시도 할것인지에 대한 팝업 띄워주기
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        
        imagePopupCtrl.type = REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self getDevice:searchQuery limit:searchLimit offset:searchOffset mode:deviceMode];
            }
            else
            {
                [self closePopup:self parentViewController:self.parentViewController];
            }
            
        }];
        
    }];
    
}


- (IBAction)showSearchTextFieldView:(id)sender
{
    [textView setHidden:NO];
    [searchTextField becomeFirstResponder];
}



- (IBAction)cancelSearch:(id)sender
{
    [self.view endEditing:YES];
    [textView setHidden:YES];
    
    if ((nil == query || [query isEqualToString:@""]))
    {
        
        offset = 0;
        limit = 50;
        
        [self getDevice:query limit:limit offset:offset mode:_deviceMode];
    }
}





- (void)adjustHeight:(NSInteger)count
{
    if (count < 4)
    {
        containerHeightConstraint.constant = LIST_SUB_POPUP_MINIMUM_HEIGHT;
    }
    [containerView setHidden:NO];
    [self showPopupAnimation:containerView];
}

- (IBAction)cancelCurrentPopup:(id)sender
{
    if (self.cancelBlock )
    {
        self.cancelBlock();
        self.cancelBlock = nil;
    }
    [self closePopup:self parentViewController:self.parentViewController];
}

- (IBAction)confirmCurrentPopup:(id)sender
{
    if (self.deviceBlock && nil != selectedDevice)
    {
        self.deviceBlock(selectedDevice);
        self.deviceBlock = nil;
    }

    if (self.devicesBlock && selectedDevices.count > 0)
    {
        self.devicesBlock(selectedDevices);
        self.devicesBlock = nil;
    }
    
    
    [self closePopup:self parentViewController:self.parentViewController];
}

- (void)getDevices:(DevicesBlock)devicesBlock
{
    self.devicesBlock = devicesBlock;
}

- (void)getDevice:(DeviceBlock)deviceBlock;
{
    self.deviceBlock = deviceBlock;
}

- (void)getCancelBlock:(CancelBlock)cancelBlock
{
    self.cancelBlock = cancelBlock;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RadioCell" forIndexPath:indexPath];
    RadioCell *customCell = (RadioCell*)cell;
    SearchResultDevice *device = [devices objectAtIndex:indexPath.row];
    
    [customCell checkSelected:device.isSelected];
    customCell.titleLabel.text = device.name;

    if (indexPath.row == devices.count -1)
    {
        if (hasNextPage)
        {
           [self getDevice:query limit:limit offset:offset mode:_deviceMode];
        }
    }
    
    return customCell;
}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (multiSelect)
    {
        SearchResultDevice *device = [devices objectAtIndex:indexPath.row];
        device.isSelected = !device.isSelected;
        
        if (device.isSelected)
        {
            [selectedDevices addObject:device];
        }
        else
        {
            [selectedDevices removeObject:device];
        }
        
        searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)selectedDevices.count, (unsigned long)devices.count];
    }
    else
    {
        for (SearchResultDevice *device in devices)
        {
            device.isSelected = NO;
        }
        SearchResultDevice *device = [devices objectAtIndex:indexPath.row];
        device.isSelected = YES;
        
        selectedDevice = [devices objectAtIndex:indexPath.row];
        
        searchTotalCountLabel.text = [NSString stringWithFormat:@"1 / %ld", (unsigned long)devices.count];
    }
    
    [tableView reloadData];
}



#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""])
    {
        query = textField.text;
        offset = 0;
        
        [self getDevice:query limit:10000 offset:offset mode:mode];
        
        [textField resignFirstResponder];
    }
    return YES;
}


- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    query = @"";
    return YES;
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString *content = [[NSMutableString alloc] initWithString:textField.text];
    
    if (![string isEqualToString:@""])
    {
        // append
        @try {
            [content insertString:string atIndex:range.location];
        } @catch (NSException *exception) {
            NSLog(@"%@ \n %@", exception.description, content);
        }
    }
    else
    {
        //delete
        @try {
            [content deleteCharactersInRange:range];
        } @catch (NSException *exception) {
            NSLog(@"%@ \n %@", exception.description, content);
        }
    }
    
    query = content;
    return YES;
}


@end
