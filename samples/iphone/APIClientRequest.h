//
//  APIClientRequest.h
//  iPower
//
//  Created by Roger Nesbitt on 03/01/2010.
//  Copyright 2010 Powershop. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "OADataFetcher.h"
#import "OAMutableURLRequest.h"
#import "APIClient.h"

@interface APIClientRequest : NSObject {
	APIClient *client;
	id delegate;
	SEL finishSelector;
	SEL failSelector;
	
	@private
	NSManagedObjectModel *managedObjectModel;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSManagedObjectContext *managedObjectContext;
	NSDateFormatter *dateFormatter;
	NSDateFormatter *timeFormatter;
	OAMutableURLRequest *request;
	OADataFetcher *fetcher;
}

@property (nonatomic, retain) APIClient *client;
@property (assign) id delegate;
@property SEL finishSelector;
@property SEL failSelector;

- (id)initWithAPIClient:(APIClient *)client;

- (BOOL)requestCustomerData;

- (BOOL)requestProductsForICP:(NSString *)icpNumber;

- (BOOL)requestReadingsForICP:(NSString *)icpNumber 
					startDate:(NSDate *)startDate
					  endDate:(NSDate *)endDate;

- (BOOL)requestTopUpForICP:(NSString *)icpNumber;

- (BOOL)performTopUpForICP:(NSString *)icpNumber 
				  offerKey:(NSString *)offerKey;

- (BOOL)createReadingsForICP:(NSString *)icpNumber
					readings:(NSDictionary *)readings;

@end
