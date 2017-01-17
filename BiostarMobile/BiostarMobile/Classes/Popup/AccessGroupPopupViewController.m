//
//  AccessGroupPopupViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 2..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "AccessGroupPopupViewController.h"

@interface AccessGroupPopupViewController ()

- (void)getAccessGroups;
- (void)adjustHeight:(NSInteger)count;

@end

@implementation AccessGroupPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setSharedViewController:self];
    
    [cancelBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    totalDecLabel.text = NSLocalizedString(@"total", nil);
    isMenuSelected = NO;
    limitCount = 16;
    isLimited = NO;
    [containerView setHidden:YES];
    
    accessGroups = [[NSMutableArray alloc] init];
    selectedAccessGroups = [[NSMutableArray alloc] init];
    accessProvider = [[AccessGroupProvider alloc] init];
    
    titleLabel.text = NSLocalizedString(@"select_access_group", nil);
    switch (self.type)
    {
        case EXCHANGE_ACCESS_GROUP:
            canMultiSelect = NO;
            break;
            
        case ADD_ACCESS_GROUP:
            canMultiSelect = YES;
            break;
    }
   
    [self getAccessGroups];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getAccessGroups
{
    [self startLoading:self];
    
    [accessProvider getAccessGroups:^(AccessGroupSearchResult *searchResult) {
        
        [self finishLoading];
        
        [accessGroups removeAllObjects];
        
        NSArray <AccessGroupItem*>*groups = searchResult.records;
        
        for (AccessGroupItem *accessGroupItem in groups)
        {
            BOOL isFound = NO;
            for (AccessGroupItem *savedGroup in userAccessGroups)
            {
                if ([accessGroupItem.id isEqualToString:savedGroup.id])
                {
                    isFound = YES;
                    break;
                }
            }
            if (!isFound)
            {
                [accessGroups addObject:accessGroupItem];
            }
        }
        
        totalCount = searchResult.total;
        
        [listTableView reloadData];
        
        [self adjustHeight:searchResult.records.count];
        
        if (canMultiSelect)
        {
            totalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)selectedAccessGroups.count, (long)totalCount];
        }
        else
        {
            totalCountLabel.text = [NSString stringWithFormat:@"%ld", (long)totalCount];
        }
        
        
    } onError:^(Response *error) {
        
        [self finishLoading];
        
        // 재시도 할것인지에 대한 팝업 띄워주기
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            
            if (isConfirm)
            {
                [self getAccessGroups];
            }
            else
            {
                [self closePopup:self parentViewController:self.parentViewController];
            }
        }];
    }];
    
    
}

- (void)setUserAccessGroups:(NSArray <UserItemAccessGroup*>*)savedAccessGroups
{
    userAccessGroups = [[NSMutableArray alloc] initWithArray:savedAccessGroups];
}

- (IBAction)cancelCurrentPopup:(id)sender
{
    [self closePopup:self parentViewController:self.parentViewController];
}

- (IBAction)confirmCurrentPopup:(id)sender
{
    if (self.accessGroupsPopupBlock) {
        if (selectedAccessGroups.count > 0) {
            for (AccessGroupItem *item in selectedAccessGroups) {
                item.isSelected = NO;
            }
            self.accessGroupsPopupBlock(selectedAccessGroups);
            self.accessGroupsPopupBlock = nil;
        }
    }
    
    if (self.accessGroupPopupBlock) {
        if (isMenuSelected) {
            
            self.accessGroupPopupBlock(accessGroup);
            self.accessGroupPopupBlock = nil;
        }
    }
    
    [self closePopup:self parentViewController:self.parentViewController];
}

- (void)getAccessGroupsBlock:(AccessGroupsPopupBlock)accessGroupsPopupBlock
{
    self.accessGroupsPopupBlock = accessGroupsPopupBlock;
}

- (void)getAccessGroupBlock:(AccessGroupPopupBlock)accessGroupPopupBlock
{
    self.accessGroupPopupBlock = accessGroupPopupBlock;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)adjustHeight:(NSInteger)count
{
    if (count < 4)
    {
        containerHeightConstraint.constant = LIST_SUB_POPUP_MINIMUM_HEIGHT;
    }
    [containerView setHidden:NO];
    [self showPopupAnimation:containerView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return accessGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RadioCell" forIndexPath:indexPath];
    RadioCell *customCell = (RadioCell*)cell;
    
    AccessGroupItem *currentAccessGroup = [accessGroups objectAtIndex:indexPath.row];
    if (canMultiSelect)
    {
        [customCell checkSelected:currentAccessGroup.isSelected isLimited:isLimited];
    }
    else
    {
        [customCell checkSelected:currentAccessGroup.isSelected];
    }
    
    customCell.titleLabel.text = currentAccessGroup.name;
    
    return customCell;
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (canMultiSelect)
    {
        AccessGroupItem *item = [accessGroups objectAtIndex:indexPath.row];
        
        if (!item.isSelected)
        {
            if (!isLimited)
            {
                [selectedAccessGroups addObject:item];
                item.isSelected = YES;
            }
            
            if (selectedAccessGroups.count + userAccessGroups.count >= limitCount )
            {
                isLimited = YES;
            }
            else
            {
                isLimited = NO;
            }
        }
        else
        {
            item.isSelected = NO;
            isLimited = NO;
            [selectedAccessGroups removeObject:item];
            
        }
        
        totalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)selectedAccessGroups.count, (long)totalCount];
    }
    else
    {
        for (AccessGroupItem *item in accessGroups)
        {
            item.isSelected = NO;
        }
        AccessGroupItem *item = [accessGroups objectAtIndex:indexPath.row];
        item.isSelected = YES;
        
        accessGroup = item;
        isMenuSelected = YES;
    }
    
    [tableView reloadData];
}
@end
