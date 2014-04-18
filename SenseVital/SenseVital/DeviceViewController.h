//
//  DeviceViewController.h
//  SenseVital
//
//  Created by Pim Nijdam on 18/04/14.
//  Copyright (c) 2014 Sense Observation Systems BV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceViewController : UIViewController
- (IBAction) disconnect:(id)sender;

@property (nonatomic, retain) IBOutlet UILabel* modelLabel;
@property (nonatomic, retain) IBOutlet UILabel* serialLabel;
@property (nonatomic, retain) IBOutlet UILabel* batteryLabel;
@property (nonatomic, retain) IBOutlet UILabel* memoryLabel;
@property (nonatomic, retain) IBOutlet UILabel* firmwareLabel;
@end
