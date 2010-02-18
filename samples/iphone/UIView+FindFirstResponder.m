//
//  UIView+FindFirstResponder.m
//  Powershop
//
//  Created by Roger Nesbitt on 02/02/2010.
//  Copyright 2010 Powershop. All rights reserved.
//

#import "UIView+FindFirstResponder.h"


@implementation UIView (FindFirstResponder)

- (UIView *)findFirstResponder
{
    if (self.isFirstResponder) {        
        return self;     
    }
	
    for (UIView *subView in self.subviews) {
        UIView *firstResponder = [subView findFirstResponder];
		
        if (firstResponder != nil) {
            return firstResponder;
        }
    }
	
    return nil;
}

@end
