//
//  DeviceViewController.m
//  SenseVital
//
//  Created by Pim Nijdam on 18/04/14.
//  Copyright (c) 2014 Sense Observation Systems BV. All rights reserved.
//

#import "DeviceViewController.h"
#import "VitalConnect.h"
#import "Factory.h"

@interface DeviceViewController ()

@end

@implementation DeviceViewController

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
    
    //NSString* pathToImageFile = [[NSBundle mainBundle] pathForResource:@"Background" ofType:@"png"];
    //UIImage* bgImage = [UIImage imageWithContentsOfFile:pathToImageFile];
    //[self.view setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateValues];
}

- (void) updateValues {
    VitalConnectSensor* sensor = [[VitalConnectManager getSharedInstance] getActiveSensor];
    NSString* identifier = [[Factory sharedFactory].csVitalConnectSensor sensorName];
    [self.modelLabel setText:identifier];
    
    if (sensor != nil) {
        NSString* serial = [NSString stringWithFormat:@"UUID: %@", sensor.serialNumber];
        NSString* battery = [NSString stringWithFormat:@"Battery: %@%%", sensor.batteryLevel];
        NSString* freeMem = [NSString stringWithFormat:@"Memory used: %i%%", 100 - [sensor.freeMemory intValue]];
        NSString* firmware = [NSString stringWithFormat:@"Firmware: %@", sensor.firmwareVersion];
        [self.serialLabel setText:serial];
        [self.batteryLabel setText:battery];
        [self.memoryLabel setText:freeMem];
        [self.firmwareLabel setText:firmware];
    } else {
        [self.serialLabel setText:@"Device not connected"];
        [self.batteryLabel setText:@""];
        [self.memoryLabel setText:@""];
        [self.firmwareLabel setText:@""];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) disconnect:(id)sender {
    [[Factory sharedFactory].csVitalConnectSensor forgetSensor];
    
    VitalConnectSensor* sensor = [[VitalConnectManager getSharedInstance] getActiveSensor];
    if (sensor)
        [[VitalConnectManager getSharedInstance] disconnectSensor:sensor];
    
    [self performSegueWithIdentifier:@"Disconnected" sender:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

@end
