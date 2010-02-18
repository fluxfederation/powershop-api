//
//  APIClientRequest.m
//  iPower
//
//  Created by Roger Nesbitt on 03/01/2010.
//  Copyright 2010 Powershop. All rights reserved.
//

#import "JSON.h"
#import "NSString+URLEncoding.h"
#import "APIClientRequest.h"
#import "Customer.h"
#import "Property.h"
#import "Address.h"
#import "Register.h"
#import "Product.h"
#import "Reading.h"
#import "TopUp.h"
#import "Settings.h"

@implementation APIClientRequest

@synthesize client;
@synthesize delegate, finishSelector, failSelector;

- (id)initWithAPIClient:(APIClient *)aClient {
	if (self = [super init]) {
		self.client = [aClient retain];
	
		managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
		persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel];
		managedObjectContext = [NSManagedObjectContext new];
		[managedObjectContext setPersistentStoreCoordinator: persistentStoreCoordinator];		
		
		dateFormatter = [NSDateFormatter new];
		[dateFormatter setDateFormat:@"yyyy-MM-dd"];
		
		timeFormatter = [NSDateFormatter new];
		[timeFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];		
		
		fetcher = [OADataFetcher new];
	}
	return self;
}

- (BOOL)genericRequest:(NSString *)action 		   
		   queryString:(NSString *)queryString
				method:(NSString *)method
			  postData:(NSDictionary *)postData
				parser:(SEL)parser {
		
	NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@.js%@", POWERSHOP_API_URL, PROTOCOL_VERSION, action, queryString];
	NSURL *url = [NSURL URLWithString:urlString];

	[request release];
	request = [[OAMutableURLRequest alloc] initWithURL:url
											  consumer:client.consumer
												 token:client.accessToken
												 realm:nil
									 signatureProvider:nil];

    [request setHTTPMethod:method];
	
	if (postData) {
		NSMutableArray *parameters = [[NSMutableArray new] autorelease];
		for (NSString *key in postData) {
			OARequestParameter *p = [OARequestParameter requestParameterWithName:key value:[postData objectForKey:key]];
			[parameters addObject:p];
		}
		
		if ([parameters count] > 0) {
			[request setParameters: parameters];
		}
	}
	
	[fetcher fetchDataWithRequest:request
						 delegate:self
				didFinishSelector:parser
				  didFailSelector:@selector(callTicket:didFailWithError:)];
	
	return YES;	
}

- (BOOL)genericRequest:(NSString *)action 		   
		   queryString:(NSString *)queryString
				parser:(SEL)parser {
	return [self genericRequest:action queryString:queryString method:@"GET" postData:nil parser:parser];
}



- (BOOL)requestCustomerData {
	return [self genericRequest:@"customer" 
					queryString:@"" 
						 parser:@selector(customerRequest:didFinishWithData:)];
}

- (BOOL)requestProductsForICP:(NSString *)icpNumber {	
	return [self genericRequest:@"products" 
					queryString:[NSString stringWithFormat:@"?icp_number=%@", [icpNumber URLEncodedString]] 
						 parser:@selector(productsRequest:didFinishWithData:)];
}

- (BOOL)requestReadingsForICP:(NSString *)icpNumber 
					startDate:(NSDate *)startDate
					  endDate:(NSDate *)endDate {	
	return [self genericRequest:@"meter_readings" 
					queryString:[NSString stringWithFormat:@"?icp_number=%@&start_date=%@&end_date=%@", [icpNumber URLEncodedString], [dateFormatter stringFromDate:startDate], [dateFormatter stringFromDate:endDate]]
						 parser:@selector(readingsRequest:didFinishWithData:)];
}

- (BOOL)createReadingsForICP:(NSString *)icpNumber
					readings:(NSDictionary *)readings {
	NSMutableDictionary *dict = [[NSMutableDictionary new] autorelease];
	[dict setObject:icpNumber forKey:@"icp_number"];
	
	for (NSString *registerNumber in readings) {
		NSString *paramName = [NSString stringWithFormat:@"readings[%@]", registerNumber];
		NSString *paramValue = [readings objectForKey:registerNumber];		
		[dict setObject:paramValue forKey:paramName];
	}	
	
	return [self genericRequest:@"meter_readings"
					queryString:@""
						 method:@"POST"
					   postData:dict
						 parser:@selector(updateAction:didFinishWithData:)];	
}

- (BOOL)requestTopUpForICP:(NSString *)icpNumber {	
	return [self genericRequest:@"top_up"
					queryString:[NSString stringWithFormat:@"?icp_number=%@", [icpNumber URLEncodedString]] 
						 parser:@selector(topUpRequest:didFinishWithData:)];
}

- (BOOL)performTopUpForICP:(NSString *)icpNumber offerKey:(NSString *)offerKey {	
	return [self genericRequest:@"top_up"
					queryString:@""
						 method:@"POST"
					   postData:[NSDictionary dictionaryWithObjectsAndKeys: icpNumber, @"icp_number", offerKey, @"offer_key", nil]
						 parser:@selector(updateAction:didFinishWithData:)];
}

- (NSString*)emptyIfNull:(NSDictionary *)dict key:(NSString *)key {
	NSString *string = [dict objectForKey:key];
	return [[NSNull null] isEqual:string] ? @"" : string;
}

- (void)customerRequest:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];	
//	NSLog(@"json data: %@", string);
	
	NSError *error;
	NSDictionary *root = [[[SBJSON new] autorelease] objectWithString:string error:&error];
	
	if (root) {		
		Customer *customer = [NSEntityDescription insertNewObjectForEntityForName:@"Customer" inManagedObjectContext:managedObjectContext];
		NSArray *properties = [[root objectForKey:@"result"] objectForKey:@"properties"];
		for (NSDictionary *property_data in properties) {
			Property *property = [NSEntityDescription insertNewObjectForEntityForName:@"Property" inManagedObjectContext:managedObjectContext];
			property.dailyConsumption = [property_data objectForKey:@"daily_consumption"];
			property.endDate = [dateFormatter dateFromString:[property_data objectForKey:@"end_date"]];
			property.icpNumber = [property_data objectForKey:@"icp_number"];
			property.lastAccountReviewAt = [timeFormatter dateFromString:[property_data objectForKey:@"last_account_review_at"]];
			property.startDate = [dateFormatter dateFromString:[property_data objectForKey:@"start_date"]];
			property.unitBalance = [property_data objectForKey:@"unit_balance"];
			
			NSDictionary *address_data = [property_data objectForKey:@"address"];			
			Address *address = [NSEntityDescription insertNewObjectForEntityForName:@"Address" inManagedObjectContext:managedObjectContext];
			address.flatNumber = [self emptyIfNull:address_data key:@"flat_number"];
			address.streetNumber = [self emptyIfNull:address_data key:@"street_number"];
			address.streetName = [self emptyIfNull:address_data key:@"street_name"];
			address.suburb = [self emptyIfNull:address_data key:@"suburb"];
			address.district = [self emptyIfNull:address_data key:@"district"];
			address.region = [self emptyIfNull:address_data key:@"region"];
			property.address = address;
			
			for (NSDictionary *register_data in [property_data objectForKey:@"registers"]) {
				Register *meter_register = [NSEntityDescription insertNewObjectForEntityForName:@"Register" inManagedObjectContext:managedObjectContext];
				NSNumber *number = [register_data objectForKey:@"dials"];				
				meter_register.dials = [[NSNull null] isEqual:number] ? [NSNumber numberWithInt:8] : number;
				meter_register.estimatedReadingValue = [self emptyIfNull:register_data key:@"estimated_reading_value"];
				meter_register.lastReadingAt = [timeFormatter dateFromString:[self emptyIfNull:register_data key:@"last_reading_at"]];
				meter_register.lastReadingType = [self emptyIfNull:register_data key:@"last_reading_type"];
				meter_register.lastReadingValue = [self emptyIfNull:register_data key:@"last_reading_value"];
				meter_register.registerDescription = [self emptyIfNull:register_data key:@"register_description"];
				meter_register.registerHidden = [register_data objectForKey:@"hidden"];
				meter_register.registerNumber = [self emptyIfNull:register_data key:@"register_number"];
				[property addRegistersObject:meter_register];
			}
			
			[customer addPropertiesObject:property];
		}
		
		[delegate performSelector:finishSelector withObject:customer];
		[customer release];
	} else {
		[delegate performSelector:failSelector withObject:[NSString stringWithFormat:@"JSON Parse Failed: %@", [error localizedDescription]]];
	}
}


- (void)productsRequest:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];	
	//NSLog(@"json data: %@", string);
	
	NSError *error;
	NSDictionary *root = [[[SBJSON new] autorelease] objectWithString:string error:&error];
	
	if (root) {
		NSMutableArray *products = [NSMutableArray new];
		NSArray *products_data = [root objectForKey:@"result"];
		for (NSDictionary *product_data in products_data) {
			Product *product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:managedObjectContext];
			product.productName = [product_data objectForKey:@"name"];
			product.productDescription = [product_data objectForKey:@"description"];
			product.productType = [product_data objectForKey:@"type"];
			product.pricePerUnit = [NSDecimalNumber decimalNumberWithString:[product_data objectForKey:@"price_per_unit"]];
			product.imageURL = [product_data objectForKey:@"image_url"];
			[products addObject:product];
		}
	
		[delegate performSelector:finishSelector withObject:products];
		[products release];
	} else {
		[delegate performSelector:failSelector withObject:[NSString stringWithFormat:@"JSON Parse Failed: %@", [error localizedDescription]]];
	}
}


- (void)readingsRequest:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];	
	//NSLog(@"json data: %@", string);
	
	NSError *error;
	NSDictionary *root = [[[SBJSON new] autorelease] objectWithString:string error:&error];
	
	if (root) {
		NSMutableArray *readings = [NSMutableArray new];
		NSArray *readings_data = [root objectForKey:@"result"];
		for (NSDictionary *reading_data in readings_data) {
			Reading *reading = [NSEntityDescription insertNewObjectForEntityForName:@"Reading" inManagedObjectContext:managedObjectContext];
			reading.readAt = [timeFormatter dateFromString:[reading_data objectForKey:@"read_at"]];
			reading.readingType = [reading_data objectForKey:@"reading_type"];			
			reading.readingValue = [reading_data objectForKey:@"reading_value"];
			reading.registerNumber = [reading_data objectForKey:@"register_number"];
			[readings addObject:reading];
		}
		
		[delegate performSelector:finishSelector withObject:readings];
		[readings release];
	} else {
		[delegate performSelector:failSelector withObject:[NSString stringWithFormat:@"JSON Parse Failed: %@", [error localizedDescription]]];
	}
}

- (void)topUpRequest:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];	
	//NSLog(@"json data: %@", string);
	
	NSError *error;
	NSDictionary *root = [[[SBJSON new] autorelease] objectWithString:string error:&error];
	
	if (root) {
		TopUp *topUp = [NSEntityDescription insertNewObjectForEntityForName:@"TopUp" inManagedObjectContext:managedObjectContext];
		NSDictionary *topUpData = [root objectForKey:@"result"];

		topUp.unitBalance = [topUpData objectForKey:@"unit_balance"];
		NSString *productName = [topUpData objectForKey:@"product_name"];
		if (![[NSNull null] isEqual:productName]) {
			topUp.productName = productName;
			topUp.offerKey = [topUpData objectForKey:@"offer_key"];
			topUp.pricePerUnit = [NSDecimalNumber decimalNumberWithString:[topUpData objectForKey:@"price_per_unit"]];
			topUp.totalPrice = [NSDecimalNumber decimalNumberWithString:[topUpData objectForKey:@"total_price"]];
		}
		else {
			topUp.productName = nil;
		}
		
		[delegate performSelector:finishSelector withObject:topUp];
	} else {
		[delegate performSelector:failSelector withObject:[NSString stringWithFormat:@"JSON Parse Failed: %@", [error localizedDescription]]];
	}
}

/* used for both POST meter_readings and POST top_up */
- (void)updateAction:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];	
	//NSLog(@"json data: %@", string);
	
	NSError *error;
	NSDictionary *root = [[[SBJSON new] autorelease] objectWithString:string error:&error];
	
	if (root) {
		NSDictionary *data = [root objectForKey:@"result"];
		
		NSNumber *success = [NSNumber numberWithBool:[[data objectForKey:@"result"] isEqual:@"success"]];
		NSString *errorMessage = [data objectForKey:@"message"];
		
		[delegate performSelector:finishSelector withObject:success withObject:errorMessage];
	} else {
		[delegate performSelector:failSelector withObject:[NSString stringWithFormat:@"JSON Parse Failed: %@", [error localizedDescription]]];
	}
}

- (void)callTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	NSString *message;
	
	if (ticket.responseData) {
		message = [[[NSString alloc] initWithData:ticket.responseData encoding:NSUTF8StringEncoding] autorelease];
	} else {
		message = [error localizedDescription];
	}
		
	[delegate performSelector:failSelector withObject:[NSString stringWithFormat:@"OAuth Data Call Failed: %@", message]];
}

- (void)dealloc {
	[request release];
	[fetcher release];
	[timeFormatter release];
	[dateFormatter release];
	[managedObjectContext release];
	[persistentStoreCoordinator release];
	[managedObjectModel release];
	[client release];
	[super dealloc];	
}

@end
