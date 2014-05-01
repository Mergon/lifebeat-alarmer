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
static NSString* VCSensorNameKey = @"CSVTSensorName";
static NSString* VCSensorDeviceKey = @"CSVTSensorDevice";
static NSString* VCHFDataKey = @"CSVTHFData";
static NSString* VCTrackingEnabledKey = @"CSVCTrackingEnabled";

static NSString* sensorDescription = @"vital_connect";

@implementation CSVitalConnectSensor {
    VitalConnectSensor* connectedSensor;
    NSString* sensorUUID;
    NSString* sensorDeviceType;
    NSMutableArray* accelerometerData;
    NSMutableArray* ecgData;
    double burstInterval;
    BOOL HFDataIsEnabled;
    NSDate* keppAliveNotificationDate;
    BOOL shouldKeepAlive;
}

- (id) init {
    self = [super init];
    if (self) {
        accelerometerData = [[NSMutableArray alloc] init];
        ecgData = [[NSMutableArray alloc] init];
        
        burstInterval = 3;
        
        [self initVitalConnect];

        NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
        if ([prefs objectForKey:VCHFDataKey] == nil) {
            //default to YES
            [self setHFData:YES];
        } else {
            [self setHFData:[prefs boolForKey:VCHFDataKey]];
        }
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
    [_vitalConnectManager storedDataStream:connectedSensor open:YES];
    int status = [_vitalConnectManager readData:kVCIObserverSensorData withCallback:processData withContext:self];
    switch (status) {
        case kVitalConnectmanagerNoError:
            break;
        default:
            NSLog(@"Error reading stream: %d", status);
            break;
    }
}

- (void) processSensorData:(NSDictionary*) data {
   NSDictionary* keySensorMapping = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"activity_raw", kVCIObserverKeyActivity,
                                      @"battery", kVCIObserverKeyBatteryLevel,
                                      @"temperature", kVCIObserverKeyBodyTemp,
                                      @"heart_rate", kVCIObserverKeyBpm,
                                      @"energy_expended", kVCIObserverKeyEnergyExpended,
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
            
            [CSSensePlatform addDataPointForSensor:sensorName displayName:displayName description:sensorDescription deviceType:sensorDeviceType deviceUUID:sensorUUID dataType:kCSDATA_TYPE_FLOAT stringValue:value timestamp:timestamp];
        }
    }
    
    //steps should be handled a bit differently
    NSNumber* steps = [data valueForKey:kVCIObserverKeyRawSteps];
    if (steps != nil) {
        NSString* stepCounterSensor = @"step_count";
        NSDictionary* value = [NSDictionary dictionaryWithObjectsAndKeys:steps, @"total", nil];
        
        [CSSensePlatform addDataPointForSensor:stepCounterSensor displayName:[self displayNameForSensor:stepCounterSensor] description:sensorDescription deviceType:sensorDeviceType deviceUUID:sensorUUID dataType:kCSDATA_TYPE_JSON jsonValue:value timestamp:timestamp];
    }
    
    //convert activity to a human readable string
    NSNumber* activity = [data valueForKey:kVCIObserverKeyActivity];
    if (activity != nil) {
        
        NSString* activityString = activityToString([activity intValue]);
        
        [CSSensePlatform addDataPointForSensor:@"activity" displayName:[self displayNameForSensor:@"activity"] description:sensorDescription deviceType:sensorDeviceType deviceUUID:sensorUUID dataType:kCSDATA_TYPE_STRING stringValue:activityString timestamp:timestamp];
        

    }
    
    //TODO:Produce warnings about available keys that are not being processed
}

- (NSString*) displayNameForSensor:(NSString*) name {
    return [[name stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString];
}

#pragma mark -
#pragma mark VitalConnectConnectionListener implementation


-(void) didConnectToSensor:(VitalConnectSensor *)sensor {
    //wahoo!  we are connected!
    NSLog(@"Connected to sensor %@", sensor.name);

    connectedSensor = sensor;
    sensorDeviceType = sensor.moduleType;
    sensorUUID = sensor.serialNumber;
    connectedSensor.highFrequencyData = HFDataIsEnabled;
    [self saveDeviceStatus:@"connected"];
    [self saveSensor];
    [self enable];
}



- (void) disconnectReceivedFromSensor:(VitalConnectSensor *)sensor {
    [self saveDeviceStatus:@"disconnected"];
}

-(void) sensorPaging:(VitalConnectSensor *)sensor {
    [self saveDeviceStatus:@"paging"];
}

-(void) didStartScanning {
    [self saveDeviceStatus:@"start_scanning"];
}

- (void) didStopScanning {
    [self saveDeviceStatus:@"stop_scanning"];
}

#pragma mark - Properties


- (void) saveSensor {
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:connectedSensor.name forKey:VCSensorNameKey];
    [prefs synchronize];
    self->shouldKeepAlive = YES;
}

- (void) forgetSensor {
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:nil forKey:VCSensorNameKey];
    [prefs synchronize];
    self->shouldKeepAlive = NO;
    [self cancelKeepAliveNotification];
}

- (void) reconnect {
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    NSString* sensorName = [prefs stringForKey:VCSensorNameKey];
    self->shouldKeepAlive = YES;
    
    if (self.trackingEnabled && sensorName != nil && _vitalConnectManager.getActiveSensor == nil) {
        [_vitalConnectManager scanAndConnectSensorForName:sensorName forSensorSource:SDK_SENSOR_DATA_SOURCE_GUID];
    }
}

- (NSString*) sensorName {
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    return [prefs stringForKey:VCSensorNameKey];
}

- (void) setTrackingEnabled:(BOOL)trackingEnabled {
    //save preference
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:trackingEnabled forKey:VCTrackingEnabledKey];
    [prefs synchronize];
    
    //disconnect the device
    if (trackingEnabled) {
        [self reconnect];
    } else if (connectedSensor != nil) {
        [self cancelKeepAliveNotification];
        [_vitalConnectManager disconnectSensor:connectedSensor];
    }
}

- (BOOL) trackingEnabled {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:VCTrackingEnabledKey])
        return [[NSUserDefaults standardUserDefaults] boolForKey:VCTrackingEnabledKey];
    else {
        //default is enabled
        return YES;
    }
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
    NSNumber* sampleInterval = CSroundedNumber(dt * 1000.0 / [burstData count] -1 , 1);
    NSString* header = [NSString stringWithFormat:@"%@,%@,%@", accXKey, accYKey, accZKey];
    
    //add data point
    NSDictionary* value = [NSDictionary dictionaryWithObjectsAndKeys:
                           values, @"values",
                           header, @"header",
                           sampleInterval, @"interval",
                           nil];

    [CSSensePlatform addDataPointForSensor:kCSSENSOR_ACCELEROMETER_BURST displayName:nil description:sensorDescription deviceType:sensorDeviceType deviceUUID:sensorUUID dataType:kCSDATA_TYPE_JSON jsonValue:value timestamp:[NSDate dateWithTimeIntervalSince1970:start]];
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
    
    [self keepAliveNotification];
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

    [CSSensePlatform addDataPointForSensor:@"ecg (burst-mode)" displayName:nil description:sensorDescription deviceType:sensorDeviceType deviceUUID:sensorUUID dataType:kCSDATA_TYPE_JSON jsonValue:value timestamp:[NSDate dateWithTimeIntervalSince1970:start]];
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
    
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:HFDataIsEnabled forKey:VCHFDataKey];
    [prefs synchronize];
}

- (BOOL) HFData {
    return HFDataIsEnabled;
}

#pragma mark - Notification
- (void) cancelKeepAliveNotification {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}
- (void) keepAliveNotification {
    if (self.trackingEnabled == NO || self->shouldKeepAlive == NO)
        return;

    if (self->keppAliveNotificationDate == nil || [self->keppAliveNotificationDate timeIntervalSinceNow] < -60) {
        self->keppAliveNotificationDate = [NSDate date];
        [self cancelKeepAliveNotification];
        UILocalNotification* notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1 * 3600];
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.alertBody = @"No connection to the HealthPatch for 1 hour. Try to regularly keep your HealthPatch within range of your phone.";
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

#pragma mark - Helper functions

- (void) saveDeviceStatus:(NSString*) status {
    NSDate* timestamp = [NSDate date];
    NSString* sensorName = @"connection";
                [CSSensePlatform addDataPointForSensor:sensorName displayName:[self displayNameForSensor:sensorName] description:@"HealthPatch" dataType:kCSDATA_TYPE_STRING stringValue:status timestamp:timestamp];
}

static NSString* activityToString(VitalConnectPosture activity) {
    switch (activity) {
        case kPostureDriving:
            return @"driving";
        case kPostureLayingDown:
            return @"lying_down";
        case kPostureLayingDownOnLeftSide:
            return @"lying_down_on_left_side";
        case kPostureLayingDownOnRightSide:
            return @"lying_down_on_right_side";
        case kPostureLayingDownProne:
            return @"lying_down_on_stomach";
        case kPostureLayingDownSupine:
            return @"lying_down_on_back";
        case kPostureLeaningBack:
            return @"leaning_back";
        case kPostureRunning:
            return @"running";
        case kPostureSitting:
            return @"sitting";
        case kPostureStanding:
            return @"standing";
        case kPostureWalking:
            return @"walking";
        case kPostureUnknown:
            return @"unknown";
    }
    return @"unknown";
}


@end
