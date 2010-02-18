//
//  PropertiesListController.h
//  iPower
//
//  Created by Roger Nesbitt on 03/01/2010.
//  Copyright 2010 Powershop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Property.h"

@interface PropertiesListController : UIViewController <UITableViewDelegate, UINavigationBarDelegate> {
	UITableView *tableView;	
}

@property (nonatomic, retain) IBOutlet UITableView* tableView;

- (void)showProperty:(Property *)property;
- (IBAction)logoutButtonClicked:(id)sender;

@end
