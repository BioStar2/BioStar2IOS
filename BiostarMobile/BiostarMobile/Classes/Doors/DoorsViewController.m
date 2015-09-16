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
#import "DoorDetailViewController.h"

@interface DoorsViewController ()

@end

@implementation DoorsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    canScrollTop = NO;
    
    scrollButton.transform = CGAffineTransformMakeRotation(M_PI);
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"refresh Doors"];
    [doorsTableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshDoors) forControlEvents:UIControlEventValueChanged];
    secondYPosition = 0.0f;
    limit = 100;
    offset = 0;
    doors = [[NSMutableArray alloc] init];
    provider = [[DoorProvider alloc] init];
    provider.delegate = self;
    [provider searchDoors:query limit:limit offset:offset];
    isMainRequest = YES;
    [self startLoading:self];
    query = nil;
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
}

- (IBAction)moveToBack:(id)sender
{
    [self.view endEditing:YES];
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
    isMainRequest = YES;
    [doors removeAllObjects];
    offset = 0;
    [provider searchDoors:query limit:limit offset:offset];
    [self startLoading:self];
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
    NSDictionary *dic = [doors objectAtIndex:indexPath.row];
    customCell.doorID.text = [dic objectForKey:@"name"];
    customCell.doorName.text = [dic objectForKey:@"description"];
    
    if (indexPath.row == doors.count -1)
    {
        if (hasNextPage)
        {
            [provider searchDoors:query limit:limit offset:offset];
            [self startLoading:self];
        }
    }
    
    return customCell;
    
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DoorDetailViewController *doorDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"DoorDetailViewController"];
    
    [self pushChildViewController:doorDetailViewController parentViewController:self contentView:self.view animated:YES];
    
    [doorDetailViewController setDoorInfo:[doors objectAtIndex:indexPath.row]];
    
}

#pragma mark - ListPopupViewControllerDelegate

- (void)didSelectCardOption:(NSInteger)optionIndex
{

    
}

#pragma mark - DoorProviderDelegate
- (void)requestGetDoorsDidFinish:(NSArray*)doorArray totalCount:(NSInteger)total
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DOOR_COUNT_UPDATE object:@{@"count" : [NSNumber numberWithInteger:total]}];
    [refreshControl endRefreshing];
    
    [self cancelSearch:nil];
    [self finishLoading];
    [self.view endEditing:YES];
    totalCountLabel.text = [NSString stringWithFormat:@"%ld", (long)total];
    totalCount = total;
    
    if (total != 0)
    {
        [doors addObjectsFromArray:doorArray];
        
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
    
    
}

- (void)requestDoorProviderDidFail:(NSDictionary*)errDic
{
    [refreshControl endRefreshing];
    [self finishLoading];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.delegate = self;
    imagePopupCtrl.type = MAIN_REQUEST_FAIL;
    imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
    [imagePopupCtrl setContent:[errDic objectForKey:@"message"]];
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [doors removeAllObjects];
    query = textField.text;
    [provider searchDoors:query limit:limit offset:offset];
    [self startLoading:self];
    isMainRequest = NO;
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - ImagePopupDelegate
- (void)confirmImagePopup
{
    if (isMainRequest)
    {
        [provider getDoors];
        isMainRequest = YES;
        [self startLoading:self];
    }
    else
    {
        [provider searchDoors:query limit:limit offset:offset];
        [self startLoading:self];
        isMainRequest = NO;
    }
}

- (void)cancelImagePopup
{
    if (isMainRequest)
    {
        [self moveToBack:nil];
    }
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
        canScrollTop = NO;
    }
    else
    {
        // 스크롤 아래로
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
