//
//  AppDelegate.h
//  iPower
//
//  Created by Roger Nesbitt on 02/01/2010.
//  Copyright Powershop 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PropertiesListController.h"
#import "OAToken.h"
#import "OAConsumer.h"
#import "APIClient.h"
#import "Property.h"
#import "APIClientRequest.h"

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PropertiesListController *propertiesListController;
	UITabBarController *tabBarController;	
	APIClient *apiClient;
	NSArray *properties;
	Property *selectedProperty;
	UINavigationBar *navigationBar;
	
	@private
	APIClientRequest *request;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) APIClient *apiClient;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet PropertiesListController *propertiesListController;
@property (nonatomic, retain) NSArray *properties;
@property (nonatomic, retain) Property *selectedProperty;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;

- (void)showPropertiesList;
- (void)reloadPropertyData;
- (void)getRequestToken;

@end
