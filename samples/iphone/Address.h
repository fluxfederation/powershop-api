//
//  Address.h
//  iPower
//
//  Created by Roger Nesbitt on 03/01/2010.
//  Copyright 2010 Powershop. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Property;

@interface Address :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * district;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSString * flatNumber;
@property (nonatomic, retain) NSString * streetName;
@property (nonatomic, retain) NSString * suburb;
@property (nonatomic, retain) NSString * streetNumber;
@property (nonatomic, retain) Property * property;

- (NSString *)fullAddress;
- (NSString *)streetAddress;

@end



