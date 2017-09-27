//
//  DoorControlPopupViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 10. 31..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "DoorControlPopupViewController.h"

@interface DoorControlPopupViewController ()

@end

@implementation DoorControlPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setSharedViewController:self];
    totalDecLabel.text = NSBaseLocalizedString(@"total", nil);
    [cancelBtn setTitle:NSBaseLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSBaseLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    
    isMenuSelected = NO;
    doorControlMenus = [[NSMutableArray alloc] init];
    
    [containerView setHidden:YES];
    
    titleLabel.text = NSBaseLocalizedString(@"door_control", nil);
    
    DoorControlMenu *openMenu = [[DoorControlMenu alloc] init];
    openMenu.name = NSBaseLocalizedString(@"open", nil);
    openMenu.isSelected = NO;
    [doorControlMenus addObject:openMenu];
    
    
    DoorControlMenu *lockMenu = [[DoorControlMenu alloc] init];
    lockMenu.name = NSBaseLocalizedString(@"manual_lock", nil);
    lockMenu.isSelected = NO;
    [doorControlMenus addObject:lockMenu];
    
    
    DoorControlMenu *unLockMenu = [[DoorControlMenu alloc] init];
    unLockMenu.name = NSBaseLocalizedString(@"manual_unlock", nil);
    unLockMenu.isSelected = NO;
    [doorControlMenus addObject:unLockMenu];
    
    
    DoorControlMenu *releaseMenu = [[DoorControlMenu alloc] init];
    releaseMenu.name = NSBaseLocalizedString(@"release", nil);
    releaseMenu.isSelected = NO;
    [doorControlMenus addObject:releaseMenu];
    
    
    DoorControlMenu *APBMenu = [[DoorControlMenu alloc] init];
    APBMenu.name = NSBaseLocalizedString(@"clear_apb", nil);
    APBMenu.isSelected = NO;
    [doorControlMenus addObject:APBMenu];
    
    
    DoorControlMenu *alarmMenu = [[DoorControlMenu alloc] init];
    alarmMenu.name = NSBaseLocalizedString(@"clear_alarm", nil);
    alarmMenu.isSelected = NO;
    [doorControlMenus addObject:alarmMenu];
    
    
    totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)doorControlMenus.count];
    [self adjustHeight:doorControlMenus.count];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelCurrentPopup:(id)sender
{
    [self closePopup:self parentViewController:self.parentViewController];
}

- (IBAction)confirmCurrentPopup:(id)sender
{
    if (self.indexResponseBlock) {
        if (isMenuSelected) {
            self.indexResponseBlock(selectedIndex);
            self.indexResponseBlock = nil;
        }
    }
    
    [self closePopup:self parentViewController:self.parentViewController];
}

- (void)getIndexResponse:(DoorControlPopupIndexResponseBlock)indexResponseBlock
{
    self.indexResponseBlock = indexResponseBlock;
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
    return doorControlMenus.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RadioCell" forIndexPath:indexPath];
    RadioCell *customCell = (RadioCell*)cell;
    
    DoorControlMenu *menu = [doorControlMenus objectAtIndex:indexPath.row];
    
    [customCell checkSelected:menu.isSelected];
    customCell.titleLabel.text = menu.name;
    
    return customCell;
}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (DoorControlMenu *menu in doorControlMenus)
    {
        menu.isSelected = NO;
    }
    DoorControlMenu *menu = [doorControlMenus objectAtIndex:indexPath.row];
    menu.isSelected = YES;
    
    
    selectedIndex = indexPath.row;
    isMenuSelected = YES;
    
    [tableView reloadData];
}
@end
