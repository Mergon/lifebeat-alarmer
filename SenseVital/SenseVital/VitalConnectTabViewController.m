//
//  VitalConnectTabViewController.m
//  CortexDemo
//
//  Created by Pim Nijdam on 12/2/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import "VitalConnectTabViewController.h"

#import "CSVitalConnectSensor.h"
#import <Cortex/CSSensePlatform.h>

@implementation VitalConnectTabViewController {
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
    vitalConnectSensor = [[CSVitalConnectSensor alloc] init];
    
    //subscribe to sensor data
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewData:) name:kCSNewSensorDataNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) scan:(id)sender {
    [vitalConnectSensor scan];
}

- (IBAction) disconnect:(id)sender {
    [[VitalConnectManager getSharedInstance] disconnectSensor];    
}

- (IBAction) refresh:(id)sender {
    NSLog(@"Scan result: %@", [vitalConnectSensor.vitalConnectManager lastScanResult]);
}

- (IBAction) toggleHFData: (id) sender {
    if (sender == self.hfSwitch) {
        [vitalConnectSensor setHFData:self.hfSwitch.on];
    }
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
                [self.hrLabel setText:[NSString stringWithFormat:@"Heart rate: %@ bpm", hr]];
            }
        });
    } else if ([sensor isEqualToString:@"temperature"]) {
        id temp = [notification.userInfo valueForKey:@"value"];
        if ([temp isEqualToString:@"<null>"]) {
            temp = @"--";
        } else {
            temp = CSroundedNumber([temp doubleValue], 2);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                [self.skinTemperatureLabel setText:[NSString stringWithFormat:@"Skin temperature: %@ °C", temp]];
            }
        });
    } else if ([sensor isEqualToString:@"stress"]) {
        id respiration = [notification.userInfo valueForKey:@"value"];
        if ([respiration isEqualToString:@"<null>"]) {
            respiration = @"--";
        } else {
            respiration = CSroundedNumber([respiration doubleValue], 0);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                [self.respirationLabel setText:[NSString stringWithFormat:@"Stress: %@ %%", respiration]];
            }
        });
    }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Got exception %@", exception);
    }
}

static NSNumber* CSroundedNumber(double number, int decimals) {
    return [NSNumber numberWithDouble:round(number * pow(10,decimals)) / pow(10,decimals)];
}

@end
