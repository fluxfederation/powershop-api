//
//  Product.h
//  iPower
//
//  Created by Roger Nesbitt on 4/01/10.
//  Copyright 2010 Powershop. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Product :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDecimalNumber * pricePerUnit;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSString * productType;
@property (nonatomic, retain) NSString * productDescription;

@end



