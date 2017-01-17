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

#import "ListSubInfoPopupViewController.h"

@interface ListSubInfoPopupViewController ()

@end

@implementation ListSubInfoPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSharedViewController:self];
    // Do any additional setup after loading the view.
    contentListArray = [[NSMutableArray alloc] init];
    contentDic = [[NSMutableDictionary alloc] init];
    selectedInfoArray = [[NSMutableArray alloc] init];
    verificationInfo = [[NSMutableArray alloc] init];
    
    [containerView setHidden:YES];
    hasNextPage = NO;
    isLimited = NO;
    offset = 0;
    limit = 50;
    limitCount = 16;
    
    multiSelect = NO;
    isSelectedAll = NO;
    isSearchable = NO;
    isForSearch = NO;
    isForSingleSearch = NO;
    
    [cancelBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    
    listTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    switch (_type)
    {
        case ASSIGN_CARD:
        case EXCHANGE_CARD:
            isForSingleSearch = YES;
            titleLabel.text = NSLocalizedString(@"registeration_option_assign_card", nil);
            deviceProvider = [[DeviceProvider alloc] init];
            [self getCards:nil limit:limit offset:offset];
            break;
            
        default:
            break;
    }
    
    if (multiSelect)
    {
        [textView setHidden:YES];
        [multiSelectView setHidden:NO];
        [singleSelectView setHidden:YES];
        if (isSearchable)
        {
            [multiSelectSearchView setHidden:NO];
        }
        else
        {
            // 액세스 그룹 팝업만 여기에 해당함
            [singleSelectView setHidden:NO];
            [singleSearchButton setHidden:YES];
            [multiSelectView setHidden:YES];
            [multiSelectSearchView setHidden:YES];
        }
    }
    else
    {
        [multiSelectView setHidden:YES];
        [singleSelectView setHidden:NO];
        [multiSelectSearchView setHidden:YES];
        
        if (isForSingleSearch)
        {
            [singleSearchButton setHidden:NO];
        }
        else
        {
            [singleSearchButton setHidden:YES];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [super popupViewDidAppear:contentView];
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

- (void)setVerificationInfo:(NSArray*)info
{
    [verificationInfo removeAllObjects];
    [verificationInfo addObjectsFromArray:info];
}

- (void)getCards:(NSString*)searchQuery limit:(NSInteger)searchLimit offset:(NSInteger)searchOffset
{
    [self startLoading:self];
    
//    [deviceProvider getCards:searchQuery limit:searchLimit offset:searchOffset completeHandler:^(NSDictionary *responseObject, NSError *error) {
//        
//        [self finishLoading];
//        
//        if (nil == error)
//        {
//            if (isForSearch)
//            {
//                isForSearch = NO;
//                [contentListArray removeAllObjects];
//            }
//            else
//            {
//                if (contentListArray.count == 0)
//                    [self adjustHeight:contentListArray.count];
//            }
//            
//            NSArray *rows = [responseObject objectForKey:@"records"];
//            // 최초로 불러 올때만 팝업 사이즈 조절및 애니메이션 적용
//            if ([rows isKindOfClass:[NSArray class]])
//            {
//                
//                NSMutableArray *newCardCollection = [[NSMutableArray alloc] init];
//                
//                for (NSDictionary *card in rows)
//                {
//                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:card];
//                    [dic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
//                    
//                    [newCardCollection addObject:dic];
//                }
//                
//                [contentListArray addObjectsFromArray:newCardCollection];
//            }
//            
//            totalCount = [[responseObject objectForKey:@"total"] integerValue];
//            
//            [listTableView reloadData];
//            
//            if (totalCount > contentListArray.count)
//            {
//                hasNextPage = YES;
//                offset += limit;
//            }
//            else
//            {
//                hasNextPage = NO;
//            }
//            
//            singleSelectTotalCountLabel.text = [NSString stringWithFormat:@"%ld", (long)totalCount];
//        }
//        else
//        {
//            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
//            ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
//            imagePopupCtrl.type = REQUEST_FAIL;
//            imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
//            [imagePopupCtrl setContent:[responseObject objectForKey:@"message"]];
//            
//            [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
//            
//            [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
//                
//                if (isConfirm)
//                {
//                    [self getCards:searchQuery limit:searchLimit offset:searchOffset];
//                }
//            }];
//        }
//        
//    }];
}



- (void)setContentList:(NSArray*)array
{
    
    for (NSDictionary *info in array)
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:info];
        [dic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        
        [contentListArray addObject:dic];
    }
    
    [listTableView reloadData];
    [self adjustHeight:contentListArray.count];
    
    totalCount = array.count;
    searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)selectedInfoArray.count, (unsigned long)totalCount];
    
}

- (IBAction)showSearchTextFieldView:(id)sender
{
    [textView setHidden:NO];
    [searchTextField resignFirstResponder];
}

- (IBAction)showSingleSearchView:(id)sender
{
    [singleSearchView setHidden:NO];
    [singleSearchTextField becomeFirstResponder];
}

- (IBAction)cancelSearch:(id)sender
{
    [self.view endEditing:YES];
    [textView setHidden:YES];
}

- (IBAction)cancelSingleSearch:(id)sender
{
    [self.view endEditing:YES];
    [singleSearchView setHidden:YES];
}

- (IBAction)selectAll:(id)sender
{
    UIButton *button = (UIButton*)sender;
    isSelectedAll = !isSelectedAll;
    [selectedInfoArray removeAllObjects];
    
    if (isSelectedAll)
    {
        for (NSMutableDictionary *info in contentListArray)
        {
            [info setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
        }
        [selectedInfoArray addObjectsFromArray:contentListArray];
        [button setImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
        multiSelectTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)selectedInfoArray.count,(unsigned long)contentListArray.count];
        searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)selectedInfoArray.count, (unsigned long)totalCount];
    }
    else
    {
        for (NSMutableDictionary *info in contentListArray)
        {
            [info setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        }
        [selectedInfoArray removeAllObjects];
        [button setImage:[UIImage imageNamed:@"check_box_blank"] forState:UIControlStateNormal];
        multiSelectTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)selectedInfoArray.count,(unsigned long)contentListArray.count];
        searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)selectedInfoArray.count, (unsigned long)totalCount];
    }
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < contentListArray.count; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPaths addObject:indexPath];
    }
    
    [listTableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)adjustHeight:(NSInteger)count
{
    if (count < 4)
    {
        containerHeightConstraint.constant = LIST_SUB_POPUP_MINIMUM_HEIGHT;
    }
    singleSelectTotalCountLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
    multiSelectTotalCountLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
    [containerView setHidden:NO];
    [self showPopupAnimation:containerView];
}

- (IBAction)cancelCurrentPopup:(id)sender
{
    [self closePopup:self parentViewController:self.parentViewController];
}

- (IBAction)confirmCurrentPopup:(id)sender
{
    switch (_type)
    {
        case EXCHANGE_CARD:
            if (self.dictionaryResponseBlock && [contentDic count] > 0)
            {
                [contentDic removeObjectForKey:@"selected"];
                self.dictionaryResponseBlock(contentDic);
                self.dictionaryResponseBlock = nil;
            }
            break;
        case ASSIGN_CARD:
            if (multiSelect)
            {
                if (self.arrayResponseBlock && [selectedInfoArray count] > 0) {
                    self.arrayResponseBlock(selectedInfoArray);
                    self.arrayResponseBlock = nil;
                }
            }
            else
            {
                if (self.dictionaryResponseBlock && [contentDic count] > 0)
                {
                    self.dictionaryResponseBlock(contentDic);
                    self.dictionaryResponseBlock = nil;
                }
            }
            break;
            
        default:
            break;
    }
    
    [self closePopup:self parentViewController:self.parentViewController];
}

- (void)getDictionaryResponse:(ListSubInfoPopupDictionaryResponseBlock)dictionaryResponseBlock
{
    self.dictionaryResponseBlock = dictionaryResponseBlock;
}

- (void)getArrayResponse:(ListSubInfoPopupArrayResponseBlock)arrayResponseBlock
{
    self.arrayResponseBlock = arrayResponseBlock;
}

- (void)getIndexResponse:(ListSubInfoPopupIndexResponseBlock)indexResponseBlock
{
    self.indexResponseBlock = indexResponseBlock;
}

- (void)addContent:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    
    
    
    
    NSMutableDictionary *currentDic = [contentListArray objectAtIndex:indexPath.row];
    
    if ([[currentDic objectForKey:@"selected"] boolValue])
    {
        [currentDic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        [selectedInfoArray removeObject:currentDic];
        isLimited = NO;
    }
    else
    {
        if (!isLimited)
        {
            [currentDic setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
            [selectedInfoArray addObject:currentDic];
        }
    }
    
    multiSelectTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)selectedInfoArray.count,(unsigned long)contentListArray.count];
    searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)selectedInfoArray.count, (unsigned long)totalCount];
    singleSelectTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (unsigned long)selectedInfoArray.count, (unsigned long)totalCount];
    
    // select all 판단
    if (selectedInfoArray.count == totalCount)
    {
        // 전체선택
        [multiSearchSelectAllButton setImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
    }
    else
    {
        [multiSearchSelectAllButton setImage:[UIImage imageNamed:@"check_box_blank"] forState:UIControlStateNormal];
    }
    
    [tableView reloadData];
    
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (_type)
    {
        case ASSIGN_CARD:
        case EXCHANGE_CARD:
            return [contentListArray count];
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RadioCell" forIndexPath:indexPath];
    RadioCell *customCell = (RadioCell*)cell;
    
    switch (_type)
    {
        case ASSIGN_CARD:
        case EXCHANGE_CARD:
        {
            NSDictionary *currentDic = [contentListArray objectAtIndex:indexPath.row];
            
            [customCell checkSelected:[[currentDic objectForKey:@"selected"] boolValue] isLimited:isLimited];
            
            customCell.titleLabel.text = [currentDic objectForKey:@"card_id"];
            if (indexPath.row == contentListArray.count -1)
            {
                if (hasNextPage)
                {
                    [self getCards:query limit:limit offset:offset];
                }
            }
        }
            break;
            
        default:
            break;
    }
    
    return customCell;
}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = indexPath.row;
    
    if (multiSelect)
    {
        [self addContent:indexPath tableView:tableView];
    }
    else
    {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *currentDic = [contentListArray objectAtIndex:indexPath.row];
        
        NSInteger index = 0;
        
        for (NSMutableDictionary *content in contentListArray)
        {
            [content setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            
            [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
            index++;
            
        }
        
        [currentDic setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
        
        [contentDic setDictionary:[contentListArray objectAtIndex:indexPath.row]];
        
        [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}



#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    isForSearch = YES;
    query = textField.text;
    offset = 0;
    
    
    if (_type == ASSIGN_CARD || _type == EXCHANGE_CARD)
    {
        [self getCards:query limit:limit offset:offset];
    }
    
    [textField resignFirstResponder];
    return YES;
}

@end
