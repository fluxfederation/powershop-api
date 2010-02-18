//
//  APIClient.m
//  iPower
//
//  Created by Roger Nesbitt on 03/01/2010.
//  Copyright 2010 Powershop. All rights reserved.
//

#import "APIClient.h"
#import "APIClientRequest.h"
#import "NSString+Explode.h"
#import "NSString+URLEncoding.h"
#import "NSData-AES.h"
#import "sha1.h"
#import "Settings.h"

@implementation APIClient

@synthesize consumer;
@synthesize accessToken;

- (id)init {
	if (self = [super init]) {
		self.consumer = [[OAConsumer alloc] initWithKey:OAUTH_CONSUMER_KEY
												  secret:OAUTH_CONSUMER_SECRET];
		
		self.accessToken = [[self loadTokenWithPrefix:@"access"] retain];
	}
	return self;
}

- (void)getRequestTokenWithDelegate:(id)aDelegate errorSelector:(SEL)errorSelector {
	delegate = aDelegate;
	requestTokenErrorSelector = errorSelector;
	
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/request_token", POWERSHOP_API_URL]];
	
	[request release];
    request = [[OAMutableURLRequest alloc] initWithURL:url
											  consumer:consumer
												 token:nil   // we don't have a Token yet
												 realm:nil   // our service provider doesn't specify a realm
									 signatureProvider:nil]; // use the default method, HMAC-SHA1
	
    [request setHTTPMethod:@"POST"];
	[request setParameters: [NSArray arrayWithObject: [[[OARequestParameter alloc] initWithName: @"oauth_callback" value: @"ipower-oauth://authorisation"] autorelease]]];
	
	[fetcher release];
	fetcher = nil;
    fetcher = [OADataFetcher new];
	
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];	
}	


- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	NSString *responseBody = [[[NSString alloc] initWithData:data
												   encoding:NSUTF8StringEncoding] autorelease];
	
	if (ticket.didSucceed) {		
		OAToken *requestToken = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] autorelease];
		[self storeToken:requestToken prefix:@"request"];
		
		NSString *urlString = [NSString stringWithFormat:@"%@/oauth/authorize?oauth_token=%@", POWERSHOP_API_URL, [requestToken.key URLEncodedString]];
		NSURL *url = [NSURL URLWithString:urlString];
		[[UIApplication sharedApplication] openURL:url];		
	}
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	[delegate performSelector:requestTokenErrorSelector withObject:[error localizedDescription]];
}



- (void)getAccessToken:(NSString *)query delegate:(id)aDelegate receivedSelector:(SEL)receivedSelector errorSelector:(SEL)errorSelector {
	delegate = aDelegate;
	accessTokenReceivedSelector = receivedSelector;
	accessTokenErrorSelector = errorSelector;
	
	NSMutableDictionary *queryDict = [query explodeToDictionaryInnerGlue:@"=" outterGlue:@"&"];
	NSString *oauth_verifier = [queryDict objectForKey:@"oauth_verifier"];
	
	OAToken *requestToken = [[self loadTokenWithPrefix:@"request"] retain];
	NSLog(@"request token key: %@", requestToken.key);
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/access_token", POWERSHOP_API_URL]];	
	
	[request release];
	request = [[OAMutableURLRequest alloc] initWithURL:url
											  consumer:consumer
												 token:requestToken
												 realm:nil   // our service provider doesn't specify a realm
									 signatureProvider:nil]; // use the default method, HMAC-SHA1
	
	[request setParameters:[NSArray arrayWithObject:[[[OARequestParameter alloc] initWithName:@"oauth_verifier" value:oauth_verifier] autorelease]]];		
	
	[fetcher release];
	fetcher = nil;
	fetcher = [OADataFetcher new];
	
	[fetcher fetchDataWithRequest:request
						 delegate:self
				didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
				  didFailSelector:@selector(accessTokenTicket:didFailWithError:)];	
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	NSString *responseBody = [[[NSString alloc] initWithData:data
												   encoding:NSUTF8StringEncoding] autorelease];
	
	if (ticket.didSucceed) {	
		[accessToken release];
		accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
		[self storeToken:accessToken prefix:@"access"];
		
		[delegate performSelector:accessTokenReceivedSelector withObject:accessToken];
	}
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	[delegate performSelector:accessTokenErrorSelector withObject:[error localizedDescription]];
}

- (APIClientRequest *)newRequest {
	return [[[APIClientRequest alloc] initWithAPIClient:self] autorelease];
}

- (NSString *)encrypt:(NSString *)encryptedText {
	NSData *encryptedData = [encryptedText dataUsingEncoding:NSISOLatin1StringEncoding];
	NSData *data = [encryptedData AESEncryptWithPassphrase:OAUTH_CONSUMER_SECRET];
	return [[[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding] autorelease];
}

- (NSString *)decrypt:(NSString *)text {
	NSData *data = [text dataUsingEncoding:NSISOLatin1StringEncoding];
	NSData *encryptedData = [data AESDecryptWithPassphrase:OAUTH_CONSUMER_SECRET];
	return [[[NSString alloc] initWithData:encryptedData encoding:NSISOLatin1StringEncoding] autorelease];	
}

- (OAToken *)loadTokenWithPrefix:(NSString *)prefix {
	NSString *encryptedKey = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"OAUTH_%@_%@_KEY", prefix, SERVICE_PROVIDER_NAME]];
	NSString *encryptedSecret = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"OAUTH_%@_%@_SECRET", prefix, SERVICE_PROVIDER_NAME]];
	if (encryptedKey == NULL || encryptedSecret == NULL) return nil;
	
	NSString *key = [self decrypt:encryptedKey];
	NSString *secret = [self decrypt:encryptedSecret];
	
	return [[[OAToken alloc] initWithKey:key secret:secret] autorelease];
}

- (void)storeToken:(OAToken *)token prefix:(NSString *)prefix {
	NSString *encryptedKey = [self encrypt:token.key];
	NSString *encryptedSecret = [self encrypt:token.secret];
	
	[[NSUserDefaults standardUserDefaults] setObject:encryptedKey forKey:[NSString stringWithFormat:@"OAUTH_%@_%@_KEY", prefix, SERVICE_PROVIDER_NAME]];
	[[NSUserDefaults standardUserDefaults] setObject:encryptedSecret forKey:[NSString stringWithFormat:@"OAUTH_%@_%@_SECRET", prefix, SERVICE_PROVIDER_NAME]];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeTokenWithPrefix:(NSString *)prefix {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"OAUTH_%@_%@_KEY", prefix, SERVICE_PROVIDER_NAME]];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"OAUTH_%@_%@_SECRET", prefix, SERVICE_PROVIDER_NAME]];
	[[NSUserDefaults standardUserDefaults] synchronize];	
}

- (void)dealloc {
	[fetcher release];
	[request release];
	[accessToken release];
	[consumer release];
	[super dealloc];
}

@end
