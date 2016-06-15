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
    NSMutableDictionary* lastValues;
    NSTimeInterval rrInterval;
    BOOL isBeating;
    NSDate* lastRRDate;
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
    
    lastValues = [[NSMutableDictionary alloc] init];

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
    
    
    //make navigation bar transparant
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage new]
    //                                              forBarMetrics:UIBarMetricsDefault];
    //self.navigationController.navigationBar.shadowImage = [UIImage new];
    //self.navigationController.navigationBar.translucent = YES;
    //self.navigationController.view.backgroundColor = [UIColor clearColor];
}

- (void) viewWillDisappear:(BOOL)animated {
    [[VitalConnectManager getSharedInstance] removeListener:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//Only support Portrait
- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}



- (void) setNoValues {
    NSString* noValue = @"--";
    [self.hrLabel setText:noValue];
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

- (void) beatAnimation {
    isBeating = YES;
    NSLog(@"dt = %.3f", [lastRRDate timeIntervalSinceNow]);
    if (lastRRDate == nil || [lastRRDate timeIntervalSinceNow] < -8) {
        isBeating = NO;
        return;
    }
    
    //one third up, 2 thirds 
    NSTimeInterval growDuration = 0.2/3;
    NSTimeInterval shrinkDuration = 0.2/3 * 2;
    // instantaneously make the image view small (scaled to 1% of its actual size)
    [UIView animateWithDuration:growDuration delay:0 options:0 animations:^{
        // scale up
        self.hrLabel.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:shrinkDuration delay:0 options:0 animations:^{
            //scale down
             self.hrLabel.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
        }];
    }];

    [self performSelector:@selector(beatAnimation) withObject:nil afterDelay:rrInterval];
}

- (void) onNewData:(NSNotification*)notification {
    @try {
        
        NSString* sensor = notification.object;
        NSTimeInterval dateUnix = [[notification.userInfo valueForKey:@"date"] doubleValue];
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:dateUnix];
        NSDate* previousDate = [lastValues valueForKey:sensor];
        NSTimeInterval dt = [date timeIntervalSinceDate:previousDate];
        
        if ((previousDate != nil && dt < 0) || [date timeIntervalSinceNow] < -60) {
            //ignore earlier data, so as only show the real-time values and not the buffered data that is being synchronized
            //also ignore data more than a minute old, to filter if the first value we get is a buffered data point
            return;
        }
        
        [lastValues setValue:date forKey:sensor];
        
    if ([sensor isEqualToString:@"heart_rate"]) {
        id hr = [notification.userInfo valueForKey:@"value"];
        if ([hr isEqualToString:@"<null>"]) {
            hr = @"--";
        } else {
            hr = CSroundedNumber([hr doubleValue], 0);
            
            // MERRY HACK: Detect heart rate here.
            NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
            if ([prefs boolForKey:@"MerryHackThresholdEnabled"] == true) {
                void (^alarmSent)() = ^(){
                    // Show confirmation
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Alarm sent!"
                                                                                   message:@"An alarm has been sent."
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                };
                
                NSInteger lowerThreshold = [prefs integerForKey:@"MerryHackLowerThreshold"];
                NSInteger upperThreshold = [prefs integerForKey:@"MerryHackUpperThreshold"];
                
                if ([hr integerValue] < lowerThreshold || [hr integerValue] > upperThreshold) {
                    [SendAlarm sendAlarmWithCompletionHandler:alarmSent];
                    [prefs setBool:false forKey:@"MerryHackThresholdEnabled"];
                }
            }
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
    } else if ([sensor isEqualToString:@"rr_interval"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                rrInterval = [[notification.userInfo valueForKey:@"value"] doubleValue] / 1000;
                lastRRDate = date;
                if (NO == isBeating)
                    [self beatAnimation];
            }});
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
