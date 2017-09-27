//
//  DoorPopupViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2017. 2. 10..
//  Copyright © 2017년 suprema. All rights reserved.
//

#import "DoorPopupViewController.h"

@interface DoorPopupViewController ()

@end

@implementation DoorPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    [self setSharedViewController:self];
    
    [cancelBtn setTitle:NSBaseLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSBaseLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    totalDecLabel.text = NSBaseLocalizedString(@"total", nil);
    
    doors = [[NSMutableArray alloc] init];
    selectedDoors = [[NSMutableArray alloc] init];
    [containerView setHidden:YES];
    hasNextPage = NO;
    isForSearch = NO;
    offset = 0;
    limit = 50;
    loadedItemCount = 0;
    multiSelect = YES;
    
    listTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    doorProvider = [[DoorProvider alloc] init];
    titleLabel.text = NSBaseLocalizedString(@"door", nil);
    
    [self getDoors:query limit:limit offset:offset];
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



- (void)getDoors:(NSString *)searchQuery limit:(NSInteger)searchLimit offset:(NSInteger)searchOffset;
{
    
    [self startLoading:self];
    
    [doorProvider searchDoors:searchQuery limit:searchLimit offset:searchOffset completeBlock:^(GetDoorList *result) {
        
        [self finishLoading];
        
        searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)result.records.count];
        
        [self adjustHeight:result.records.count];
        
        if (isForSearch)
        {
            [doors removeAllObjects];
            isForSearch = NO;
        }
        [doors addObjectsFromArray:result.records];
        
        loadedItemCount += result.records.count;
        if (result.records.count == 0)
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
                [self getDoors:searchQuery limit:searchLimit offset:searchOffset];
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
    
    if ((nil == query || [query isEqualToString:@""]) && didSearch)
    {
        didSearch = NO;
        offset = 0;
        limit = 50;
        query = nil;
        [self getDoors:query limit:limit offset:offset];
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
    [self closePopup:self parentViewController:self.parentViewController];
}

- (IBAction)confirmCurrentPopup:(id)sender
{
    
    
    if (self.doorsBlock && selectedDoors.count > 0)
    {
        self.doorsBlock(selectedDoors);
        self.doorsBlock = nil;
    }
    
    
    [self closePopup:self parentViewController:self.parentViewController];
}

- (void)getDoors:(DoorsBlock)doorsBlock;
{
    self.doorsBlock = doorsBlock;
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return doors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RadioCell" forIndexPath:indexPath];
    RadioCell *customCell = (RadioCell*)cell;
    ListDoorItem *door = [doors objectAtIndex:indexPath.row];
    
    [customCell checkSelected:door.isSelected];
    customCell.titleLabel.text = door.name;
    
    if (indexPath.row == doors.count -1)
    {
        if (hasNextPage)
        {
            [self getDoors:query limit:limit offset:offset];
        }
    }
    
    return customCell;
}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListDoorItem *door = [doors objectAtIndex:indexPath.row];
    door.isSelected = !door.isSelected;
    
    if (door.isSelected)
    {
        [selectedDoors addObject:door];
    }
    else
    {
        [selectedDoors removeObject:door];
    }
    
    searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)selectedDoors.count, (unsigned long)doors.count];
    
    [tableView reloadData];
}



#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""])
    {
        query = textField.text;
        offset = 0;
        isForSearch = YES;
        [self getDoors:query limit:limit offset:offset];
        didSearch = YES;
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
