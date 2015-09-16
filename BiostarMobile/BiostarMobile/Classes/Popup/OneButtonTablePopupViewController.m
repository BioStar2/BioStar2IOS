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

#import "OneButtonTablePopupViewController.h"

@interface OneButtonTablePopupViewController ()

@end

@implementation OneButtonTablePopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    contentListArray = [[NSMutableArray alloc] init];
    
    [self showPopupAnimation:self.containerView];
    selectedIndex = -1;
    
    switch (_type)
    {
        case MORNITORING:
                titleLabel.text = NSLocalizedString(@"select_link", nil);
            break;
            
        case PHOTO:
                titleLabel.text = NSLocalizedString(@"edit_photo", nil);
            break;
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

- (void)setContentListArray:(NSArray*)array
{
    for (NSDictionary *info in array)
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:info];
        [dic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        
        [contentListArray addObject:dic];
    }
    
    [radioTableView reloadData];
}

- (IBAction)confirmSelection:(id)sender {
    
    if (selectedIndex != -1)
    {
        switch (_type)
        {
            case MORNITORING:
                if ([self.delegate respondsToSelector:@selector(didSelectItem:)])
                {
                    [self.delegate didSelectItem:[contentListArray objectAtIndex:selectedIndex]];
                }
                break;
                
            case PHOTO:
                if ([self.delegate respondsToSelector:@selector(didSelectIndex:)])
                {
                    [self.delegate didSelectIndex:selectedIndex];
                }
                break;
        }
        
    }
    
    [self closePopup:self parentViewController:self.parentViewController];
}

- (IBAction)cancelCurrentPopup:(id)sender
{
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
    [customCell checkSelected:[[[contentListArray objectAtIndex:indexPath.row] objectForKey:@"selected"] boolValue]];
    customCell.titleLabel.text = [[contentListArray objectAtIndex:indexPath.row] objectForKey:@"name"];

    
    return customCell;
}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = indexPath.row;
    
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
    
    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];

}

@end
