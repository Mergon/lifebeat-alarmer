//
//  AppDelegate.h
//  SenseVital
//
//  Created by Pim Nijdam on 17/04/14.
//  Copyright (c) 2014 Sense Observation Systems BV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VitalConnect.h"
#import "CSVitalConnectSensor.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
}

@property (strong, nonatomic) UIWindow *window;
@property VitalConnectManager* vitalConnectManager;
@property CSVitalConnectSensor* csVitalConnectSensor;

@end
