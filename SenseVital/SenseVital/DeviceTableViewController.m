//
//  VCDeviceTable.m
//  CortexDemo
//
//  Created by Pim Nijdam on 12/3/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import "DeviceTableViewController.h"
#import "VitalConnect.h"
#import "SDK.h"

@implementation DeviceTableViewController {
    BOOL isScanning;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        isScanning = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[VitalConnectManager getSharedInstance] addListener:self withNotificationsOnMainThread:YES];
    if ([self isViewLoaded]) {
        [self.tableView reloadData];
    }
    
    self.navigationController.title = @"Select device";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    isScanning = YES;
    [self.tableView reloadData];
    [[VitalConnectManager getSharedInstance] startScan];
}

- (void) viewDidDisappear:(BOOL)animated {
    if (isScanning) {
        [[VitalConnectManager getSharedInstance] stopScan];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSUInteger n = [[[VitalConnectManager getSharedInstance] lastScanResult] count];
    return n;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VitalConnectManager* vcManager = [VitalConnectManager getSharedInstance];
    VitalConnectSensor *sensor = nil;
    static NSString *CellIdentifier = @"SensorTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    if ([vcManager lastScanResult].count > indexPath.row)
    {
        sensor = [[vcManager lastScanResult] objectAtIndex:indexPath.row];
        cell.textLabel.text = sensor.name;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VitalConnectSensor *sensor = [[[VitalConnectManager getSharedInstance] lastScanResult] objectAtIndex:indexPath.row];
    [self connectToSensor:sensor];

}

- (void) connectToSensor:(VitalConnectSensor*) sensor {
    NSLog(@"Connecting to sensor %@.", sensor.name);
    isScanning = NO;
    [[VitalConnectManager getSharedInstance] connectSensor:sensor forSensorSource:SDK_SENSOR_DATA_SOURCE_GUID];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - VitalConnectSensorListener
-(void) didSeeNewSensor:(VitalConnectSensor *)sensor
{
    NSLog(@"New sensor seen.");
    if ([self isViewLoaded]) {
        [self.tableView reloadData];
    }
}

-(void) didConnectToSensor:(VitalConnectSensor *)sensor
{
     NSLog(@"Connected to %@.", sensor.name);
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) didNotConnectToSensorWithUuid:(NSString *)Uuid
{
    NSLog(@"Not connected to %@.", Uuid);
    
}

-(void) disconnectReceivedFromSensor:(VitalConnectSensor *)sensor
{
    NSLog(@"Disconnected from %@.", sensor.name);
    [self.tableView reloadData];
    
}

-(void) sensorPairing:(VitalConnectSensor *)sensor {
    NSLog(@"Pairing with %@.", sensor.name);
}

-(void) sensorAuthenticating:(VitalConnectSensor *)sensor {
    NSLog(@"Authenticating with %@.", sensor.name);
}


-(void) sensorSecuring:(VitalConnectSensor *)sensor {
    NSLog(@"Securing sensor %@.", sensor.name);
}

@end
