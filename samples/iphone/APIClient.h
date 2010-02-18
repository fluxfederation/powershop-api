//
//  APIClient.h
//  iPower
//
//  Created by Roger ; on 03/01/2010.
//  Copyright 2010 Powershop. All rights reserved.
//

#import "OAConsumer.h"
#import "OAToken.h"
#import "Settings.h"
#import "OADataFetcher.h"
#import "OAMutableURLRequest.h"

#define PROTOCOL_VERSION @"v1"

#if defined(TARGET_PRODUCTION_SERVER)
	#define POWERSHOP_API_URL @"https://secure.powershop.co.nz/external_api"
#elif defined(TARGET_TEST_SERVER)
	#define POWERSHOP_API_URL @"https://suppliertest.youdo.co.nz/external_api"
#elif defined(TARGET_DEVELOPMENT_SERVER)
	#define POWERSHOP_API_URL @"http://powershop.localhost/external_api"
#else
	#error "Before compiling you must first specify which server you are targetting in Settings.h"
#endif

@class APIClientRequest;

@interface APIClient : NSObject {
	OAConsumer *consumer;
	OAToken *accessToken;
	
	@private
	id delegate;
	SEL accessTokenReceivedSelector;
	SEL accessTokenErrorSelector;
	SEL requestTokenErrorSelector;
	OADataFetcher *fetcher;
	OAMutableURLRequest *request;
}

@property (nonatomic, retain) OAConsumer *consumer;
@property (nonatomic, retain) OAToken *accessToken;

- (id)init;
- (void)getRequestTokenWithDelegate:(id)aDelegate errorSelector:(SEL)errorSelector;
- (void)getAccessToken:(NSString *)query delegate:(id)aDelegate receivedSelector:(SEL)receivedSelector errorSelector:(SEL)errorSelector;
- (APIClientRequest *)newRequest;

- (OAToken *)loadTokenWithPrefix:(NSString *)prefix;
- (void)storeToken:(OAToken *)token prefix:(NSString *)prefix;
- (void)removeTokenWithPrefix:(NSString *)prefix;

@end
