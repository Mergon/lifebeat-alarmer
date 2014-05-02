//
//  StepCounter.h
//  Cortex
//
//  Created by Pim Nijdam on 7/1/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import "AIModule.h"

@interface StepCounterModule : AIModule

- (void) resetStepCounter;
- (void) setSensitivity:(double)sensitivity;
- (double) defaultSensitivity;
- (double) getSensitivity;
@end
