//
//  ProductsViewController.h
//  iPower
//
//  Created by Roger Nesbitt on 4/01/10.
//  Copyright 2010 Powershop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"
#import "APIClientRequest.h"

@class TopUpViewController;

@interface ProductsViewController : UIViewController {
	NSMutableArray *products;
	APIClientRequest *request;
	UIViewController *loadingViewController;

	@private
	UITableView *tableView;
	UINavigationBar *navigationBar;
	TopUpViewController *topUpViewController;
	NSString *dataLoadedForIcpNumber;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet TopUpViewController *topUpViewController;
@property (nonatomic, retain) IBOutlet UIViewController *loadingViewController;

- (IBAction)topUpClicked:(int)sender;

@end
