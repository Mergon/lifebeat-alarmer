//
//  TimeActiveModule.h
//  Cortex
//
//  Created by Pim Nijdam on 7/25/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import "AIModule.h"

@interface TimeActiveModule : AIModule

- (void) reset;
- (void) setPeriodicReset:(NSDate*) date withPeriod: (NSTimeInterval) period;
- (void) clearPeriodicReset;
@end
