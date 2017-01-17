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
    
    [cancelBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    
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



- (void)setContentModelArray:(NSArray<SelectModel*>*)array
{
    [contentListArray addObjectsFromArray:array];
    [radioTableView reloadData];
}

- (void)setContentStringArray:(NSArray<NSString*>*)names
{
    for (NSString *name in names) {
        SelectModel *model = [SelectModel new];
        model.name = name;
        [contentListArray addObject:model];
    }
    
    [radioTableView reloadData];
}

- (void)getIndexResponse:(TablePopupIndexResponseBlock)responseBlock
{
    self.indexResponseBlock = responseBlock;
}

- (void)getModelResponse:(TablePopupModelResponseBlock)responseBlock
{
    self.modelResponseBlock = responseBlock;
}

- (IBAction)confirmSelection:(id)sender {
    
    if (selectedIndex != -1)
    {
        switch (_type)
        {
            case MORNITORING:
                if (self.modelResponseBlock)
                {
                    self.modelResponseBlock([contentListArray objectAtIndex:selectedIndex]);
                    self.modelResponseBlock = nil;
                }
                break;
                
            case PHOTO:
                if (self.indexResponseBlock)
                {
                    self.indexResponseBlock(selectedIndex);
                    self.indexResponseBlock = nil;
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
    SelectModel *model = [contentListArray objectAtIndex:indexPath.row];
    [customCell checkSelected:model.isSelected];
    customCell.titleLabel.text = model.name;

    return customCell;
}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = indexPath.row;
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    SelectModel *model = [contentListArray objectAtIndex:indexPath.row];
    
    NSInteger index = 0;
    
    for (SelectModel *model in contentListArray)
    {
        model.isSelected = NO;
        
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        index++;
        
    }
    
    model.isSelected = YES;
    
    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];

}

@end
