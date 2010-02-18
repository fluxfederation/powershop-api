//
//  NSString+Explode.h
//  iPower
//
//  Created by Roger Nesbitt on 02/01/2010.
//  Copyright 2010 Powershop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Explode)
- (NSMutableDictionary *)explodeToDictionaryInnerGlue:(NSString *)innerGlue outterGlue:(NSString *)outterGlue;
@end
