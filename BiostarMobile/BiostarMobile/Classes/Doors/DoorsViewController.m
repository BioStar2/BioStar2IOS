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

#import "DoorsViewController.h"


@interface DoorsViewController ()

@end

@implementation DoorsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setSharedViewController:self];
    canScrollTop = NO;
    titleLabel.text = NSBaseLocalizedString(@"all_door", nil);
    totalDecLabel.text = NSBaseLocalizedString(@"total", nil);
    scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
    
    refreshControl = [[UIRefreshControl alloc] init];
    //refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"refresh Doors"];
    [doorsTableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshDoors) forControlEvents:UIControlEventValueChanged];
    secondYPosition = 0.0f;
    limit = 100;
    offset = 0;
    doors = [[NSMutableArray alloc] init];
    provider = [[DoorProvider alloc] init];
    query = nil;
    isMainRequest = YES;
    [self searchDoors:query limit:limit offset:offset];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showTextFieldView:(id)sender
{
    [textFieldView setHidden:NO];
    [countView setHidden:YES];
}

- (IBAction)cancelSearch:(id)sender
{
    [self.view endEditing:YES];
    [textFieldView setHidden:YES];
    [countView setHidden:NO];
    
    if ((nil == query || [query isEqualToString:@""]) && didSearch)
    {
        didSearch = NO;
        offset = 0;
        limit = 50;
        query = nil;

        [self searchDoors:query limit:limit offset:offset];
    }
}

- (IBAction)moveToBack:(id)sender
{
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:NEED_TO_GET_MOBILE_CREDENTIAL object:nil];
    [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
}

- (IBAction)scrollTopOrBottom:(id)sender
{
    if (nil == doors || doors.count == 0)
    {
        return;
    }
    
    if (canScrollTop)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [doorsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
        canScrollTop = NO;
    }
    else
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:doors.count - 1 inSection:0];
        [doorsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
        
        if (doors.count == totalCount)
        {
            canScrollTop = YES;
            scrollButton.transform = CGAffineTransformMakeRotation(0);
        }
    }
}

- (void)refreshDoors
{
    [doors removeAllObjects];
    offset = 0;
    isMainRequest = YES;
    [self searchDoors:query limit:limit offset:offset];
}

- (void)searchDoors:(NSString *)searchQuery limit:(NSInteger)searchLimit offset:(NSInteger)searchOffset
{
    [self startLoading:self];
    
    [provider searchDoors:searchQuery limit:searchLimit offset:searchOffset completeBlock:^(GetDoorList *result) {
        
        [refreshControl endRefreshing];
        [self finishLoading];
        
        isMainRequest = NO;
        
        NSInteger total = result.total;
        if (nil == query)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:DOOR_COUNT_UPDATE object:@{@"count" : [NSNumber numberWithInteger:total]}];
        }
        
        [self cancelSearch:nil];
        [self.view endEditing:YES];
        totalCountLabel.text = [NSString stringWithFormat:@"%ld", (long)total];
        totalCount = total;
        
        if (total != 0)
        {
            [doors addObjectsFromArray:result.records];
            
            if (doors.count < total)
            {
                hasNextPage = YES;
                offset += limit;
            }
            else
            {
                hasNextPage = NO;
            }
            
            [doorsTableView reloadData];
        }
        else
        {
            hasNextPage = NO;
            [doors removeAllObjects];
            [doorsTableView reloadData];
            
        }
        
        
    } onError:^(Response *error) {
        
        [refreshControl endRefreshing];
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
                [self searchDoors:query limit:limit offset:offset];
            }
            else
            {
                if (isMainRequest)
                {
                    [self moveToBack:nil];
                }
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [doors count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DoorCell" forIndexPath:indexPath];
    DoorCell *customCell = (DoorCell*)cell;
    if (doors.count > 0)
    {
        ListDoorItem *door = [doors objectAtIndex:indexPath.row];
        customCell.doorID.text = door.name;
        customCell.doorName.text = door.door_description;
        [customCell setDoorStatus:door];
        if (indexPath.row == doors.count -1)
        {
            if (hasNextPage)
            {
                [self searchDoors:query limit:limit offset:offset];
            }
        }
    }
    
    
    return customCell;
    
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DoorDetailViewController *doorDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"DoorDetailViewController"];
    doorDetailViewController.delegate = self;
    [self pushChildViewController:doorDetailViewController parentViewController:self contentView:self.view animated:YES];
    
    [doorDetailViewController setDoorInfo:[doors objectAtIndex:indexPath.row]];
    
}

#pragma mark - DoorDetailViewControllerDelegate

- (void)refreshDoorList
{
    isMainRequest = YES;
    [doors removeAllObjects];
    [self searchDoors:query limit:limit offset:offset];
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""])
    {
        [doors removeAllObjects];
        query = textField.text;
        
        NSString *tempQuery = [textField.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        
        if ([tempQuery isEqualToString:@""])
        {
            query = nil;
        }
        offset = 0;
        isMainRequest = NO;
        [self searchDoors:query limit:limit offset:offset];
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

#pragma mark - ScrollView Delegate


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndDecelerating");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    secondYPosition = scrollView.contentOffset.y;
    NSLog(@"scrollViewDidEndDragging");
    if (firstYPosition < secondYPosition)
    {
        // 스크롤 위로 움직이게
        if (decelerate)
            canScrollTop = NO;
    }
    else
    {
        // 스크롤 아래로
        if (decelerate)
            canScrollTop = YES;
    }
    if (canScrollTop)
    {
        scrollButton.transform = CGAffineTransformMakeRotation(0);
    }
    else
    {
        scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
    }
    
    if (scrollView.contentOffset.y > scrollView.contentSize.height - doorsTableView.frame.size.height) {
        NSLog(@"bouncing down");
        canScrollTop = YES;
        scrollButton.transform = CGAffineTransformMakeRotation(0);
    }
    
    if (scrollView.contentOffset.y < 0) {
        NSLog(@"bouncing up");
        canScrollTop = NO;
        scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidScroll");
    secondYPosition = scrollView.contentOffset.y;
    
    if (scrollView.contentOffset.y < 0) {
        NSLog(@"bouncing up");
        canScrollTop = NO;
        scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
    }
    
    
    if (scrollView.contentOffset.y > scrollView.contentSize.height - doorsTableView.frame.size.height) {
        NSLog(@"bouncing down");
        canScrollTop = YES;
        scrollButton.transform = CGAffineTransformMakeRotation(0);
    }
    
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    firstYPosition = scrollView.contentOffset.y;
    
}

@end
