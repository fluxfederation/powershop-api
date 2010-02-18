//
//  ReadingsViewController.m
//  iPower
//
//  Created by Roger Nesbitt on 4/01/10.
//  Copyright 2010 Powershop. All rights reserved.
//

#import "ReadingsViewController.h"
#import "AppDelegate.h"
#import "Address.h"
#import "EnterReadingsViewController.h"

@implementation ReadingsViewController

@synthesize enterReadingsViewController, navigationBar, tableView, loadingViewController;

- (void)makeRequestThread {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	dataLoadedForIcpNumber = delegate.selectedProperty.icpNumber;
	
	[request requestReadingsForICP:delegate.selectedProperty.icpNumber 
						 startDate:[NSDate dateWithTimeIntervalSinceNow:-86400 * 90]
						   endDate:[NSDate date]];	
	[pool release];
}

- (void)makeRequest {
	[[self view] insertSubview:loadingViewController.view atIndex:1];
	[readings removeAllObjects];
	[NSThread detachNewThreadSelector:@selector(makeRequestThread) toTarget:self withObject:nil];	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (dateFormatter == nil) {
		dateFormatter = [NSDateFormatter new];
		[dateFormatter setDateFormat:@"dd MMM yyyy"];
	}
	
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
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonClicked:)] autorelease];
	[[[delegate.navigationBar items] objectAtIndex:1] setRightBarButtonItem:button animated:NO];
	
	if (dataLoadedForIcpNumber != delegate.selectedProperty.icpNumber) {
		[self makeRequest];
	}	
}


- (void)didReceiveDataMain:(NSArray *)aReadings {
	NSMutableArray *partialUpdate = nil;
	
	[loadingViewController.view removeFromSuperview];
	
	if (readings && [readings count] > 0) {
		int difference = [aReadings count] - [readings count];
		if (difference > 0) {
			partialUpdate = [[NSMutableArray new] autorelease];
			for (int index=0; index<difference; index++) {
				[partialUpdate addObject:[NSIndexPath indexPathForRow:index inSection:0]];
			}
		}
	}
	
	[readings release];	
	readings = [aReadings retain];
		
	if (partialUpdate) {
		[tableView beginUpdates];
		[tableView insertRowsAtIndexPaths:partialUpdate withRowAnimation:UITableViewRowAnimationTop];
		[tableView endUpdates];		
	} else {
		[tableView reloadData];
	}		
}

- (void)didReceiveData:(NSArray *)aReadings {
	[self performSelectorOnMainThread:@selector(didReceiveDataMain:) withObject:aReadings waitUntilDone:YES];
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

- (IBAction)addButtonClicked:(id)sender {
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	
	enterReadingsViewController.parentController = self;
	[delegate.window addSubview:enterReadingsViewController.view];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return readings ? [readings count] : 0;
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (readings == nil) return nil;
	
    static NSString *CellIdentifier = @"ReadingCellIdentifier";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
	
	Reading *reading = [readings objectAtIndex:indexPath.row];
	cell.textLabel.text = reading.registerNumber;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", reading.readingValue, [dateFormatter stringFromDate:reading.readAt]];
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (void)didUpdateReadings:(id)sender {
	[self makeRequest];	
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
	[enterReadingsViewController release];
	[navigationBar release];
	[request release];
	[dateFormatter release];
	[readings release];
    [super dealloc];
}

@end
