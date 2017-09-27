//
//  EventPopupViewController.m
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 10..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "EventPopupViewController.h"

@interface EventPopupViewController ()

@end

@implementation EventPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self setSharedViewController:self];
    
    [cancelBtn setTitle:NSBaseLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSBaseLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    totalDecLabel.text = NSBaseLocalizedString(@"total", nil);
    eventTypes = [[NSMutableArray alloc] init];
    selectedEventTypes = [[NSMutableArray alloc] init];
    [containerView setHidden:YES];
    hasNextPage = NO;
    offset = 0;
    limit = 50;
    
    listTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    eventProvider = [[EventProvider alloc] init];
    titleLabel.text = NSBaseLocalizedString(@"select_event", nil);
    
    [eventTypes addObjectsFromArray:[EventProvider getLocalEventTypes]];
    searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld", (long)eventTypes.count];
    [self adjustHeight:eventTypes.count];
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
        
        [eventTypes removeAllObjects];
        [eventTypes addObjectsFromArray:[EventProvider getLocalEventTypes]];
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
    if (self.eventTypeBlock && selectedEventTypes.count != 0)
    {
        self.eventTypeBlock(selectedEventTypes);
        self.eventTypeBlock = nil;
    }
    
    [self closePopup:self parentViewController:self.parentViewController];
}

- (void)getEventTypeBlock:(EventTypeBlock)eventTypeBlock;
{
    self.eventTypeBlock = eventTypeBlock;
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return eventTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RadioCell" forIndexPath:indexPath];
    RadioCell *customCell = (RadioCell*)cell;
    EventType *eventType = [eventTypes objectAtIndex:indexPath.row];
    [customCell checkSelected:eventType.isSelected];
    
    customCell.titleLabel.text = eventType.event_type_description;
    
    return customCell;
}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventType *eventType = [eventTypes objectAtIndex:indexPath.row];
    eventType.isSelected = !eventType.isSelected;
    
    if (eventType.isSelected)
    {
        [selectedEventTypes addObject:eventType];
    }
    else
    {
        [selectedEventTypes removeObject:eventType];
    }
    
    searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)selectedEventTypes.count, (long)eventTypes.count];
    
    [tableView reloadData];
}



#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""])
    {
        NSMutableArray <EventType*> *searchArray = [[NSMutableArray alloc] init];
        
        for (EventType *event in [EventProvider getLocalEventTypes])
        {
            event.isSelected = NO;
            
            
            NSString *name = event.event_type_description;
            name = [name uppercaseString];
            
            query = textField.text;
            query = [query uppercaseString];
            
            NSRange range;
            range = [name rangeOfString:query];
            
            if (range.location != NSNotFound)
            {
                [searchArray addObject:event];
            }
            
            NSString *code = [NSString stringWithFormat:@"%ld", (long)event.code];
            
            range = [code rangeOfString:query];
            
            if (range.location != NSNotFound)
            {
                [searchArray addObject:event];
            }
        }
        
        [selectedEventTypes removeAllObjects];
        [eventTypes removeAllObjects];
        [eventTypes addObjectsFromArray:searchArray];
        [listTableView reloadData];
        didSearch = YES;

        searchTotalCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", (long)selectedEventTypes.count, (long)eventTypes.count];
        
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
