//
//  EventPopupViewController.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 10..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "BaseViewController.h"
#import "RadioCell.h"
#import "EventProvider.h"
#import "ImagePopupViewController.h"

@interface EventPopupViewController : BaseViewController
{
    __weak IBOutlet NSLayoutConstraint *containerHeightConstraint;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *searchTotalCountLabel;
    __weak IBOutlet UITableView *listTableView;
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UIView *multiSelectSearchView;
    __weak IBOutlet UIView *textView;
    __weak IBOutlet UITextField *searchTextField;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UIButton *confirmBtn;
    
    EventProvider *eventProvider;
    NSMutableArray <EventType*> *eventTypes;
    NSMutableArray <EventType*> *selectedEventTypes;
    
    NSString *query;
    NSInteger offset;
    NSInteger limit;
    
    BOOL hasNextPage;
    BOOL isForSearch;
}

typedef void (^EventTypeBlock)(NSArray <EventType*> *eventTypes);


@property (nonatomic, strong) EventTypeBlock eventTypeBlock;


- (IBAction)showSearchTextFieldView:(id)sender;

- (IBAction)cancelSearch:(id)sender;

- (void)adjustHeight:(NSInteger)count;

- (IBAction)cancelCurrentPopup:(id)sender;

- (IBAction)confirmCurrentPopup:(id)sender;

- (void)getEventTypeBlock:(EventTypeBlock)eventTypeBlock;

@end
