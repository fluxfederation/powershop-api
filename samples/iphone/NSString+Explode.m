//
//  NSString+Explode.m
//  iPower
//
//  Created by Roger Nesbitt on 02/01/2010.
//  Copyright 2010 Powershop. All rights reserved.
//

#import "NSString+Explode.h"


@implementation NSString (Explode)

- (NSMutableDictionary *)explodeToDictionaryInnerGlue:(NSString *)innerGlue outterGlue:(NSString *)outterGlue {
    // Explode based on outter glue
    NSArray *firstExplode = [self componentsSeparatedByString:outterGlue];
    NSArray *secondExplode;
	
    // Explode based on inner glue
    NSInteger count = [firstExplode count];
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        secondExplode = [(NSString *)[firstExplode objectAtIndex:i] componentsSeparatedByString:innerGlue];
        if ([secondExplode count] == 2) {
			[returnDictionary setObject:[secondExplode objectAtIndex:1] forKey:[secondExplode objectAtIndex:0]];
        }
    }
	
    return returnDictionary;
}

@end
