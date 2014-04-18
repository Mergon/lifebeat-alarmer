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
    // Do any additional setup after loading the view.
    [self updateValues];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidLoad];
    [self updateValues];
}

- (void) updateValues {
    VitalConnectSensor* sensor = [[VitalConnectManager getSharedInstance] getActiveSensor];
    NSString* identifier = [NSString stringWithFormat:@"%@", sensor.name];
    NSString* serial = [NSString stringWithFormat:@"UUID: %@", sensor.serialNumber];
    NSString* battery = [NSString stringWithFormat:@"Battery: %@%%", sensor.batteryLevel];
    NSString* freeMem = [NSString stringWithFormat:@"Memory free: %@%%", sensor.freeMemory];
    NSString* firmware = [NSString stringWithFormat:@"Firmware: %@", sensor.firmwareVersion];
    [self.modelLabel setText:identifier];
    [self.serialLabel setText:serial];
    [self.batteryLabel setText:battery];
    [self.memoryLabel setText:freeMem];
    [self.firmwareLabel setText:firmware];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) disconnect:(id)sender {
    [[Factory sharedFactory].csVitalConnectSensor forgetSensor];
    
    VitalConnectSensor* sensor = [[VitalConnectManager getSharedInstance] getActiveSensor];
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

@end
