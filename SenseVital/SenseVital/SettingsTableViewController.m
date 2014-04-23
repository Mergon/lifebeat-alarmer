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

#pragma mark - Actions
- (IBAction) toggleTracking:(id)sender {
    
}
- (IBAction) toggleHFTracking:(id)sender {
    if (sender == self.hfSwitch) {
        [[Factory sharedFactory].csVitalConnectSensor setHFData:self.hfSwitch.on];
    }
    
}
- (IBAction) toggleWifiUploading:(id)sender {
    
}

- (IBAction) signOut:(id)sender {
    [signOutAlertView show];
    
}
- (IBAction) uploadNow:(id)sender {
    [CSSensePlatform flushData];
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
