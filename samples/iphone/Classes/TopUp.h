//
//  TopUp.h
//  iPower
//
//  Created by Roger Nesbitt on 5/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface TopUp :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSDecimalNumber * pricePerUnit;
@property (nonatomic, retain) NSNumber * unitBalance;
@property (nonatomic, retain) NSString * offerKey;
@property (nonatomic, retain) NSDecimalNumber * totalPrice;

@end



