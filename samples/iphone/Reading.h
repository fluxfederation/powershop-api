//
//  Reading.h
//  iPower
//
//  Created by Roger Nesbitt on 4/01/10.
//  Copyright 2010 Powershop. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Reading :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * registerNumber;
@property (nonatomic, retain) NSDate * readAt;
@property (nonatomic, retain) NSString * readingValue;
@property (nonatomic, retain) NSString * readingType;

@end



