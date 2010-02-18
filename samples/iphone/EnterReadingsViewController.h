//
//  EnterReadingsViewController.h
//  iPower
//
//  Created by Roger Nesbitt on 6/01/10.
//  Copyright 2010 Powershop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Property.h"
#import "APIClientRequest.h"

@class ReadingsViewController;

@interface EnterReadingsViewController : UIViewController <UITextFieldDelegate> {
	NSMutableArray *registerNumbers;
	NSMutableArray *readings;
	UITableViewCell *enterReadingsTableViewCell;
	APIClientRequest *request;
	ReadingsViewController *parentController;
	UITableView *tableView;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *enterReadingsTableViewCell;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) ReadingsViewController *parentController;

- (IBAction) updateButtonPressed:(id)sender;
- (IBAction) cancelButtonPressed:(id)sender;

@end
