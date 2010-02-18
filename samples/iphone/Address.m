// 
//  Address.m
//  iPower
//
//  Created by Roger Nesbitt on 03/01/2010.
//  Copyright 2010 Powershop. All rights reserved.
//

#import "Address.h"

#import "Property.h"

@implementation Address 

@dynamic district;
@dynamic region;
@dynamic flatNumber;
@dynamic streetName;
@dynamic suburb;
@dynamic streetNumber;
@dynamic property;

- (NSString *)fullAddress {
	return [NSString stringWithFormat:@"%@, %@", self.streetAddress, self.suburb];
}

- (NSString *)streetAddress {
	return [NSString stringWithFormat:@"%@%@ %@", 
			[self.flatNumber isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"%@/", self.flatNumber],
			self.streetNumber, 
			self.streetName];
}

@end
