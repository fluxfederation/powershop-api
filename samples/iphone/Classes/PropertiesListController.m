//
//  PropertiesListController.m
//  iPower
//
//  Created by Roger Nesbitt on 03/01/2010.
//  Copyright 2010 Powershop. All rights reserved.
//

#import "PropertiesListController.h"
#import "PropertyViewController.h"
#import "AppDelegate.h"
#import "Customer.h"
#import "Address.h"
#import "Settings.h"

@implementation PropertiesListController

@synthesize tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];	
	[[self view] addSubview:delegate.navigationBar];
}

- (IBAction)logoutButtonClicked:(id)sender {
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];	
	[delegate.apiClient removeTokenWithPrefix:@"access"];
	[delegate getRequestToken];
}


#pragma mark -
#pragma mark Table view methods

- (NSArray *)properties {
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	return delegate.properties;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self properties] ? [[self properties] count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self properties] == nil) return nil;
	
    static NSString *PropertyCellIdentifier = @"PropertyCellIdentifier";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:PropertyCellIdentifier];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PropertyCellIdentifier] autorelease];
    }
	
	Property *property = [[self properties] objectAtIndex:indexPath.row];
	Address *address = property.address;
	cell.textLabel.text = address.streetAddress;
	cell.detailTextLabel.text = address.suburb;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self properties] && indexPath.row < [[self properties] count]) {	
		[self showProperty:[[self properties] objectAtIndex:indexPath.row]];
	}
}

- (void)showProperty:(Property *)property {
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	delegate.selectedProperty = property;
		
	Address *a = property.address;
	UINavigationItem *item = [[[UINavigationItem alloc] initWithTitle:a.streetAddress] autorelease];
	[delegate.navigationBar pushNavigationItem:item animated:YES];
	
    [delegate.window addSubview:delegate.tabBarController.view];
}

- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item {
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	
//	[UIView beginAnimations:nil context:NULL];
	[[delegate.tabBarController view] removeFromSuperview];
//	[UIView setAnimationDuration:1];
//	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
//	[UIView commitAnimations];
	
	[[self view] addSubview:delegate.navigationBar];	
}


#pragma mark -


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
    [super dealloc];
}


@end
