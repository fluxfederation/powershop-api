//
//  Register.h
//  iPower
//
//  Created by Roger Nesbitt on 03/01/2010.
//  Copyright 2010 Powershop. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Property;

@interface Register :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * registerHidden;
@property (nonatomic, retain) NSNumber * dials;
@property (nonatomic, retain) NSString * lastReadingType;
@property (nonatomic, retain) NSString * estimatedReadingValue;
@property (nonatomic, retain) NSString * registerDescription;
@property (nonatomic, retain) NSDate * lastReadingAt;
@property (nonatomic, retain) NSString * lastReadingValue;
@property (nonatomic, retain) NSString * registerNumber;
@property (nonatomic, retain) Property * property;

@end



