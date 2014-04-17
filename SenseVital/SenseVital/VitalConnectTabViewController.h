//
//  VitalConnectTabViewController.h
//  CortexDemo
//
//  Created by Pim Nijdam on 12/2/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VitalConnectTabViewController : UIViewController
- (IBAction) scan:(id)sender;
- (IBAction) disconnect:(id)sender;
- (IBAction) refresh:(id)sender;

- (IBAction) toggleHFData: (id) sender;


@property (nonatomic, retain) IBOutlet UISwitch* hfSwitch;
@property (nonatomic, retain) IBOutlet UILabel* hrLabel;
@property (nonatomic, retain) IBOutlet UILabel* respirationLabel;
@property (nonatomic, retain) IBOutlet UILabel* skinTemperatureLabel;

@end
