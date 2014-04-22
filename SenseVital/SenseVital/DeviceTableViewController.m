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
    NSArray* lastResults;
    UIActivityIndicatorView* activityIndicatorView;
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
    activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicatorView setColor:[UIColor blackColor]];
    activityIndicatorView.hidesWhenStopped = YES;
    [self.view addSubview:activityIndicatorView];
    activityIndicatorView.center = self.view.center;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    isScanning = YES;
    [[VitalConnectManager getSharedInstance] startScan];
    //Whoa, why do this twice? Well, it seems sometimes bluetooth is only turned on the first time we start the scan. So te be sure we just invoke it twice with a small delay.
    [[VitalConnectManager getSharedInstance] performSelector:@selector(startScan) withObject:nil afterDelay:0.5];
    [self.tableView reloadData];
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
    NSUInteger n = [lastResults count];
    return n;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VitalConnectSensor *sensor = nil;
    static NSString *CellIdentifier = @"SensorTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    if (lastResults.count > indexPath.row)
    {
        sensor = [lastResults objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"HealthPatch %@", sensor.name];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VitalConnectSensor *sensor = [lastResults objectAtIndex:indexPath.row];
    [self connectToSensor:sensor];

}

- (void) connectToSensor:(VitalConnectSensor*) sensor {
    NSLog(@"Connecting to sensor %@.", sensor.name);
    isScanning = NO;
    [[VitalConnectManager getSharedInstance] connectSensor:sensor forSensorSource:SDK_SENSOR_DATA_SOURCE_GUID];
    [activityIndicatorView startAnimating];
    [self.view bringSubviewToFront:activityIndicatorView];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return orientation == UIInterfaceOrientationPortrait;
}

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
    lastResults = [[VitalConnectManager getSharedInstance] lastScanResult];
    if ([self isViewLoaded]) {
        [self.tableView reloadData];
    }
}

-(void) didConnectToSensor:(VitalConnectSensor *)sensor
{
    [activityIndicatorView stopAnimating];
    NSLog(@"Connected to %@.", sensor.name);
   [self performSegueWithIdentifier:@"Connected" sender:self];
}

-(void) didNotConnectToSensorWithUuid:(NSString *)Uuid
{
    NSLog(@"Not connected to %@.", Uuid);
    [activityIndicatorView stopAnimating];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Connection failed" message:@"Sorry, couldn't establish a connection to the HealthPatch." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
    
}

-(void) disconnectReceivedFromSensor:(VitalConnectSensor *)sensor
{
    NSLog(@"Disconnected from %@.", sensor.name);
    lastResults = [[VitalConnectManager getSharedInstance] lastScanResult];
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
