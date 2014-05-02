//
//  CarryDevice.h
//  Cortex
//
//  Created by Pim Nijdam on 4/9/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import "AIModule.h"

/** Wrapper for the CarryDevice AI Module. This modules outputs to sensor "CarryDevice" wether the user is carrying the device, and some extra information.
 */
@interface CarryDeviceModule : AIModule

/**
 * Set the interval
 *
 * This method sets the interval at which to do the computation whether the device is carried.
 * The default is 60 seconds.
 * Setting the interval will reset the time window
 *
 * @param interval in seconds
 */
- (void) setInterval: (double) interval;

/**
 * Set the time window
 *
 * This method sets the time window used for auto calibrating the accelerometer.
 * The default value is 10% larger than the interval.
 * Setting the interval will reset the time window
 *
 * @param time_window double The time window used for calibration
 */
- (void) setTimeWindow: (double) time_window;

/**
 * Set the event threshold
 *
 * This method sets the threshold for when a change in sensor data is seen as noise or as an event.
 *
 * The default 0.05 = 5% higher then noise
 *
 * @param threshold double threshold value between 0-1
 */
- (void) setEventThreshold: (double) threshold;

/**
 * Re-calibrate the module
 *
 * This method removes the learned lowest variance for acceleration sensor.
 *
 */
- (void) reCalibrate;

@end
