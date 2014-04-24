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
#import "Factory.h"

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
    vitalConnectSensor = [Factory sharedFactory].csVitalConnectSensor;
    
    //subscribe to sensor data
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewData:) name:kCSNewSensorDataNotification object:nil];
    
    
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
    //[self.navigationController setNavigationBarHidden:YES animated:NO];
    [self updateStatus];
}

- (void) viewDidDisappear:(BOOL)animated {
  //[self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void) updateStatus {
    NSString* status = @"Unknown";
    //Is a sensor connected
    
    //Is the patch active?
    VitalConnectSensor* sensor = [VitalConnectManager getSharedInstance].getActiveSensor;
    if (sensor == nil) {
        status = @"Not connected.";
    } else {
        switch (sensor.patchStatus) {
            case kPatchStatusApplied:
                status = @"Connected and Wearing";
                break;
            case kPatchStatusPoorConnection:
                status = @"Poor connection";
                break;
            case kPatchStatusRemoved:
                status = @"Connected, but not wearing";
                break;
            case kPatchStatusUnknown:
                status = @"Unknown";
                break;
        }
    }
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

@end
