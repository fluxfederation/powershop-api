//
//  TopUpViewController.h
//  iPower
//
//  Created by Roger Nesbitt on 5/01/10.
//  Copyright 2010 Powershop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopUp.h"

@class APIClientRequest;

@interface TopUpViewController : UIViewController {
	UILabel *label;
	
	@private
	APIClientRequest *request;
	TopUp *topUp;
}

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) TopUp *topUp;

- (void)loadTopUpDetails;
- (IBAction)purchaseButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;

@end
