//
//  AppDelegate.m
//  SenseVital
//
//  Created by Pim Nijdam on 17/04/14.
//  Copyright (c) 2014 Sense Observation Systems BV. All rights reserved.
//

#import "AppDelegate.h"
#import <Cortex/CSSensePlatform.h>
#import <Cortex/CSSettings.h>
#import "SDK.h"
#import "Factory.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *rootFileDir = [dirPaths objectAtIndex:0];
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    rootFileDir = [rootFileDir stringByAppendingPathComponent:[bundleInfo objectForKey:@"CFBundleDisplayName"]];
    [CSSensePlatform initialize];
	
	//[[CSSettings sharedSettings] setSettingType:kCSSettingTypeGeneral setting:kCSGeneralSettingUploadInterval value:@"3600"];
    self.vitalConnectManager = [VitalConnectManager createVitalConnect:SDK_API_KEY environment:kVitalConnectServerDevelopment services:kVitalConnectServerServicesNone rootFileDir:rootFileDir encrypted:NO];
    [self.vitalConnectManager start];
    [_vitalConnectManager enableAutoReconnect:YES];

    //initialize the factory
    [Factory sharedFactory];
    [[Factory sharedFactory].csVitalConnectSensor reconnect];

    //Immediately upload data, in case the app won't run for an hour, we'll at least upload all data we've collected so far.
    [CSSensePlatform flushData];

    //register for background fetch (used to upload the data to CS, esp. when the app can't run in the background due to no connected device, but we still need to upload the data)
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    return YES;
}

- (NSUInteger) supportedInterfaceOrientationsForWindow:(UIWindow*) window {
    return UIInterfaceOrientationPortrait;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self.vitalConnectManager applicationWillResignActive];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.]
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self.vitalConnectManager applicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [CSSensePlatform willTerminate];
    [self.vitalConnectManager applicationWillTerminate];
}

- (void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [CSSensePlatform flushDataAndBlock];
    completionHandler(UIBackgroundFetchResultNewData);
}


@end
