//
//  CSVitalConnectSensor.h
//  CortexDemo
//
//  Created by Pim Nijdam on 12/2/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VitalConnect.h"

@interface CSVitalConnectSensor : NSObject <VitalConnectConnectionListener>
- (void) reconnect;
- (void) forgetSensor;

- (NSString*) sensorName;

@property (strong, nonatomic, readonly) VitalConnectManager* vitalConnectManager;
@property BOOL HFData;
@property BOOL trackingEnabled;
@end
