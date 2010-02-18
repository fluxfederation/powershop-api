//
//  Property.h
//  iPower
//
//  Created by Roger Nesbitt on 03/01/2010.
//  Copyright 2010 Powershop. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Address;
@class Customer;
@class Register;

@interface Property :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSNumber * dailyConsumption;
@property (nonatomic, retain) NSNumber * unitBalance;
@property (nonatomic, retain) NSDate * lastAccountReviewAt;
@property (nonatomic, retain) NSString * icpNumber;
@property (nonatomic, retain) Address * address;
@property (nonatomic, retain) NSSet* registers;
@property (nonatomic, retain) Customer * customer;

@end


@interface Property (CoreDataGeneratedAccessors)
- (void)addRegistersObject:(Register *)value;
- (void)removeRegistersObject:(Register *)value;
- (void)addRegisters:(NSSet *)value;
- (void)removeRegisters:(NSSet *)value;

@end

