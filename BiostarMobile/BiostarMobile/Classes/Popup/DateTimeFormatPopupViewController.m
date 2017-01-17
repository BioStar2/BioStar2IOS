//
//  DateTimeFormatPopupViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 1..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "DateTimeFormatPopupViewController.h"

@interface DateTimeFormatPopupViewController ()

@end

@implementation DateTimeFormatPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [cancelBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    totalDecLabel.text = NSLocalizedString(@"total", nil);
    
    switch (_type)
    {
        case TIME_FORMAT:
            titleLabel.text = NSLocalizedString(@"time_format", nil);
            timeFormats = [[NSMutableArray alloc] init];
            
            break;
        case DATE_FORMAT:
            titleLabel.text = NSLocalizedString(@"date_format", nil);
            totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)dateFormats.count];
            dateFormats = [[NSMutableArray alloc] init];
            
            break;
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

- (IBAction)cancelCurrentPopup:(id)sender
{
    [self closePopup:self parentViewController:self.parentViewController];
}

- (IBAction)confirmCurrentPopup:(id)sender
{
    
    switch (_type)
    {
        case TIME_FORMAT:
            if (self.timeFormatBlock) {
                if (nil != selectedTimeFormat) {
                    self.timeFormatBlock(selectedTimeFormat);
                    self.timeFormatBlock = nil;
                }
            }
            
            break;
        case DATE_FORMAT:
            if (self.dateFormateBlock) {
                if (nil != selectedDateFormat) {
                    self.dateFormateBlock(selectedDateFormat);
                    self.dateFormateBlock = nil;
                }
            }
            
            break;
    }
    
    [self closePopup:self parentViewController:self.parentViewController];
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

- (void)setTimeFormats:(NSArray*)array
{
    [timeFormats addObjectsFromArray:array];
    
    [listTableView reloadData];
    [self adjustHeight:timeFormats.count];
    totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)timeFormats.count];
}

- (void)setDateFormats:(NSArray*)array
{
    [dateFormats addObjectsFromArray:array];
    [listTableView reloadData];
    [self adjustHeight:dateFormats.count];
    totalCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)dateFormats.count];
}


- (void)getTimeFormatResponse:(TimeFormatResponseBlock)timeFormatBlock
{
    self.timeFormatBlock = timeFormatBlock;
}

- (void)getDateFormatResponse:(DateFormatResponseBlock)dateFormateBlock
{
    self.dateFormateBlock = dateFormateBlock;
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
        case TIME_FORMAT:
            return timeFormats.count;
            break;
        case DATE_FORMAT:
            return dateFormats.count;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RadioCell" forIndexPath:indexPath];
    RadioCell *customCell = (RadioCell*)cell;
    
    switch (_type)
    {
        case TIME_FORMAT:
        {
            TimeFormat *format = [timeFormats objectAtIndex:indexPath.row];
            customCell.titleLabel.text = format.time_format;
            [customCell checkSelected:format.isSelected];
        }
            return customCell;
            break;
        case DATE_FORMAT:
        {
            DateFormat *format = [dateFormats objectAtIndex:indexPath.row];
            customCell.titleLabel.text = format.date_format;
            [customCell checkSelected:format.isSelected];
        }
            return customCell;
            break;
    }
    
    
}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (_type)
    {
        case TIME_FORMAT:
        {
            for (TimeFormat *format in timeFormats)
            {
                format.isSelected = NO;
            }
            TimeFormat *format = [timeFormats objectAtIndex:indexPath.row];
            format.isSelected = YES;
            selectedTimeFormat = format;
        }
            break;
        case DATE_FORMAT:
        {
            for (DateFormat *format in dateFormats)
            {
                format.isSelected = NO;
            }
            DateFormat *format = [dateFormats objectAtIndex:indexPath.row];
            format.isSelected = YES;
            selectedDateFormat = format;
        }
            break;
    }
    
    isMenuSelected = YES;
    
    [tableView reloadData];
}
@end
