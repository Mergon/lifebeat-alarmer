//
//  VitalConnectTabViewController.h
//  CortexDemo
//
//  Created by Pim Nijdam on 12/2/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VitalConnectTabViewController : UIViewController


@property (nonatomic, retain) IBOutlet UILabel* hrLabel;
@property (nonatomic, retain) IBOutlet UILabel* respirationLabel;
@property (nonatomic, retain) IBOutlet UILabel* skinTemperatureLabel;

@property (nonatomic, retain) IBOutlet UILabel* status;

@end
