//
//  Customer.h
//  iPower
//
//  Created by Roger Nesbitt on 03/01/2010.
//  Copyright 2010 Powershop. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Property;

@interface Customer :  NSManagedObject  
{
}

@property (nonatomic, retain) NSSet* properties;

@end


@interface Customer (CoreDataGeneratedAccessors)
- (void)addPropertiesObject:(Property *)value;
- (void)removePropertiesObject:(Property *)value;
- (void)addProperties:(NSSet *)value;
- (void)removeProperties:(NSSet *)value;

@end

