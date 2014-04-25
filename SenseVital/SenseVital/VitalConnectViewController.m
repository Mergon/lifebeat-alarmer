//
//  VitalConnectTabViewController.m
//  CortexDemo
//
//  Created by Pim Nijdam on 12/2/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import "VitalConnectViewController.h"

#import "CSVitalConnectSensor.h"
#import <Cortex/CSSensePlatform.h>
#import "Factory.h"

static NSString* kVCStatusTrackingDisabled = @"Tracking disabled";
static NSString* kVCStatusScanning = @"Scanning...";
static NSString* kVCStatusConnecting = @"Connecting...";
static NSString* kVCStatusNotOnBody = @"Not on body";
static NSString* kVCStatusConnected = @"Connected";
static NSString* kVCStatusDisconnected = @"Disconnected";


@implementation VitalConnectViewController {
    CSVitalConnectSensor* vitalConnectSensor;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    vitalConnectSensor = [Factory sharedFactory].csVitalConnectSensor;
    
    NSString* pathToImageFile = [[NSBundle mainBundle] pathForResource:@"Background" ofType:@"png"];
    UIImage* bgImage = [UIImage imageWithContentsOfFile:pathToImageFile];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];

    //make navigation bar transparant
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
}

- (void) viewWillAppear:(BOOL)animated {
    //subscribe to sensor data
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewData:) name:kCSNewSensorDataNotification object:nil];
    //subscribe to notifications to update the device state
    if ([VitalConnectManager getSharedInstance].getActiveSensor != nil) {
        [self updateStatusWith:kVCStatusConnected connected:YES];
    } else {
        [self updateStatusWith:kVCStatusScanning connected:NO];
    }
    [[VitalConnectManager getSharedInstance] addListener:self];
}

- (void) viewWillDisappear:(BOOL)animated {
    [[VitalConnectManager getSharedInstance] removeListener:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setNoValues {
    NSString* noValue = @"--";
    [self.stepsLabel setText:noValue];
    [self.respirationLabel setText:noValue];
    [self.stressLevelLabel setText:noValue];
}


- (void) updateStatusWith:(NSString*) newStatus connected:(BOOL) connected{
    NSString* status = @"Unknown";
    if (NO == [Factory sharedFactory].csVitalConnectSensor.trackingEnabled) {
        status = kVCStatusTrackingDisabled;
    } else {
        status = newStatus;
    }
    
    if (NO == connected)
        [self setNoValues];

    [self.status setText:status];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) onNewData:(NSNotification*)notification {
    @try {
    NSString* sensor = notification.object;
    if ([sensor isEqualToString:@"heart_rate"]) {
        id hr = [notification.userInfo valueForKey:@"value"];
        if ([hr isEqualToString:@"<null>"]) {
            hr = @"--";
        } else {
            hr = CSroundedNumber([hr doubleValue], 0);
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                [self.hrLabel setText:[NSString stringWithFormat:@"%@", hr]];
            }
        });
    } else if ([sensor isEqualToString:@"step_count"]) {
        id steps = [[notification.userInfo valueForKey:@"value"] valueForKey:@"total"];
        steps = CSroundedNumber([steps doubleValue], 2);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                [self.stepsLabel setText:[NSString stringWithFormat:@"%@", steps]];
            }
        });
    } else if ([sensor isEqualToString:@"respiration"]) {
        id respiration = [notification.userInfo valueForKey:@"value"];
        if ([respiration isEqualToString:@"<null>"]) {
            respiration = @"--";
        } else {
            respiration = CSroundedNumber([respiration doubleValue], 0);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                [self.respirationLabel setText:[NSString stringWithFormat:@"%@ breaths / min", respiration]];
            }
        });
    } else if ([sensor isEqualToString:@"stress"]) {
        id stress = [notification.userInfo valueForKey:@"value"];
        if ([stress isEqualToString:@"<null>"]) {
            stress = @"--";
        } else {
            stress = CSroundedNumber([stress doubleValue], 0);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                [self.stressLevelLabel setText:[NSString stringWithFormat:@"%@%%", stress]];
            }
        });
    }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Got exception %@", exception);
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return orientation == UIInterfaceOrientationPortrait;
}

static NSNumber* CSroundedNumber(double number, int decimals) {
    return [NSNumber numberWithDouble:round(number * pow(10,decimals)) / pow(10,decimals)];
}

#pragma mark - VitalConnectConnectionListener implementation
-(void) deviceAntennaStatusChange:(VCDeviceAntennaState)state {
    NSLog(@"deviceAntennaStatusChange:%i", state);
}

-(void) sensorPairing:(VitalConnectSensor *)sensor {
    NSLog(@"sensorPairing:");
    [self updateStatusWith:kVCStatusScanning connected:NO];
}

-(void) sensorPaging:(VitalConnectSensor *)sensor {
    NSLog(@"sensorPaging");
    [self updateStatusWith:kVCStatusScanning connected:NO];
}

-(void) sensorAuthenticating:(VitalConnectSensor *)sensor {
    NSLog(@"sensorAuthenticating");
    [self updateStatusWith:kVCStatusConnecting connected:NO];
}

-(void) sensorSecuring:(VitalConnectSensor *)sensor {
    NSLog(@"sensorSecuring");
    [self updateStatusWith:kVCStatusConnecting connected:NO];
    
}

-(void) didConnectToSensor:(VitalConnectSensor *)sensor {
    NSLog(@"didConnectToSensor");
    [self updateStatusWith:kVCStatusConnected connected:YES];
}

-(void) didNotConnectToSensorWithUuid:(NSString *)Uuid {
    NSLog(@"didNotConnectToSensorWithUuid");
    [self updateStatusWith:kVCStatusDisconnected connected:NO];
}

-(void) disconnectReceivedFromSensor:(VitalConnectSensor *)sensor {
    NSLog(@"disconnectReceivedFromSensor");
    [self updateStatusWith:kVCStatusDisconnected connected:NO];
}


-(void) didStartScanning {
    NSLog(@"didStartScanningdidStartScanning");
    [self updateStatusWith:kVCStatusScanning connected:NO];
}

@end
