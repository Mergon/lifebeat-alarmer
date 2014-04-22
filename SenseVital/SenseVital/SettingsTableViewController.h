//
//  SettingsTableViewController.h
//  SenseVital
//
//  Created by Pim Nijdam on 22/04/14.
//  Copyright (c) 2014 Sense Observation Systems BV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController
- (IBAction) toggleTracking:(id)sender;
- (IBAction) toggleHFTracking:(id)sender;
- (IBAction) toggleWifiUploading:(id)sender;

- (IBAction) signOut:(id)sender;
- (IBAction) uploadNow:(id)sender;


@property (nonatomic, retain) IBOutlet UISwitch* hfSwitch;
@property (nonatomic, retain) IBOutlet UISwitch* wifiUploadSwitch;
@property (nonatomic, retain) IBOutlet UISwitch* trackingEnabledSwitch;
@end
