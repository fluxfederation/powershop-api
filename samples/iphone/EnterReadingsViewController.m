//
//  EnterReadingsViewController.m
//  iPower
//
//  Created by Roger Nesbitt on 6/01/10.
//  Copyright 2010 Powershop. All rights reserved.
//

#import "EnterReadingsViewController.h"
#import "AppDelegate.h"
#import "Register.h"
#import "ReadingsViewController.h"
#import "UIView+FindFirstResponder.h"

@implementation EnterReadingsViewController

@synthesize enterReadingsTableViewCell, parentController, tableView;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (registerNumbers == nil) registerNumbers = [NSMutableArray new];
	if (readings == nil) readings = [NSMutableArray new];	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	Property *property = delegate.selectedProperty;

	[registerNumbers removeAllObjects];
	[readings removeAllObjects];	
	
	for (Register *r in property.registers) {
		[registerNumbers addObject:r.registerNumber];
		[readings addObject:r.estimatedReadingValue];
	}
	
	[tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [registerNumbers count];
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"EnterReadingCellIdentifier";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"EnterReadingsTableCell" owner:self options:nil];
		cell = enterReadingsTableViewCell;
		self.enterReadingsTableViewCell = nil;
		
		UILabel *label = (UILabel *)[cell viewWithTag:1];
		label.text = [registerNumbers objectAtIndex:[indexPath row]];

		UITextField *field = (UITextField *)[cell viewWithTag:2];
		field.delegate = self;
		field.text = [readings objectAtIndex:[indexPath row]];
		field.tag = [indexPath row] + 10;
    }
	
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	int row = textField.tag - 10;
	[readings replaceObjectAtIndex:row withObject:textField.text];
}

- (IBAction) updateButtonPressed:(id)sender {
	UIView *responder = [[self view] findFirstResponder];
	[responder resignFirstResponder]; // do this so textFieldDidEndEditing will execute
	
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	Property *property = delegate.selectedProperty;	
		
	if (request == nil) {
		request = [[delegate.apiClient newRequest] retain];
		request.delegate = self;
		request.finishSelector = @selector(didReceiveData:errorMessage:);
		request.failSelector = @selector(didReceiveError:);	
	}
	
	[request createReadingsForICP:property.icpNumber readings:[NSDictionary dictionaryWithObjects:readings forKeys:registerNumbers]];
}

- (void)didReceiveData:(NSNumber *)aSuccess errorMessage:(NSString *)errorMessage {
	NSString *message;
	BOOL success = [aSuccess boolValue];
	
	if (success) {
		message = @"Your new readings have been entered.";
	}
	else {
		message = [NSString stringWithFormat:@"An error occurred: %@", errorMessage];
	}
	
	UIAlertView *box = [[UIAlertView alloc] initWithTitle:PRODUCT_NAME message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[box show];
	[box release];	
	
	if (success) {
		[[self view] removeFromSuperview];
		[parentController didUpdateReadings:self];
		AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		[delegate reloadPropertyData];
	}
}

- (void)didReceiveError:(NSString *)error {	
	UIAlertView *box = [[UIAlertView alloc] initWithTitle:PRODUCT_NAME message:[NSString stringWithFormat:@"Error: %@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[box show];
	[box release];
}

- (IBAction) cancelButtonPressed:(id)sender {
	[[self view] removeFromSuperview];	
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
	[request release];
	[registerNumbers release];
	[readings release];
    [super dealloc];
}

@end
