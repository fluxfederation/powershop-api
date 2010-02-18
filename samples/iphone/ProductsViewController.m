//
//  ProductsViewController.m
//  iPower
//
//  Created by Roger Nesbitt on 4/01/10.
//  Copyright 2010 Powershop. All rights reserved.
//

#import "ProductsViewController.h"
#import "TopUpViewController.h"
#import "Property.h"
#import "AppDelegate.h"
#import "Address.h"

@implementation ProductsViewController

@synthesize tableView, navigationBar, topUpViewController, loadingViewController;

- (void)makeRequestThread:(id)object {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	Property *property = delegate.selectedProperty;
	dataLoadedForIcpNumber = delegate.selectedProperty.icpNumber;	

	[request requestProductsForICP:property.icpNumber];
	
	[pool release];
}

- (void)makeRequest {
	[[self view] insertSubview:loadingViewController.view atIndex:1];
	[products removeAllObjects];
	[NSThread detachNewThreadSelector:@selector(makeRequestThread:) toTarget:self withObject:nil];	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[[self view] addSubview:loadingViewController.view];
	
	if (request == nil) {
		request = [[delegate.apiClient newRequest] retain];
		request.delegate = self;
		request.finishSelector = @selector(didReceiveData:);
		request.failSelector = @selector(didReceiveError:);		
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];	
	[[self view] addSubview:delegate.navigationBar];
	
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithTitle:@"Top Up" style:UIBarButtonItemStyleBordered target:self action:@selector(topUpClicked:)] autorelease];
	[[[delegate.navigationBar items] objectAtIndex:1] setRightBarButtonItem:button animated:NO];
	
	if (dataLoadedForIcpNumber != delegate.selectedProperty.icpNumber) {
		[self makeRequest];
	}	
}

NSInteger compareByPrice(Product *product1, Product *product2, void *context) {
	if (product1.pricePerUnit.doubleValue < product2.pricePerUnit.doubleValue) return NSOrderedAscending;
	if (product1.pricePerUnit.doubleValue > product2.pricePerUnit.doubleValue) return NSOrderedDescending;
	return NSOrderedSame;
}

- (void)didReceiveDataMain:(NSArray *)aProducts {
	[loadingViewController.view removeFromSuperview];
	
	[products release];	
	products = [[NSMutableArray alloc] initWithArray:[aProducts sortedArrayUsingFunction:compareByPrice context:NULL]];
	
	[[self tableView] reloadData];	
}

- (void)didReceiveData:(NSArray *)aProducts {
	[self performSelectorOnMainThread:@selector(didReceiveDataMain:) withObject:aProducts waitUntilDone:YES];
}

- (void)didReceiveErrorMain:(NSString *)error {	
	NSLog(@"Error: %@", error);
	
	UIAlertView *box = [[UIAlertView alloc] initWithTitle:PRODUCT_NAME message:[NSString stringWithFormat:@"Error: %@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[box show];
	[box release];
}

- (void)didReceiveError:(NSString *)error {	
	[self performSelectorOnMainThread:@selector(didReceiveErrorMain:) withObject:error waitUntilDone:YES];
}

- (IBAction)topUpClicked:(int)sender {
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];

	[delegate.window addSubview:topUpViewController.view];
	[topUpViewController loadTopUpDetails];
}



#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return products ? [products count] : 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (products == nil) return nil;
	
    static NSString *CellIdentifier = @"ProductCellIdentifier";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
	
	Product *product = [products objectAtIndex:[indexPath indexAtPosition:0]];
	switch ([indexPath indexAtPosition:1]) {
		case 0:
			cell.textLabel.text = @"Name";
			cell.detailTextLabel.text = product.productName;
			break;
			
		case 1:
			cell.textLabel.text = @"Price";
			NSDecimalNumber *tenThousand = [NSDecimalNumber decimalNumberWithString:@"10000"];
			int hundredthsOfCents = [product.pricePerUnit decimalNumberByMultiplyingBy:tenThousand].intValue;
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d.%0.2dc / unit", hundredthsOfCents / 100, hundredthsOfCents % 100];
			break;
	}
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[topUpViewController release];
	[tableView release];
	[navigationBar release];
	[request release];
	[products release];
    [super dealloc];
}


@end
