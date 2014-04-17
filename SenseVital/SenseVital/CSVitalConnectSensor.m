//
//  CSVitalConnectSensor.m
//  CortexDemo
//
//  Created by Pim Nijdam on 12/2/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import "CSVitalConnectSensor.h"
#import "VitalConnect.h"
#import "SDK.h"
#import <Cortex/CSSensePlatform.h>

static const NSString* accXKey = @"x";
static const NSString* accYKey = @"y";
static const NSString* accZKey = @"z";
static const NSString* heartValueKey = @"heart value";

@implementation CSVitalConnectSensor {
    VitalConnectSensor* connectedSensor;
    NSString* sensorUUID;
    NSString* sensorDeviceType;
    NSMutableArray* accelerometerData;
    NSMutableArray* ecgData;
    double burstInterval;
    BOOL HFDataIsEnabled;
}

- (id) init {
    self = [super init];
    if (self) {
        accelerometerData = [[NSMutableArray alloc] init];
        ecgData = [[NSMutableArray alloc] init];
        
        burstInterval = 3;
        
        [self initVitalConnect];
    }
    return self;
}

- (void) initVitalConnect {
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *rootFileDir = [dirPaths objectAtIndex:0];
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    rootFileDir = [rootFileDir stringByAppendingPathComponent:[bundleInfo objectForKey:@"CFBundleDisplayName"]];
    
    _vitalConnectManager = [VitalConnectManager getSharedInstance];

    [_vitalConnectManager addListener:self withNotificationsOnMainThread:YES];
}

- (void) enable {
    int status = [_vitalConnectManager readData:kVCIObserverSensorData withCallback:processData withContext:self];
    switch (status) {
        case kVitalConnectmanagerNoError:
            NSLog(@"Error reading stream: %d", status);
            break;
        default:
            NSLog(@"Error reading stream: %d", status);
            break;
    }
}

- (void) processSensorData:(NSDictionary*) data {
   NSDictionary* keySensorMapping = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"activity", kVCIObserverKeyActivity,
                                      @"battery", kVCIObserverKeyBatteryLevel,
                                      @"temperature", kVCIObserverKeyBodyTemp,
                                      @"heart_rate", kVCIObserverKeyBpm,
                                      @"energy_expenditure_rate", kVCIObserverKeyEnergyExpendedRate,
                                      @"impedance", kVCIObserverKeyImpedance,
                                      @"respiration", kVCIObserverKeyRespiration,
                                      @"rr_interval", kVCIObserverKeyRRInterval,
                                      @"stress", kVCIObserverKeyStress,
                                      @"memory_level", kVCIObserverKeyMemoryLevel,
                                      nil];
    NSTimeInterval sinceEpoch = [[data valueForKey:kVCIObserverKeyTime] doubleValue];
    NSDate* timestamp = [NSDate dateWithTimeIntervalSince1970:sinceEpoch];

    for (NSString* key in keySensorMapping) {
        id dataValue = [data valueForKey:key];
        if (dataValue != nil) {
            
            NSString* value = [NSString stringWithFormat:@"%@", dataValue];
            if ([value isEqualToString:@"<null>"]) {
                continue;
            }

            NSString* sensorName = [keySensorMapping valueForKey:key];
            NSString* displayName = [self displayNameForSensor:sensorName];
            
            [CSSensePlatform addDataPointForSensor:sensorName displayName:displayName description:sensorName deviceType:sensorDeviceType deviceUUID:sensorUUID dataType:kCSDATA_TYPE_FLOAT stringValue:value timestamp:timestamp];
        }
    }
    
    //steps should be handled a bit differently
    NSNumber* steps = [data valueForKey:kVCIObserverKeyRawSteps];
    if (steps != nil) {
        NSString* stepCounterSensor = @"step_count";
        NSDictionary* value = [NSDictionary dictionaryWithObjectsAndKeys:steps, @"total", nil];
        
        [CSSensePlatform addDataPointForSensor:stepCounterSensor displayName:[self displayNameForSensor:stepCounterSensor] description:nil deviceType:sensorDeviceType deviceUUID:sensorUUID dataType:kCSDATA_TYPE_JSON jsonValue:value timestamp:timestamp];
    }
}

- (NSString*) displayNameForSensor:(NSString*) name {
    return [[name stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString];
}

#pragma mark -
#pragma mark VitalConnectConnectionListener implementation

-(void) didSeeNewSensor:(VitalConnectSensor *)sensor {
}

-(void) didConnectToSensor:(VitalConnectSensor *)sensor {
    //wahoo!  we are connected!
    NSLog(@"Connected to sensor %@", sensor.name);

    connectedSensor = sensor;
    sensorDeviceType = sensor.moduleType;
    sensorUUID = sensor.serialNumber;
    connectedSensor.highFrequencyData = HFDataIsEnabled;
    
    [self enable];
}

- (void) scan {
    [_vitalConnectManager stopScan];
    [_vitalConnectManager startScan];
}

#pragma mark - Process data

- (void) processAccelerometerBurst:(NSArray*) burstData {
    //Scale values to convert to approx m/s^2 units.
    const double scalingDiv = 12.8;
    //create array with all values
    NSMutableArray* values = [[NSMutableArray alloc] initWithCapacity:burstData.count];
    for (NSDictionary* sample in burstData) {
        //NSNumber* timestamp = [sample valueForKey:kVCIObserverKeyTime];
        NSNumber* x = CSroundedNumber([[sample valueForKey:kVCIObserverKeyRawXValue] doubleValue] / scalingDiv, 3);
        NSNumber* y = CSroundedNumber([[sample valueForKey:kVCIObserverKeyRawYValue] doubleValue] / scalingDiv, 3);
        NSNumber* z = CSroundedNumber([[sample valueForKey:kVCIObserverKeyRawZValue] doubleValue] / scalingDiv, 3);

        [values addObject:[NSArray arrayWithObjects:x,y,z, nil]];
    }

    //create header
    NSTimeInterval start = [[[burstData objectAtIndex:0] valueForKey:kVCIObserverKeyTime] doubleValue];
    NSTimeInterval end = [[[burstData lastObject] valueForKey:kVCIObserverKeyTime] doubleValue];
    NSTimeInterval dt = end - start;
    NSNumber* sampleInterval = CSroundedNumber(dt * 1000.0 / [burstData count], 1);
    NSString* header = [NSString stringWithFormat:@"%@,%@,%@", accXKey, accYKey, accZKey];
    
    //add data point
    NSDictionary* value = [NSDictionary dictionaryWithObjectsAndKeys:
                           values, @"values",
                           header, @"header",
                           sampleInterval, @"interval",
                           nil];
    
    [CSSensePlatform addDataPointForSensor:kCSSENSOR_ACCELEROMETER_BURST displayName:nil description:nil deviceType:sensorDeviceType deviceUUID:sensorUUID dataType:kCSDATA_TYPE_JSON jsonValue:value timestamp:[NSDate dateWithTimeIntervalSince1970:start]];
}

typedef void (^dataCallback)(NSArray* data);
- (void) addSample:(NSDictionary*) sample toArray:(NSMutableArray*) array withCallbackOnFull:(dataCallback) callback{
    if ([array count] > 0) {
        NSTimeInterval start = [[[array objectAtIndex:0] valueForKey:kVCIObserverKeyTime] doubleValue];
        NSTimeInterval timestamp = [[sample valueForKey:kVCIObserverKeyTime] doubleValue];
        if (timestamp - start > burstInterval) {
            //process the data
            //TODO: use a separate gcd queue
            callback(array);
            //reset this array
            [array removeAllObjects];
        }
    }

    [array addObject:sample];
}

- (void) processECGBurst:(NSArray*) burstData {
    //create array with all values
    NSMutableArray* values = [[NSMutableArray alloc] initWithCapacity:burstData.count];
    for (NSDictionary* sample in burstData) {
        //NSNumber* timestamp = [sample valueForKey:kVCIObserverKeyTime];
        NSNumber* hrValue = [sample valueForKey:kVCIObserverKeyRawHeartValue];
        if (hrValue == nil) {
            NSLog(@"Error, no hr value");
        } else {
            [values addObject:hrValue];
        }
    }
    
    //create header
    NSTimeInterval start = [[[burstData objectAtIndex:0] valueForKey:kVCIObserverKeyTime] doubleValue];
    NSTimeInterval end = [[[burstData lastObject] valueForKey:kVCIObserverKeyTime] doubleValue];
    NSTimeInterval dt = end - start;
    NSNumber* sampleInterval = CSroundedNumber(dt * 1000.0 / [burstData count], 1);
    NSString* header = [NSString stringWithFormat:@"%@", heartValueKey];
    
    //add data point
    NSDictionary* value = [NSDictionary dictionaryWithObjectsAndKeys:
                           values, @"values",
                           header, @"header",
                           sampleInterval, @"interval",
                           nil];
    
    [CSSensePlatform addDataPointForSensor:@"ecg (burst-mode)" displayName:nil description:nil deviceType:sensorDeviceType deviceUUID:sensorUUID dataType:kCSDATA_TYPE_JSON jsonValue:value timestamp:[NSDate dateWithTimeIntervalSince1970:start]];
}

static BOOL processData(id contextObject, NSArray* samples, Boolean done, int error)
{
    CSVitalConnectSensor* selfRef = (CSVitalConnectSensor*) contextObject;
    if (samples == nil)
    {
        return NO;
    }
    for (int i = 0; i < [samples count]; i++) {
        NSDictionary *dict = [samples objectAtIndex:i];
        //process low frequency data
        [selfRef processSensorData:dict];
        
        //process ECG data
        if ([dict valueForKey:kVCIObserverKeyRawHeartValue] != nil) {
            dataCallback callback = ^(NSArray* data) {
                [selfRef processECGBurst:data];
            };
            [selfRef addSample:dict toArray:selfRef->ecgData withCallbackOnFull:callback];
        }
        
        //process accelerometer data
        if ([dict valueForKey:kVCIObserverKeyRawXValue] != nil) {
            dataCallback callback = ^(NSArray* data) {
                [selfRef processAccelerometerBurst:data];
            };
            [selfRef addSample:dict toArray:selfRef->accelerometerData withCallbackOnFull:callback];
        }
    }
    return YES;
}

static NSNumber* CSroundedNumber(double number, int decimals) {
    return [NSNumber numberWithDouble:round(number * pow(10,decimals)) / pow(10,decimals)];
}

- (void) setHFData:(BOOL) enable {
    HFDataIsEnabled = enable;
    [_vitalConnectManager enableHighFrequencyData:enable];
    if (connectedSensor != nil) {
        connectedSensor.highFrequencyData = enable;
    }
}

@end