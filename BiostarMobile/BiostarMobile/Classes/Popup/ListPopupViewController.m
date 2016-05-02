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

#import "ListPopupViewController.h"


@interface ListPopupViewController ()

@end

@implementation ListPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [containerView setHidden:YES];
    
    contentListArray = [[NSMutableArray alloc] init];
    [contentListArray removeAllObjects];
    contentDic = [[NSMutableDictionary alloc] init];
    selectedIndex = NOT_SELECTED;
    offset = 0;
    limit = 100;
    
    switch (_type)
    {
        case PERMISSON:
            titleLabel.text = NSLocalizedString(@"select_operator", nil);
            permissionProvider = [[PermissionProvider alloc] init];
            permissionProvider.delegate = self;
            [permissionProvider getPermissions];
            [self startLoading:self];
            break;
        case ASSIGN_CARD:
            titleLabel.text = NSLocalizedString(@"registeration_option_assign_card", nil);
            deviceProvider = [[DeviceProvider alloc] init];
            deviceProvider.delegate = self;
            [deviceProvider getCardsWithGroupID:@"0" limit:limit offset:offset];
            break;
        case CARD_OPTION:
            titleLabel.text = NSLocalizedString(@"registeration_option", nil);
            break;
        case PEROID:
            titleLabel.text = NSLocalizedString(@"select_option", nil);
            break;
        default:
            break;    
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [super popupViewDidAppear:contentView];
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
        heightConstraint.constant = LIST_POPUP_MINIMUM_HEIGHT;
    }
    
    [containerView setHidden:NO];
    [self showPopupAnimation:containerView];
}

- (IBAction)cancelCurrentPopup:(id)sender
{
    [self closePopup:self parentViewController:self.parentViewController];
}

- (void)addOptions:(NSArray*)options
{
    [self adjustHeight:options.count];
    
    NSMutableArray *cardOptions = [[NSMutableArray alloc] init];
    
    for (NSString *option in options)
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:option forKey:@"name"];
        [dic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        
        [cardOptions addObject:dic];
    }
    
    [contentListArray addObjectsFromArray:cardOptions];
    [contentTableView reloadData];
}

- (IBAction)confirmCurrentPopup:(id)sender
{
    switch (_type)
    {
        case PERMISSON:
            if ([self.delegate respondsToSelector:@selector(didSelectContent:)])
            {
                if ([contentDic count] > 0)
                    [self.delegate didSelectContent:contentDic];
            }
            break;
            
            
        case CARD_OPTION:
            if ([self.delegate respondsToSelector:@selector(didSelectCardOption:)])
            {
                if (selectedIndex != NOT_SELECTED)
                {
                    [self.delegate didSelectCardOption:selectedIndex];
                }
            }
            break;
            
        case ASSIGN_CARD:
            if ([self.delegate respondsToSelector:@selector(didSelectCard:)])
            {
                if ([contentDic count] > 0)
                    [self.delegate didSelectCard:contentDic];
            }
            break;
        case PEROID:
            if ([self.delegate respondsToSelector:@selector(didSelectDateOption:)])
            {
                if (selectedIndex != NOT_SELECTED)
                {
                    [self.delegate didSelectDateOption:selectedIndex];
                }
            }
            break;
        default:
            break;
    }
    
    
    [self closePopup:self parentViewController:self.parentViewController];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [contentListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RadioCell" forIndexPath:indexPath];
    RadioCell *customCell = (RadioCell*)cell;
    
    NSDictionary *currentDic = [contentListArray objectAtIndex:indexPath.row];
    
    [customCell checkSelected:[[currentDic objectForKey:@"selected"] boolValue]];
    
    switch (_type)
    {
        case PEROID:
        case CARD_OPTION:
            customCell.titleLabel.text = (NSLocalizedString([[contentListArray objectAtIndex:indexPath.row] objectForKey:@"name"], nil));
            break;
        case ASSIGN_CARD:
            customCell.titleLabel.text = [[contentListArray objectAtIndex:indexPath.row] objectForKey:@"card_id"];
            break;
        case PERMISSON:
            customCell.titleLabel.text = [[contentListArray objectAtIndex:indexPath.row] objectForKey:@"description"];
            break;
        default:
            break;
    }
    
    
    
    return customCell;
}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isRadioStyle)
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
        
        
        if (_type == CARD_OPTION || _type == PEROID)
        {
            selectedIndex = indexPath.row;
        }
        else
        {
            [contentDic setDictionary:[contentListArray objectAtIndex:indexPath.row]];
        }
        
        [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        
    }
    
}



#pragma mark - UserProviderDelegate

- (void)requestDidFinishGetUserGroups:(NSArray*)groups
{
    [self adjustHeight:groups.count];
    
    NSMutableArray *newGroup = [[NSMutableArray alloc] init];
    
    for (NSDictionary *group in groups)
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:group];
        [dic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        
        [newGroup addObject:dic];
    }
    
    [contentListArray addObjectsFromArray:newGroup];
    [contentTableView reloadData];
    
}

- (void)requestUserProviderDidFail:(NSDictionary*)errDic;
{
}

#pragma mark - PermissionProviderDelegate


- (void)requestGetPermissionDidFinish:(NSArray*)permissions
{
    [self finishLoading];
    [self adjustHeight:permissions.count + 1];
    
    NSMutableArray *newPermissions = [[NSMutableArray alloc] init];
    
    for (NSDictionary *permission in permissions)
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:permission];
        [dic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        
        [newPermissions addObject:dic];
    }
//    NSMutableDictionary *noneDic = [[NSMutableDictionary alloc] init];
//    [noneDic setObject:@"NONE" forKey:@"name"];
//    [noneDic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
//    [newPermissions addObject:noneDic];
    
    [contentListArray addObjectsFromArray:newPermissions];
    [contentTableView reloadData];
}


- (void)requestPermisionProviderDidFail:(NSDictionary*)errDic
{
    [self finishLoading];
    if ([self.delegate respondsToSelector:@selector(cancelListPopupWithError:)])
    {
        [self.delegate cancelListPopupWithError:errDic];
    }
    [self closePopup:self parentViewController:self.parentViewController];
    
}

#pragma mark - DeviceProviderDelegate
- (void)requestGetDevicesDidFinish:(NSArray*)devices totalCount:(NSInteger)total
{
    [self adjustHeight:devices.count];
    
    NSMutableArray *newDevices = [[NSMutableArray alloc] init];
    
    for (NSDictionary *device in devices)
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:device];
        [dic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        
        [newDevices addObject:dic];
    }
    
    [contentListArray addObjectsFromArray:newDevices];
    [contentTableView reloadData];
}

- (void)requestGetCardsDidFinish:(NSDictionary *)cardColletion
{
    [self adjustHeight:cardColletion.count];
    
    NSInteger totalCount = [[cardColletion objectForKey:@"total"] integerValue];
    
    NSMutableArray *newCardCollection = [[NSMutableArray alloc] init];
    
    for (NSDictionary *card in [cardColletion objectForKey:@"rows"])
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:card];
        [dic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        
        [newCardCollection addObject:dic];
    }
    
    [contentListArray addObjectsFromArray:newCardCollection];
    [contentTableView reloadData];
    
    if (totalCount > limit)
    {
        offset += limit;
        [deviceProvider getCardsWithGroupID:@"0" limit:limit offset:offset];
    }
}

#pragma mark = ImagePopupDelegate

- (void)confirmImagePopup
{
    
}

- (void)cancelImagePopup
{
    
}

@end
