//
//  PropertyViewController.h
//  iPower
//
//  Created by Roger Nesbitt on 03/01/2010.
//  Copyright 2010 Powershop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Property.h"


@interface PropertyViewController : UIViewController {
	UILabel *address;
	UILabel *icpNumber;
	UILabel *unitBalance;
	UILabel *dailyConsumption;
	UILabel *daysRemaining;
	UILabel *daysRemainingDescription;
}

@property (nonatomic, retain) IBOutlet UILabel *address;
@property (nonatomic, retain) IBOutlet UILabel *icpNumber;
@property (nonatomic, retain) IBOutlet UILabel *unitBalance;
@property (nonatomic, retain) IBOutlet UILabel *dailyConsumption;
@property (nonatomic, retain) IBOutlet UILabel *daysRemaining;
@property (nonatomic, retain) IBOutlet UILabel *daysRemainingDescription;

@end
