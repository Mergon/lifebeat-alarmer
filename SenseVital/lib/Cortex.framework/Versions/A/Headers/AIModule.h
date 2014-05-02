//
//  FilteredPosition.h
//  Intellisense
//
//  Created by Pim Nijdam on 3/27/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import <Foundation/Foundation.h>
//TODO: use CSDynamicSensor so an AIModule is just like another sensor, you can enable/disable it and set preferences. However, we need to know the sensor details (name, data type etc) when instantiating, so this has to wait until AI Modules can provide this information
//#import "SensePlatform/CSDynamicSensor.h"

/** Base class to create AIModule subclasses.
 * This class contains logic to put inputs into a module and save the output to a sensor. It also takes care of all data marshalling.
 */
@interface AIModule : NSObject {
    
}

- (void) setOutputSensor:(NSString*) sensorName withDescription:(NSString*) description withDataType:(NSString*) dataType;
- (void) addInputSensor:(NSString*) sensor as:(NSString*) alias;
- (void) addInputSensor:(NSString*) sensor;
- (void) save;
- (void) load;

- (NSString*) name;

@property (assign) bool saveToSensor;
@property (assign) bool saveStateEachTick;
@property (assign) bool verbose;
@end
