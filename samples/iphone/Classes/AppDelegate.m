//
//  AppDelegate.m
//  iPower
//
//  Created by Roger Nesbitt on 02/01/2010.
//  Copyright Powershop 2010. All rights reserved.
//

#import "AppDelegate.h"
#import "Customer.h"
#import "OAConsumer.h"
#import "OAToken.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"

@implementation AppDelegate

@synthesize window, apiClient, tabBarController, propertiesListController, selectedProperty, properties, navigationBar;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	apiClient = [APIClient new];
	
	NSURL *launchedWithUrl = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
	
	if (launchedWithUrl) {
		[apiClient getAccessToken:[launchedWithUrl query] 
						 delegate:self 
				 receivedSelector:@selector(accessTokenReceived:) 
					errorSelector:@selector(accessTokenError:)];
	} 
	else if (apiClient.accessToken) {
		[self showPropertiesList];	
	} 
	else {		
		[self getRequestToken];
	}
		
	return true;
}

- (void)getRequestToken {
	[apiClient getRequestTokenWithDelegate:self errorSelector:@selector(requestTokenError:)];
}

- (void)requestTokenError:(NSString *)error {
	UIAlertView *box = [[UIAlertView alloc] initWithTitle:PRODUCT_NAME message:[NSString stringWithFormat:@"Error: %@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[box show];
	[box release];	
}

- (void)accessTokenReceived:(OAToken *)accessToken {
	[self showPropertiesList];
}

- (void)accessTokenError:(NSString *)error {
	UIAlertView *box = [[UIAlertView alloc] initWithTitle:PRODUCT_NAME message:[NSString stringWithFormat:@"Error: %@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[box show];
	[box release];	
}

- (void)showPropertiesList {
	[self reloadPropertyData];
	[window addSubview:propertiesListController.view];
}

- (void)reloadPropertyData {
	if (request == nil) {
		request = [[APIClientRequest alloc] initWithAPIClient:apiClient];
		request.delegate = self;
		request.finishSelector = @selector(didReceiveData:);
		request.failSelector = @selector(didReceiveError:);		
	}
	
	[request requestCustomerData];
}

- (void)didReceiveData:(Customer *)customer {
	NSString *icpNumber = nil;
	
	if (selectedProperty) {
		icpNumber = selectedProperty.icpNumber;
		selectedProperty = nil;
	}
	
	[properties release];
	properties = [[customer.properties allObjects] retain];
	
	if (icpNumber) {
		for (Property *p in properties) {
			if ([icpNumber isEqualToString:p.icpNumber]) {
				selectedProperty = p;
				break;
			}
		}
	}
	
	[[propertiesListController tableView] reloadData];
}

- (void)didReceiveError:(NSString *)error {
	NSLog(@"Error: %@", error);
	
	NSRange range = [error rangeOfString:@"[E903]"]; // error code for "invalid OAuth token"
	if (range.location != NSNotFound) {
		[apiClient getRequestTokenWithDelegate:self errorSelector:@selector(requestTokenError:)];
	}
	else {
		UIAlertView *box = [[UIAlertView alloc] initWithTitle:PRODUCT_NAME message:[NSString stringWithFormat:@"Error: %@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[box show];
		[box release];
	}
}

- (void)dealloc {
	[request release];
	[properties release];
	[propertiesListController release];
	[apiClient release];
    [window release];
    [super dealloc];
}

@end
