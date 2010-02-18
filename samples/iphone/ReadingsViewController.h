//
//  ReadingsViewController.h
//  iPower
//
//  Created by Roger Nesbitt on 4/01/10.
//  Copyright 2010 Powershop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APIClientRequest.h"
#import "Reading.h"

@class EnterReadingsViewController;

@interface ReadingsViewController : UIViewController <UITableViewDelegate> {
	NSMutableArray *readings;
	NSDateFormatter *dateFormatter;
	APIClientRequest *request;
	EnterReadingsViewController *enterReadingsViewController;
	UINavigationBar *navigationBar;
	UITableView *tableView;
	UIViewController *loadingViewController;
	NSString *dataLoadedForIcpNumber;
}

@property (nonatomic, retain) IBOutlet EnterReadingsViewController *enterReadingsViewController;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIViewController *loadingViewController;

- (IBAction)addButtonClicked:(id)sender;
- (void)didUpdateReadings:(id)sender;

@end
