//
//  PropertyViewController.m
//  iPower
//
//  Created by Roger Nesbitt on 03/01/2010.
//  Copyright 2010 Powershop. All rights reserved.
//

#import "PropertyViewController.h"
#import "Address.h"
#import "AppDelegate.h"


@implementation PropertyViewController

@synthesize address, icpNumber, unitBalance, dailyConsumption, daysRemaining, daysRemainingDescription;


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];	
	
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	Property *property = delegate.selectedProperty;

	[[self view] addSubview:delegate.navigationBar];
	[[[delegate.navigationBar items] objectAtIndex:1] setRightBarButtonItem:nil animated:NO];	
	
	Address *a = property.address;
	NSDateFormatter *dateFormat = [[NSDateFormatter new] autorelease];
	[dateFormat setDateFormat: @"dd MMM YYYY"];
	
	unitBalance.text = [NSString stringWithFormat:@"%@", property.unitBalance];
	UIColor *color = property.unitBalance.doubleValue < 0 ? [UIColor colorWithRed:0.5 green:0 blue:0 alpha:1] : [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
	unitBalance.textColor = color;
	
	dailyConsumption.text = [NSString stringWithFormat:@"%@", property.dailyConsumption];
	
	daysRemaining.text = [NSString stringWithFormat:@"%.0f", fabs(floor(property.unitBalance.doubleValue / property.dailyConsumption.doubleValue))];
	daysRemaining.textColor = color;
	
	daysRemainingDescription.text = property.unitBalance.doubleValue < 0 ? @"Days in arrears" : @"Days remaining";

	icpNumber.text = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n\nICP %@\nLast account review was on %@", 
					  a.streetAddress, a.suburb, a.district, a.region,
					  property.icpNumber, [dateFormat stringFromDate:property.lastAccountReviewAt]];
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
    [super dealloc];
}

@end
