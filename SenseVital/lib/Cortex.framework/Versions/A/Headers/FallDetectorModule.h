//
//  FallDetectorModule.h
//  Cortex
//
//  Created by Pim Nijdam on 4/10/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import "AIModule.h"
/** FallDetect will determine a fall based on the acceleration sensor.
* For this the acceleration sensor needs to sample at least with game mode: 50Hz.
*
* By default the demo mode is disabled.
* Demo mode will only look at a free fall for 200ms and triggers a fall.
*
* By default the useInactivity is enabled.
* When useInactivity is enabled, it is only considered a fall if the user is immobile for at least 2 seconds after impact.
* This class outputs a json object with the structure {"fall":1}.
*/
@interface FallDetectorModule : AIModule

/** With isDemo enabled, a fall will be triggered when a free fall is detected for 200 ms.
 */
@property (assign) bool isDemo;

/** If enabled a fall will be triggered only when there is no movement for 2 seconds after an impact.
 */
@property (assign) bool useInactivity;

@end
