//
//  Factory.h
//  SenseVital
//
//  Created by Pim Nijdam on 18/04/14.
//  Copyright (c) 2014 Sense Observation Systems BV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSVitalConnectSensor.h"

@interface Factory : NSObject

+ (Factory*) sharedFactory;

@property (strong, nonatomic, readonly) CSVitalConnectSensor* csVitalConnectSensor;

@end
