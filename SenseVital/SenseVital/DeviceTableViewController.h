//
//  VCDeviceTable.h
//  CortexDemo
//
//  Created by Pim Nijdam on 12/3/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VitalConnect.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface DeviceTableViewController : UITableViewController <VitalConnectConnectionListener, CBCentralManagerDelegate>

@end
