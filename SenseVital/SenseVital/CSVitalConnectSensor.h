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
- (void) setHFData:(BOOL) enable;
- (void) reconnect;
- (void) forgetSensor;

@property (strong, nonatomic, readonly) VitalConnectManager* vitalConnectManager;
@end
