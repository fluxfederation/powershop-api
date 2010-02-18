//
//  TopUpViewController.m
//  iPower
//
//  Created by Roger Nesbitt on 5/01/10.
//  Copyright 2010 Powershop. All rights reserved.
//

#import "TopUpViewController.h"
#import "AppDelegate.h"
#import "Property.h"
#import "TopUp.h"


@implementation TopUpViewController

@synthesize label, topUp;

- (void)loadTopUpDetails {	
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	Property *property = delegate.selectedProperty;
	
	request = [[delegate.apiClient newRequest] retain];
	request.delegate = self;
	request.finishSelector = @selector(didReceiveData:);
	request.failSelector = @selector(didReceiveError:);
	
	[request requestTopUpForICP:property.icpNumber];
}

- (void)didReceiveData:(TopUp *)aTopUp {
	self.topUp = aTopUp;
	
	if (topUp.productName == nil) {
		UIAlertView *box = [[UIAlertView alloc] initWithTitle:PRODUCT_NAME message:@"You do not have any power owing at the moment." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[box show];
		[box release];
		[[self view] removeFromSuperview];
	}
	else {
		NSDecimalNumber *oneHundred = [NSDecimalNumber decimalNumberWithString:@"100"];
		NSDecimalNumber *perUnit = [topUp.pricePerUnit decimalNumberByMultiplyingBy:oneHundred];
										
		label.text = [NSString stringWithFormat:@"You are about to purchase %d units of %@ power at %@c per unit, for a total of $%@.",
					  -[topUp.unitBalance intValue], topUp.productName, perUnit, topUp.totalPrice];
	}
}

- (void)didReceiveError:(NSString *)error {	
	UIAlertView *box = [[UIAlertView alloc] initWithTitle:PRODUCT_NAME message:[NSString stringWithFormat:@"Error: %@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[box show];
	[box release];
}

- (IBAction)purchaseButtonClicked:(id)sender {
	request.finishSelector = @selector(didReceiveConfirmation:errorMessage:);
	
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	Property *property = delegate.selectedProperty;	
	
	[request performTopUpForICP:property.icpNumber offerKey:topUp.offerKey];	
}

- (void)didReceiveConfirmation:(NSNumber *)aSuccess errorMessage:(NSString *)errorMessage {
	NSString *message;
	BOOL success = [aSuccess boolValue];
	
	if (success) {
		message = @"Successfully purchased.";
	}
	else {
		message = [NSString stringWithFormat:@"An error occurred while topping up: %@.  Your top up has not been processed.", errorMessage];
	}
	
	UIAlertView *box = [[UIAlertView alloc] initWithTitle:PRODUCT_NAME message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[box show];
	[box release];	
	
	if (success) {
		[[self view] removeFromSuperview];

		AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		[delegate reloadPropertyData];
	}
}

- (IBAction)cancelButtonClicked:(id)sender {
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
	[topUp release];
	[request release];
    [super dealloc];
}


@end
