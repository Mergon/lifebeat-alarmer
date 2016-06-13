//
//  SettingsTableViewController.m
//  SenseVital
//
//  Created by Pim Nijdam on 22/04/14.
//  Copyright (c) 2014 Sense Observation Systems BV. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "Factory.h"
#import <Cortex/CSSensePlatform.h>
#import <Cortex/CSSettings.h>

static NSString* loginSucceedKey = @"LoginSucceed";

@implementation SettingsTableViewController {
    UIAlertView* signOutAlertView;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    signOutAlertView = [[UIAlertView alloc] initWithTitle:@"Sign out" message:@"Are you sure you want to sign out of CommonSense?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Sign out", nil];
    
    //NSString* pathToImageFile = [[NSBundle mainBundle] pathForResource:@"Background" ofType:@"png"];
    //UIImage* bgImage = [UIImage imageWithContentsOfFile:pathToImageFile];
    //[self.view setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];
    
    //set state of settings
    self.trackingEnabledSwitch.on = [Factory sharedFactory].csVitalConnectSensor.trackingEnabled;
    self.hfSwitch.on = [Factory sharedFactory].csVitalConnectSensor.HFData;
	self.uploadFreqSwitch.on = ([[CSSettings sharedSettings] getSettingType:kCSSettingTypeGeneral setting:kCSGeneralSettingUploadInterval].intValue <= 60);
	
	
    // MERRY HACK: Update threshold button
    [self updateThresholdButton];
    
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

#pragma mark - Actions
- (IBAction) toggleTracking:(id)sender {
    [[Factory sharedFactory].csVitalConnectSensor setTrackingEnabled:self.trackingEnabledSwitch.on];
}
- (IBAction) toggleHFTracking:(id)sender {
    [[Factory sharedFactory].csVitalConnectSensor setHFData:self.hfSwitch.on];
    
}
- (IBAction) toggleWifiUploading:(id)sender {
    
}

- (IBAction) toggleHighFrequencyUploading:(id)sender {
	if(self.uploadFreqSwitch.on) {
		[[CSSettings sharedSettings] setSettingType:kCSSettingTypeGeneral setting:kCSGeneralSettingUploadInterval value:@"60"];
	} else {
		[[CSSettings sharedSettings] setSettingType:kCSSettingTypeGeneral setting:kCSGeneralSettingUploadInterval value:@"3600"];
	}
}

- (IBAction) signOut:(id)sender {
    [signOutAlertView show];
    
}





- (IBAction)alarm:(id)sender { // MERRY HACK: Alarm button here
    [SendAlarm sendAlarmWithCompletionHandler:^{
        // Show confirmation
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Alarm sent!"
                                                                       message:@"An alarm has been sent."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (IBAction)autoAlarmThreshold:(id)sender { // MERRY HACK: Auto-alarm threshold here
    // Show alert
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Set Threshold"
                                                                   message:@"Set your desired threshold. If the heart beat rate drops below this threshold, an alarm will immediately be sent."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    __block NSString *thresholdText;
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {    }];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              UITextField *input = [[alert textFields] firstObject];
                                                              thresholdText = input.text;
                                                              [self setAutoAlarmThreshold:thresholdText];
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setAutoAlarmThreshold:(NSString*)thresholdText { // MERRY HACK: Set auto-alarm threshold here
    int threshold = thresholdText.intValue;
    if (threshold > 0) {
        // Save preference
        NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
        [prefs setBool:true forKey:@"MerryHackThresholdEnabled"];
        [prefs setInteger:threshold forKey:@"MerryHackThreshold"];
        [prefs synchronize];
        
        // Display new threshold
        [self updateThresholdButton];
    }
}

- (void)updateThresholdButton {
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs boolForKey:@"MerryHackThresholdEnabled"]) {
        int threshold = [prefs integerForKey:@"MerryHackThreshold"];
        NSMutableString *thresholdButtonText = [NSMutableString stringWithString:@"Auto-Alarm Threshold: "];
        [thresholdButtonText appendFormat:@"%d", threshold];
        [[_thresholdCell textLabel] setText:thresholdButtonText];
    }
    else {
        [[_thresholdCell textLabel] setText:@"Auto-Alarm Threshold"];
    }
}





- (IBAction) uploadNow:(id)sender {
    [self.uploadingActivityIndicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        [CSSensePlatform flushDataAndBlock];
        sleep(1);
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.uploadingActivityIndicator stopAnimating];
        });
    });
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == signOutAlertView) {
        switch (buttonIndex) {
            case 0:
                //cancel is pressed
                break;
            case 1: {
                NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
                [prefs setBool:NO forKey:loginSucceedKey];
                [CSSensePlatform logout];
                [self performSegueWithIdentifier:@"LoggedOut" sender:nil];
                break;
            }
        }
    }
}

@end
