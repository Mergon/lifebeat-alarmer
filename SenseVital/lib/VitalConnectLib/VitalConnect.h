/**
 @file
 VitalConnect.h
 
 Copyright 2012, 2013 Vital Connect Inc. All rights reserved.
 
 This Software is the copyrighted work of Vital Connect, Inc. Use of the Software is governed by the terms of the end user license agreement,  which accompanies or is included with the Software ("License Agreement"). An end user will be unable to install or use any Software that is accompanied by or includes the License Agreement, unless he or she first agrees to the License Agreement terms.
 
 The Software is made available solely for use by end users according to the License Agreement. Any reproduction or redistribution of the Software not in accordance with the License Agreement is expressly prohibited by law.
 
 WITHOUT LIMITING THE FOREGOING, COPYING OR REPRODUCTION OF THE SOFTWARE OR REDISTRIBUTION IS EXPRESSLY PROHIBITED, UNLESS SUCH REPRODUCTION OR REDISTRIBUTION IS EXPRESSLY PERMITTED BY THE LICENSE AGREEMENT ACCOMPANYING SUCH SOFTWARE.
 
 THE SOFTWARE IS WARRANTED, IF AT ALL, ONLY ACCORDING TO THE TERMS OF THE LICENSE AGREEMENT. EXCEPT AS WARRANTED IN THE LICENSE AGREEMENT, VITAL CONNECT, INC HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS WITH REGARD TO THE SOFTWARE, INCLUDING ALL WARRANTIES AND CONDITIONS OF MERCHANTABILITY, WHETHER EXPRESS, IMPLIED OR STATUTORY, FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT.
 
 */

/**
 * @mainpage Vital Connect iPhone Library
 *
 * @section intro_sec Introduction
 *
 * This documentation set covers the Vital Connect library API for iPhone.  The Vital Connect library provides iPhone application developers access to the functionality of the Vital Connect vital signs monitoring and notification system.  The Vital Connect system includes a Bluetooth low energy technology vital signs sensor, the Vital Connect iPhone library, the Vital Connect cloud-based data storage, and notification infrastructure. This infrastructure provides analytics and chronic condition monitoring. Application developers can use this API to enhance their applications with the full range of functionality provided by the Vital Connect system.
 *
 * @section install_sec Installation
 * @subsection prior SDK Versions prior to 2.2.5
 * The library and associated sample code is shipped as an OS X package file. To install the library and associated sample code, double-click the package file, which  runs the package installer.  Accept the software license to install the library and sample code to ~/Desktop/VitalConnectLibrary.  Then restart Xcode to get Xcode to recognize the documentation.
 
 * @subsection andbeyond SDK Versions 2.2.5 and beyond

 The library and associated sample code is shipped as a zip file. To install the library and associated sample code, double-click the zip file, which will decompress the files into a VitalConnectLibrary directory in the current directory.  To make the documentation available to Xcode, copy the VitalConnectLibrary/Docs/com.vitalconnect.library.docset file to ~/Library/Developer/Shared/Documentation/DocSets and restart Xcode to recognize the new docset.
 
 * @subsection common All Versions

 The sample application can be built and run directly from the installation directory, and the library can be added to existing projects by copying the .a and .h files from the VitalConnectLibrary/Lib subdirectory into your project directory.
 
 Add the following key into info.plist to allow background Bluetooth processing in the application:
 key: UIBackgroundModes value:bluetooth-central
 
 *
 * @section using_sec Using the Library
 *
 * @subsection initializing_sec Initializing the Library
 * To use the library, you must have a valid API key.  This is an NSString value provided to you by Vital Connect to help us verify authorized usage of the library.   The library is initialized using the following code snippet:
 
 @code
 [VitalConnectManager createVitalConnect:@"<Your API key here>" 
                             environment:kVitalConnectServerDevelopment
                             rootFileDir:rootFileDirForStoringLogsAndOtherFiles
                               encrypted:isEncryptDeviceData];
 
 VitalConnectManager *vitalConnectManager = [[VitalConnectManager getSharedInstance] start];
 
 @endcode
 
 * Once initialized, the application should check to see if a valid relay GUID has been assigned to the library.  If not, the application should retrieve a relay GUID from the Vital Connect web services API and register the GUID with the library:
 
 @code
 -(void) doRegisterRelay {
 
 VitalConnectBackendErrorCode errorCode = [[VitalConnectManager getSharedInstance] registerRelay:SDK_RELAY_ID passCode:SDK_RELAY_PASSWORD];
 switch (errorCode) {
 case kBackendError_Success:
 {
 NSLog(@"RelayID given to library");
 break;
 }
 default:
 {
 [self performSelector:@selector(doRegisterRelay) withObject:nil afterDelay:1.0];
 break;
 }
 }
 }
 
 ...
 
 NSString * relayGUID = [self.vitalConnectManager getRelayIdentifier];
 if (relayGUID == nil || relayGUID.length == 0) {
 NSLog(@"Registering relay...");
 [self performSelector:@selector(doRegisterRelay) withObject:nil afterDelay:1.0];
 } else {
 NSLog(@"Using relay id: %@", relayGUID);
 }
 @endcode
 
 
 
 
 * @subsection connecting_sec Connecting to a sensor
 Once the library is initialized, the application can receive sensor events by declaring itself a VitalConnectConnectionListener, and registering itself with the VitalConnectManager:
 @code
 [vitalConnectManager addListener:self withNotificationsOnMainThread:YES];
 @endcode
 
 Then it can start scanning for devices:
 
 @code
 VitalConnectManager *vitalConnectManager = [VitalConnectManager getSharedInstance];
 [vitalConnectManager startScan];
 @endcode
 
 The application object will receive a notification that a device was seen via the VitalConnectConnectionListener interface.  A typical implementation of the didSeeNewSensor: and didConnectToSensor: methods is:
 
 @code
 -(void) didSeeNewSensor:(VitalConnectSensor *)sensor {
 [vitalConnectManager connectSensor:sensor forSensorSource: @"<your sensor source GUID>];
 
 }
 
 -(void) didConnectToSensor:(VitalConnectSensor *)sensor {
 //wahoo!  we are connected!
 }
 
 @endcode
 
 * @subsection registering_sec Registering for data events
 The application can register for many sensor data events.  The following code registers the application to receive battery level events - real time updates of the sensor battery level.
 
 @code
 VitalConnectManager* vcManager = [VitalConnectManager getSharedInstance];
 [vcManager addObserver: self selector:@selector(receivedBatteryChange:) name: kVCIObserverBattery];
 
 -(void)receivedBatteryChange: (NSNotification *)notification {
 NSDictionary *dict = (NSDictionary *)notification.object;
 NSNumber *batteryLevel = [dict objectForKey:kVCIObserverKeyBatteryLevel];
 //do something with this new battery level
 }
 
 }
 @endcode
 
 * @subsection notification_sec Watches and Notifications
 The application can set watches and receive notifications that the watch conditions have been met.  The following code shows how to do this for a fall watch.  The first step is to implement the VitalConnectWatchManagerObserver interface:
 
 @code
 // define your class to implement the VitalConnectWatchManagerObserver interface
 @interface THFWatchListViewController : UIViewController <VitalConnectWatchManagerObserver>
 ...
 @end
 @endcode
 
 In your class, register yourself as an observer, and create some watches:
 
 @code
 NSString *sensorSourceGUID = @"<sensor source GUID>"
 
 VitalConnectManager* vcManager = [VitalConnectManager getSharedInstance];
 // register for the
 [vcManager addWatchManagerObserver:self forSensorSource:sensorSourceGUID];
 
 [vcManager createEventWatchForSensorSource:sensorSourceGUID
 DataKey: kVCIWatchTypeFall
 Confirmation: NO];
 
 [vcManager createThresholdWatchForSensorSource:sensorSourceGUID
 DataKey: kVCIObserverKeyBpm
 Severity: kVitalConnectThresholdWatchSeverityLimit
 Bound: kVitalConnectThresholdWatchBoundAbove
 Confirmation: NO
 ThresholdValue: @90];
 @endcode
 
 The application object that registers as an watch manager observer will get a notification using the watchManagerTriggeredWatch method:
 
 @code
 - (void) watchManagerTriggeredWatch:(id<VitalConnectWatch>)watch byNotification:(NSString*)localNotificationId At:(NSDate*)triggerTime {
 //do something with the notification here!
 }
 @endcode
 
 * @subsection lifecycle_sec Handling application lifecycle events
 Because the library deals with background Bluetooth activity and stores data, the application should send application lifecycle events to the library from your AppDelegate:
 
 @code
 
 - (void)applicationWillResignActive:(UIApplication *)application
 {
 VitalConnectManager* vcManager = [VitalConnectManager getSharedInstance];
 [vcManager applicationWillResignActive];
 }
 
 - (void)applicationDidBecomeActive:(UIApplication *)application
 {
 VitalConnectManager* vcManager = [VitalConnectManager getSharedInstance];
 [vcManager applicationDidBecomeActive];
 }
 
 - (void)applicationWillTerminate:(UIApplication *)application
 {
 VitalConnectManager* vcManager = [VitalConnectManager getSharedInstance];
 [vcManager applicationWillTerminate];
 }
 
 @endcode
 
 * @subsection support_sec Support
 Please email VitalConnect at developer_support@vitalconnect.com for technical support.
 
 
 * @subsection license_sec License, Warranty and Copyright
 Copyright 2012, 2013 VitalConnect, Inc. All rights reserved.
 
 This Software is the copyrighted work of VitalConnect, Inc. Use of the Software is governed by the terms of the end user license agreement,  which accompanies or is included with the Software ("License Agreement"). An end user will be unable to install or use any Software that is accompanied by or includes the License Agreement, unless he or she first agrees to the License Agreement terms.
 
 The Software is made available solely for use by end users according to the License Agreement. Any reproduction or redistribution of the Software not in accordance with the License Agreement is expressly prohibited by law.
 
 WITHOUT LIMITING THE FOREGOING, COPYING OR REPRODUCTION OF THE SOFTWARE OR REDISTRIBUTION IS EXPRESSLY PROHIBITED, UNLESS SUCH REPRODUCTION OR REDISTRIBUTION IS EXPRESSLY PERMITTED BY THE LICENSE AGREEMENT ACCOMPANYING SUCH SOFTWARE.
 
 THE SOFTWARE IS WARRANTED, IF AT ALL, ONLY ACCORDING TO THE TERMS OF THE LICENSE AGREEMENT. EXCEPT AS WARRANTED IN THE LICENSE AGREEMENT, VitalConnect, INC HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS WITH REGARD TO THE SOFTWARE, INCLUDING ALL WARRANTIES AND CONDITIONS OF MERCHANTABILITY, WHETHER EXPRESS, IMPLIED OR STATUTORY, FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT.
 */

/**
 * Specifies valid values for VitalConnect system observer types.
 */
typedef NSString* const VitalConnectObserverType;

/// Specifies that the observer would like to receive auto-scan status change notifications.
extern VitalConnectObserverType kVCIOberserverAutoscanStatusChange;

/// Specifies that the observer would like to receive sensor authenticating notifications.
extern VitalConnectObserverType kVCIObserverSensorAuthenticating;

/// Specifies that the observer would like to receive sensor authenticated notifications.
extern VitalConnectObserverType kVCIObserverSensorAuthenticated;

/// Specifies that the observer would like to receive sensor connected notifications.
extern VitalConnectObserverType kVCIObserverSensorConnected;

/// Specifies that the observer would like to receive sensor pairing notifications.
extern VitalConnectObserverType kVCIObserverSensorPairing;

/// Specifies that the observer would like to receive sensor paging notifications.
extern VitalConnectObserverType kVCIObserverSensorPaging;

/// Specifies that the observer would like to receive sensor connect error notifications.
extern VitalConnectObserverType kVCIObserverSensorConnectError;

/// Specifies that the observer would like to receive sensor disconnect error notifications.
extern VitalConnectObserverType kVCIObserverSensorDisconnect;

/// Specifies that the observer would like to receive sensor heart value notifications.
extern VitalConnectObserverType kVCIObserverHeartValue;

/// Specifies that the observer would like to receive sensor heart rate notifications.
extern VitalConnectObserverType kVCIObserverHeartRate;

/// Specifies that the observer would like to receive sensor respiration rate notifications.
extern VitalConnectObserverType kVCIObserverRespiration;

/// Specifies that the observer would like to receive sensor activity notifications.
extern VitalConnectObserverType kVCIObserverActivity;

/// Specifies that the observer would like to receive sensor step notifications.
extern VitalConnectObserverType kVCIObserverSteps;

/// Specifies that the observer would like to receive sensor stress notifications.
extern VitalConnectObserverType kVCIObserverStress;

/// Specifies that the observer would like to receive all data notifications. Restricted by key.
extern VitalConnectObserverType kVCIObserverSensorData;

/// Specifies that the observer would like to receive battery change notifications.
extern VitalConnectObserverType kVCIObserverBattery;

/// Specifies that the observer would like to receive network status change notifications.
extern VitalConnectObserverType kVCIObserverNetworkStatus;

/// Specifies that the observer would like to receive raw accelerometer notifications. Restricted by key.
extern VitalConnectObserverType kVCIObserverAccelerometer;

/// Specifies that the observer would like to receive raw impedance notifications. Restricted by key.
extern VitalConnectObserverType kVCIObserverImpedance;

/// Specifies that the observer would like to receive Energy Expended readings.
extern VitalConnectObserverType kVCIObserverEnergyExpended;

/// Specifies that the observer would like to receive Caloric Burn readings.
extern VitalConnectObserverType kVCIObserverCaloricBurn;

/// Specifies that the observer would like to receive Body Temperature readings.
extern VitalConnectObserverType kVCIObserverBodyTemp;

/// Specifies that the observer would like to receive RR Interval readings.
extern VitalConnectObserverType kVCIObserverRRInterval;

/// Specifies that the observer would like to receive sensor used memory size readings.
extern VitalConnectObserverType kVCIObserverSensorMem;

/**
 * Specifies valid values for VitalConnect dictionary keys.
 */
typedef NSString* const VitalConnectKeyType;

/// The value for this key is the number of samples in the data sample array. @see process_data_func.
extern VitalConnectKeyType kVCIObserverKeyCount;

/// The value for this key is the VitalConnect device ID. @see process_data_func.
extern VitalConnectKeyType kVCIObserverKeyDeviceId;

/// The value for this key is the timestamp of type NSInterval for the sample.  @see process_data_func.
extern VitalConnectKeyType kVCIObserverKeyTime;

/// The value for this key is the number of beats per minute in the data sample array. @see process_data_func.
extern VitalConnectKeyType kVCIObserverKeyBpm;

/// The value for this key is respiration rate value in the data sample array. @see process_data_func.
extern VitalConnectKeyType kVCIObserverKeyRespiration;

/// The value for this key is the raw ECG data in the data sample array. @see process_data_func.
extern VitalConnectKeyType kVCIObserverKeyRawHeartValue;

/// The value for this key is the battery level of the sensor.
extern VitalConnectKeyType kVCIObserverKeyBatteryLevel;

/// The value for this key is the raw activity (posture) data in the data sample array. @see process_data_func.
extern VitalConnectKeyType kVCIObserverKeyActivity;

/// The value for this key is the raw posture angle theta data in the data sample array. @see process_data_func.
extern VitalConnectKeyType kVCIObserverKeyPostureAngleTheta;

/// The value for this key is the raw posture angle phi data in the data sample array. @see process_data_func.
extern VitalConnectKeyType kVCIObserverKeyPostureAnglePhi;

/// The value for this key is the raw steps data in the data sample array. @see process_data_func.
extern VitalConnectKeyType kVCIObserverKeyRawSteps;

/// The value for this key is the raw contact impedance data in the data sample array. @see process_data_func.
extern VitalConnectKeyType kVCIObserverKeyImpedance;

/// The value for this key is the raw x-axis accelerometer data. @see process_data_func.
extern VitalConnectKeyType kVCIObserverKeyRawXValue;

/// The value for this key is the raw y-axis accelerometer data. @see process_data_func.
extern VitalConnectKeyType kVCIObserverKeyRawYValue;

/// The value for this key is the raw z-axis accelerometer data. @see process_data_func.
extern VitalConnectKeyType kVCIObserverKeyRawZValue;

/// The value for this key is the RR interval. @see process_data_func.
extern VitalConnectKeyType kVCIObserverKeyRRInterval;

/// The value for this key is the stress data in the data sample array. @see process_data_func.
extern VitalConnectKeyType kVCIObserverKeyStress;

/// The value for this key is a NSString containing action of network transaction being notified. @see kVCIObserverNetworkStatus.
extern VitalConnectKeyType kVCIObserverKeyNetAction;

/// The value for this key is a NSString containing status of network transaction being notified. @see kVCIObserverNetworkStatus.
extern VitalConnectKeyType kVCIObserverKeyNetStatus;

/// The value for this key is a NSString containing error (if present) of network transaction being notified. @see kVCIObserverNetworkStatus.
extern VitalConnectKeyType kVCIObserverKeyNetError;

/// The value for this key is a NSString containing url (if present) of network transaction being notified. @see kVCIObserverNetworkStatus.
extern VitalConnectKeyType kVCIObserverKeyNetUrl;

/// The value for this key is a NSString containing message from server of network transaction being notified. @see kVCIObserverNetworkStatus.
extern VitalConnectKeyType kVCIObserverKeyNetMessage;

/// Status value indicating start of a network transaction. @see kVCIObserverKeyNetStatus.
extern VitalConnectKeyType kVCIObserverKeyNetStatusBegin;

/// Status value indicating successful completion of a network transaction. @see kVCIObserverKeyNetStatus.
extern VitalConnectKeyType kVCIObserverKeyNetStatusSuccess;

/// Status value indicating unsuccessful completion of a network transaction. @see kVCIObserverKeyNetStatus.
extern VitalConnectKeyType kVCIObserverKeyNetStatusError;

/// Status value indicating unsuccessful attempt to receive data permissions from the server.
extern VitalConnectKeyType kVCIObserverKeyAuthorizationError;

/// Status value indicating unsuccessful attempt to authenticate with the server.
extern VitalConnectKeyType kVCIObserverKeyAuthenticationError;

/// Data indicating device name for failed authentication with the server.
extern VitalConnectKeyType kVCIObserverKeyAuthDeviceName;

/// Data indicating device type for failed authentication with the server.
extern VitalConnectKeyType kVCIObserverKeyAuthDeviceType;

/// The value for this key is the energy expended. @see process_data_func. @see kVCIObserverEnergyExpended.
extern VitalConnectKeyType kVCIObserverKeyEnergyExpended;

/// The value for this key is the Caloric Burn. @see process_data_func. @see kVCIObserverCaloricBurn.
extern VitalConnectKeyType kVCIObserverKeyEnergyExpendedRate;

/// The value for this key is the Body Temperature. @see process_data_func. @see kVCIObserverBodyTemp.
extern VitalConnectKeyType kVCIObserverKeyBodyTemp;

/// Data indicating whether sample is live or stored.  @see VCStreamType for valid values.
extern VitalConnectKeyType kVCIObserverKeyStream;

/// The value for this key is the free memory level of the sensor.
extern VitalConnectKeyType kVCIObserverKeyMemoryLevel;

/**
 * The value for the kVCIObserverKeyStream key
 */
typedef enum {
    /// The associated data or event occurred on the stored stream.
    kVCIStoredStream,
    /// The associated data or event occurred on the live stream.
    kVCILiveStream
} VCStreamType;

/**
 * The current status of the device antenna (e.g. Bluetooth).
 */
typedef enum
{
    /// The device antenna is in an unknown state...perhaps updating
    kVCIAntennaStateUnknown,
    /// The device antenna is resetting
    kVCIAntennaStateResetting,
    /// The device status command is not supported by the platform
    kVCIAntennaStateUnsupported,
    /// The device antenna is not authorized to be enabled
    kVCIAntennaStateUnauthorized,
    /// The device antenna is off
    kVCIAntennaStateOff,
    /// The device antenna is on
    kVCIAntennaStateOn
} VCDeviceAntennaState;

/**
 * Used to specify a VitalConnect scanner state.
 */
typedef const NSUInteger VitalConnectScannerState;

/// Scanner is in an unknown or uninitialized state.
extern VitalConnectScannerState kVCIScannerStateUnknown;

/// Scanning is initialized but not started.
extern VitalConnectScannerState kVCIScannerStateOn;

/// Scanner is in the process of starting an auto scan operation.
extern VitalConnectScannerState kVCIScannerStateStartAutoscan;

/// Scanner is in the process of starting an manual scan operation.
extern VitalConnectScannerState kVCIScannerStateStartScan;

/// Scanner is performing a manual scan operation.
extern VitalConnectScannerState kVCIScannerStateScanning;

/// Scanner is in the process of stopping a manual or auto scan operation.
extern VitalConnectScannerState kVCIScannerStateStopScan;

/// Scanner is in the process of connecting to a sensor during an auto scan operation.
extern VitalConnectScannerState kVCIScannerStateConnecting;

/// Scanner has connected to a sensor during an auto scan operation.
extern VitalConnectScannerState kVCIScannerStateConnected;

/// Scanner is in the process of disconnecting during an auto scan operation.
extern VitalConnectScannerState kVCIScannerStateDisconnecting;

/// Scanner is off.
extern VitalConnectScannerState kVCIScannerStateOff;

/// Scanner could not find the name of the device specified for an auto scan operation.
extern VitalConnectScannerState kVCIScannerStateAutoscanDeviceNotFound;

/**
 * Server environments supported by VitalConnect.
 */
typedef enum {
    /// Run this application in a development server associated with the application's API key.
    kVitalConnectServerDevelopment,
    /// Run this application in the production server associated with the application's API key.
    kVitalConnectServerProduction,
    /// Run this application in a test server associated with the application's API key.
    kVitalConnectServerTest,
} VitalConnectServerEnvironment;


/**
 * Server services supported by VitalConnect.
 */
typedef enum {
    /// No Services Supported
    kVitalConnectServerServicesNone         = 0,
    /// Service to support OTA Firmware Upgrade.
    kVitalConnectServerServiceFWUpdate      = 1 << 0,
    /// Service to support user demographics upload.
    kVitalConnectServerServiceDemographics  = 1 << 1,
    /// Service to support data samples upload.
    kVitalConnectServerServiceDataUplaod    = 1 << 2,
    /// Service to support remote Watches.
    kVitalConnectServerServiceWatches       = 1 << 3,
    /// Service to support logs upload.
    kVitalConnectServerServiceLogs          = 1 << 4,

} VitalConnectServerServices;


/**
 * Postures supported by the VitalConnect system.
 * @see kVCIObserverActivity
 */
typedef enum {
    /// The sensor has recognized that the user is lying down (generic).
    kPostureLayingDown = 0,
    /// The sensor has recognized that the user is sitting.
    kPostureSitting,
    /// The sensor has recognized that the user is standing.
    kPostureStanding,
    /// The sensor has recognized that the user is walking.
    kPostureWalking,
    /// The sensor has recognized that the user is running.
    kPostureRunning,
    /// The posture of the user is unknown.
    kPostureUnknown,
    /// The sensor has recognized that the user is driving.
    kPostureDriving,
    /// The sensor has recognized that the user is lying down on their back.
    kPostureLayingDownSupine,
    /// The sensor has recognized that the user is lying down on their left side.
    kPostureLayingDownOnLeftSide,
    /// The sensor has recognized that the user is lying down on their right side.
    kPostureLayingDownOnRightSide,
    /// The sensor has recognized that the user is lying down on their stomach.
    kPostureLayingDownProne,
    /// The sensor has recognized that the user is leaning back.
    kPostureLeaningBack
} VitalConnectPosture;

/**
 * Sensor status values supported by the VitalConnect system.
 * @see VitalConnectSensor
 * @since V1.1.1
 */
typedef enum {
    /// The patch status is unknown.
    kPatchStatusUnknown,
    /// The patch is correctly attached to the user's body.
    kPatchStatusApplied,
    /// The patch has been removed from the user's body.
    kPatchStatusRemoved,
    /// The patch status is attached to the user's body, but the signal quality is poor.
    kPatchStatusPoorConnection
} VitalConnectPatchStatus;

/**
 * VitalConnectManager error return codes.
 @see VitalConnectManager
 */
typedef enum {
    /// Generic Failure. If you receive this error message, contact technical support.
    kVitalConnectmanagerGenericError = -1,
    /// No Error
    kVitalConnectmanagerNoError = 0,
    /// Not Authorized
    kVitalConnectmanagerUnauthorized = 1,
    /// Invalid observer type
    kVitalConnectmanagerInvalidObserverType = 2,
    /// Data provider initialize and connect failed
    kVitalConnectmanagerReadInitFailed = 3,
    /// Sensor not connected
    kVitalConnectmanagerNotConnected = 57
} VitalConnectErrorCode;

/**
 * Observable object callback protocol. @see VitalConnectObservable
 */
@protocol VitalConnectObservableChangeListener <NSObject>
@required
/// Called after the observable object changed
- (void) notifyChange:(NSObject*)observable;
@end

/**
 * Observable Objects are those which can register observers, and notify the observer when the object changes.
 @see VitalConnectObservableChangeListener
 */
@protocol VitalConnectObservable <NSObject>

@required
/// Register an observable object to change notifications
- (void) addObserver:(id<VitalConnectObservableChangeListener>)observer;
/// Unregister an observable object from change notifications
- (void) delObserver:(id<VitalConnectObservableChangeListener>)observer;

@end

/// Notification status states @see VitalConnectNotification
typedef enum {
	/// The notification status is unknown
    kVitalConnectNotificationStatusUnknown = 0,
	/// The watch associated with this notification status is queued for synd with the server
    kVitalConnectNotificationStatusWatchQueued,
	/// The notification status is pending
    kVitalConnectNotificationStatusPending,
    /// The notification is a new notification
    kVitalConnectNotificationStatusNew,
    /// The notification has been queried
    kVitalConnectNotificationStatusQueued,
    /// The notification has been delivered
    kVitalConnectNotificationStatusDelivered,
    /// The notification is acknowledged
    kVitalConnectNotificationStatusAcknowledged,
    /// The notification is undeliverable
    kVitalConnectNotificationStatusUndeliverable,
    /// The notification has been has not been acknowledged
    kVitalConnectNotificationStatusunacknowledged,
} VitalConnectNotificationStatus;

/**
 * VitalConnect Notification.  Generated by triggering a watch @see VitalConnectWatch
 */
@protocol VitalConnectNotification <NSObject>
@required
/// Sensor data source for the notification
@property (copy, readonly, nonatomic) NSString* sensorDataSource;
/// local ID for the notification
@property (copy, readonly, nonatomic) NSString* localId;
/// Server generated ID for the notification
@property (copy, readonly, nonatomic) NSString* notificationId;
/// Watch ID that triggered to generate this notification @see VitalConnectWatch
@property (copy, readonly, nonatomic) NSString* watchId;
/// Local Watch that triggered to generate this notification @see VitalConnectWatch
@property (copy, readonly, nonatomic) NSString* localWatchId;
/// If applicable the value which triggered the notification @see VitalConnectThresholdWatch
@property (copy, readonly, nonatomic) NSNumber* value;
/// The timestamp of the triggered notification
@property (readonly, nonatomic) uint64_t uSecTriggered ;
/// The status of the notification @see VitalConnectNotificationStatus
@property (readonly, nonatomic) VitalConnectNotificationStatus status;
@end

/// VitalConnect Watch status states @see VitalConnectWatch
typedef enum {
    /// The watch status is unknown.
    kVitalConnectWatchStatusUnknown = 0,
    /// The watch has been created and is in the process of being synchronized with the server.
    kVitalConnectWatchStatusNew,
    /// The watch has been queued with the server.
    kVitalConnectWatchStatusQueued,
    /// The watch is no longer active, but not yet deleted.
    kVitalConnectWatchStatusInactive,
    /// The watch is active.
    kVitalConnectWatchStatusActive,
    /// The watch was deleted locally by the user but delete state has not yet been synced w/the server.
    kVitalConnectWatchStatusDeleting,
    /// The watch has been deleted and can no longer generate notifications.
    kVitalConnectWatchStatusDeleted
} VitalConnectWatchStatus;



/// A type definition for VitalConnect Watches.
typedef NSString*  VitalConnectWatchType;

/// A fall watch type.  This type of watch will cause notifications when the person wearing the patch falls.
extern VitalConnectWatchType kVCIWatchTypeFall;

/// A low battery watch type.  This type of watch will generate notifications when the sensor battery is low.
extern VitalConnectWatchType kVCIWatchTypeLowBattery;

/// A patch off watch type.  This type of watch will generate notifications when the sensor is completely off the wearer's body.
extern VitalConnectWatchType kVCIWatchTypePatchOff;

/// A reachability watch.  This type of watch will generate notifications when the person wearing the patch has wandered out of range of the connected sensor, or for any other reason lost connection with a connected sensor.
extern VitalConnectWatchType kVCIWatchTypeSensorReachability;

/// A contextual heart rate watch type.  This type of watch will generate notifications when the wearer's heart rate and activity are not consistent - for example, if the person wearing the patch is running and their heart rate is not increased, or when the person wearing the patch is not active and their heart rate has increased.
extern VitalConnectWatchType kVCIWatchTypeContextualHeartrate;

/// A threshold watch type.  This type of watch generates notifications based on programmed threshold values.
extern VitalConnectWatchType kVCIWatchTypeThreshold;

/**
 * An array of possible data keys that can be configure for event watches
 */
extern NSArray* VitalConnectEventDataKeyList;


/**
 * A VitalConnect watch object.  This object is used both to set a watch and to record a notification event.  VitalConnect
 * Watches are managed by the VitalConnectManager object.
 * @see VitalConnectManager
 */
@protocol VitalConnectWatch <VitalConnectObservable>

@required
/// The Sensor Data Source the watch belongs to
@property (readonly) NSString* sensorDataSource;
/// The server generated ID for the watch
@property (readonly) NSString* serverId;
/// The local id for the watch
@property (readonly) NSString* clientLocalId;
/// The timestamp the watch was created
@property (readonly) NSDate* created;
/// The timestamp the watch was last updated
@property (readonly) NSDate* updated;
/// The type of watch
@property (readonly) NSString* watchType;
/// The remote status for the watch
@property (readonly) VitalConnectWatchStatus status;
/// ArrayList of NSObject<VitalConnectNotifications>*
@property (readonly) NSArray* notificationList;
/// Does generated notification require notification.
@property (readonly) BOOL needsConfirmation;
@end

/**
 * Threshold watch severity
 */
typedef enum {
    /// A Warning
    kVitalConnectThresholdWatchSeverityWarn = 0,
    /// A Limit
    kVitalConnectThresholdWatchSeverityLimit = 1,
    /// A Goal
    kVitalConnectThresholdWatchSeverityGoal = 2
} VitalConnectThresholdWatchSeverity;

/**
 * Threshold Watch bound
 */
typedef enum {
    /// Watch will trigger when the observer channel value is above the threshold value.
    kVitalConnectThresholdWatchBoundAbove = 0,
    /// Watch will trigger when the observer channel value is below the threshold value.
    kVitalConnectThresholdWatchBoundBelow = 1
} VitalConnectThresholdWatchBound;

/**
 * Threshold watches can be configured for only certain data.
 */
typedef VitalConnectKeyType VitalConnectThresholdDataKey;

/**
 * An array of possible data keys that can be configure for threshold watches
 */
extern NSArray* VitalConnectThresholdDataKeyList;

/**
 * Threshold watches listen to data channels and triggers based on observed values
 */
@protocol VitalConnectThresholdWatch <VitalConnectWatch>

@required
/// the critical value which will cause the watch to trigger.
@property (copy, readonly, nonatomic) NSNumber* thresholdValue;
/// The data key to listen to.
@property (copy, readonly, nonatomic) NSString* key;
/// The bound, above or below to trigger on.
@property (readonly, nonatomic) VitalConnectThresholdWatchBound bound;
/// The severity of watch.
@property (readonly, nonatomic) VitalConnectThresholdWatchSeverity severity;
@end

/**
 * WatchManager Observer
 */
@protocol VitalConnectWatchManagerObserver <NSObject>
@required
/// Called by library upon creation of a watch.
@optional
- (void) watchManagerAddedWatch:(id<VitalConnectWatch>)watch;
/// Called by library upon removal of a watch.
@optional
- (void) watchManagerRemovedWatch:(id<VitalConnectWatch>)watch;
/// Called by library upon triggering of a watch.
@optional
- (void) watchManagerTriggeredWatch:(id<VitalConnectWatch>)watch byNotification:(NSString*)localNotificationId At:(NSDate*)triggerTime;
/// Called by library upon updating of a watch.
@optional
- (void) watchManagerChangedWatch:(id<VitalConnectWatch>)watch;
@end

/**
 * A VitalConnect note entry object.  This object is used to create a note event in the VitalConnect system.  Note events are
 * stored and correlated with the sensor data.
 * @since V1.1.1
 */
@interface VitalConnectNoteEntry : NSObject <NSCoding>

/// A text description of the note entry.
@property (strong, nonatomic) NSString *description;

/// A timestamp for the note entry.
@property (strong, nonatomic) NSDate *timeStamp;
@end

/**
 * A protocol that defines a listener object for adding and removing note entries.  Register to listen to note events using
 * the VitalConnectManager.
 * @see VitalConnectManager.
 * @since V1.1.1
 */
@protocol VitalConnectNoteManagerListener <NSObject>
@optional
/**
 *  An indication that a note entry was added to the VitalConnect system.
 * @param entry The entry that was added.
 * @since V1.1.1
 */
-(void) entryAdded:(VitalConnectNoteEntry *)entry;

/**
 *  An indication that a note entry was removed from the VitalConnect system.
 * @param entry The entry that was removed.
 * @since V1.1.1
 */
-(void) entryRemoved:(VitalConnectNoteEntry *)entry;
@end

@class VitalConnectSensor;
/**
 * A protocol that defines a listener object for VitalConnect connection events.  Register to listen to events using
 * the VitalConnectManager.
 * @see VitalConnectManager.
 */
@protocol VitalConnectConnectionListener <NSObject>

@optional
/**
 * The device's antenna state has changed
 * @param state  The new device antenna state.
 */
-(void) deviceAntennaStatusChange:(VCDeviceAntennaState)state;

@optional
/**
 * A new sensor was seen during a scan operation.
 * @param sensor  The new sensor that was seen.
 */
-(void) didSeeNewSensor:(VitalConnectSensor *)sensor;

@optional
/**
 * An indication that a connection is being connected.
 * @param sensor  The sensor being connected.
 */
-(void) sensorPairing:(VitalConnectSensor *)sensor;

@optional
/**
 * An indication that a sensor is being actively paged for a connection.
 * @param sensor  The sensor being paged.
 */
-(void) sensorPaging:(VitalConnectSensor *)sensor;

@optional
/**
 * An indication that a connection is being authenticated.
 * @param sensor  The sensor being authenticated.
 */
-(void) sensorAuthenticating:(VitalConnectSensor *)sensor;

@optional
/**
 * An indication that a connection is being secured.
 * @param sensor  The sensor being secured.
 */
-(void) sensorSecuring:(VitalConnectSensor *)sensor;

@optional
/**
 * An indication that a connection operation was successful.
 * @param sensor  The newly connected sensor.  This sensor is created by the VitalConnect system, and is available in the
 * VitalConnectManager.activeSensor property.
 */
-(void) didConnectToSensor:(VitalConnectSensor *)sensor;

@optional
/**
 * An indication that a connection operation was unsuccessful.
 * @param Uuid  The Uuid of the sensor that failed to connect.
 */
-(void) didNotConnectToSensorWithUuid:(NSString *)Uuid;

@optional
/**
 * An indication that a previously connected sensor received a disconnect request.
 * @param sensor  The disconnecteding sensor.
 */
-(void) sensorDisconnecting:(VitalConnectSensor *)sensor;

@optional
/**
 * An indication that a previously connected sensor received a disconnect. The VitalConnectManager.activeSensor
 * property is set to nil prior to this indication.
 * @param sensor  The disconnected sensor.
 */
-(void) disconnectReceivedFromSensor:(VitalConnectSensor *)sensor;

@optional
/**
 * A scan operation will start.
 */
-(void) willStartScanning;

@optional
/**
 * A paging operation will start.
 */
-(void) willStartPaging;

@optional
/**
 * A scan operation was started.
 */
-(void) didStartScanning;

@optional
/**
 * A scan operation was stopped.
 */
-(void) didStopScanning;

@optional
/**
 * An indication the stored data stream on a sensor was enabled/disabled
 * @param sensor  Sensor whose stored data stream was enabled/disabled
 * @param bEnabled Stored data stream was enabled/disabled
 */
-(void) storedDataOnSensor:(VitalConnectSensor *)sensor enabled:(BOOL)bEnabled;

@optional
/**
 * The Sensor Data Source GUID returned by the server doesn't match the sensor data source guid provided
 * during sensor connect. @see VitalConnectManager#connectSensor:forSensorSource:
 * @param guid The Sense Source GUID passed into connectSensor, that doesn't match.
 * @param sensor The Sensor passed into connectSensor bound to a Sensor Data Source other than that passed in as guid.
 * @param isUnRegistered True is the sensor is not currently registered to a Sensor Data Source @see bindSensor:withGUID:
 */
-(void) mismatchedSensorSourceGUID:(NSString*)guid ForSensor:(VitalConnectSensor*)sensor isUnRegistered:(BOOL)isUnRegistered;

@optional
/**
 * The Sensor Data Source GUID returned by the server matched the sensor data source guid provided
 * during sensor connect. @see VitalConnectManager#connectSensor:forSensorSource:
 * @param sensor The sensor passed into connectSensor bound to the Sensor Data Source guid
 * @param guid The sensor Source GUID passed into connectSensor.
 */
-(void) matchedSensorSource:(VitalConnectSensor *)sensor forGUID:(NSString*) guid;

@optional
/**
 * The sensor stopped communicating with the app and will be disconnected. Not called on the main thread.
 * @param sensor The currently connected sensor (soon to be disconnected).
 */
-(void) moduleCommunicationTimedOut:(VitalConnectSensor *)sensor;

@optional
/**
 * Read of sensor config value failed
 * @param sensor The currently connected sensor (soon to be disconnected)
 * @param config String name of config value
 * @param error Error value
 */
-(void) sensorReadConfigError:(VitalConnectSensor*)sensor configName:(NSString*)config error:(int)error;

@optional
/**
 * Write of sensor config value failed
 * @param sensor The currently connected sensor (soon to be disconnected)
 * @param config String name of config value
 * @param error Error value
 */
-(void) sensorWriteConfigError:(VitalConnectSensor*)sensor configName:(NSString*)config error:(int)error;

@end


/**
 * Backend (server) errors seen by the system.
 */
typedef enum
{
    /// No error occurred
    kBackendError_Success = 0,
    /// An unknown error occurred.If you see this error, contact technical support.
    kBackendError_GeneralError = 1,
    /// A sensor was not able to be bound
    kBackendError_SensorUnbound,
    /// A component (sensor or relay) was not able to authenticate to the server
    kBackendError_AuthenticationError,
    /// A component (sensor or relay) was not able to get authorization rights from the server
    kBackendError_AuthorizationError,
    /// Service discovery failed
    kBackendError_DiscoveryError,
    /// Attempt to bind sensor failed
    kBackendError_BindError,
    /// Attempt to create relay failed
    kBackendError_CreateRelayError,
    /// The network was unreachable
    kBackendError_NetworkNotReachable,
    /// The network was unreachable while module pairing was in-progress (disconnect module and try again with network available)
    kBackendError_NetworkNotReachablePairingError,
    /// The network was unreachable while module binding was in-progress (disconnect module and try again with network available)
    kBackendError_NetworkNotReachableBindingError,
    /// The Sensor Data Source Guid sent to the Vital Connect server was not recognized
    kBackendError_SDSNotRecognizedByCDS,
} VitalConnectBackendErrorCode;


/**
 * An interface for receiving "backend" error notifications.  Backend notifications are generated from the library's
 * interaction with the VitalConnect server.
 */
@protocol VitalConnectBackendListener <NSObject>

/**
 * A backend error was received
 * @param error  backend error code
 * @param componentName component associated with the error
 */
-(void) onBackendError:(VitalConnectBackendErrorCode)error  inComponent:(NSString*)componentName;

@end
/**
 * Upgrade errors seen by the system.
 */

typedef enum
{
    /// An unknown error occurred. If you see this error, contact technical support.
    kFWUpgradeError_Unknown = 0,
    /// There was a failure during the upgrade
    kFWUpgradeError_GeneralFailure = 1,
    /// There is no upgrade available
    kFWUpgradeError_NoUpgradeAvailable = 2,
    /// The check for upgrade failed
    kFWUpgradeError_UpgradeCheckFailed = 0x11,
    /// The download failed
    kFWUpgradeError_DownloadFailed = 0x12,
    /// There was an error connecting to the module
    kFWUpgradeError_ModuleConnectionError = 0x21,
    /// An error occurred during the module upgrade
    kFWUpgradeError_ModuleUpgradeError = 0x22
} VitalConnectFirmwareUpgradeError;


/**
 * A protocol that defines a listener object for VitalConnect firmware upgrade events.  Register to listen to events using
 * the VitalConnectManager.
 * @see VitalConnectManager.
 */

@protocol VitalConnectFirmwareUpgradeListener <NSObject>

/**
 * A new firmware upgrade is available.
 * @param sensor  The  sensor
 * @param upgradeVersion The version of the upgrade
 */
- (void) upgradeAvailableFor:(VitalConnectSensor*)sensor toVersion:(NSString*)upgradeVersion;

/**
 * The firmware upgrade is complete.
 * @param sensor  The  sensor
 * @param upgradeVersion The version of the upgrade
 */
- (void) onUpgradeComplete:(VitalConnectSensor*)sensor toVersion:(NSString*)upgradeVersion;

/**
 * The firmware upgrade failed to complete.
 * @param sensor  The  sensor
 * @param targetVersion The version of the upgrade
 * @param error The firmware upgrade error
 */
- (void) onUpgradeFailure:(VitalConnectSensor*)sensor toVersion:(NSString*)targetVersion error:(VitalConnectFirmwareUpgradeError)error;

/**
 * The firmware download is complete.
 */
@optional
- (void) onFirmwareDownloadComplete;

/**
 * The sensor rebooting with new firmware.
 */
@optional
- (void) onModuleRebootBegin;

/**
 * The firmware upgrade has begun.
 */
@optional
- (void) onModuleUpgradeBegin;

/**
 * The firmware upgrade has begun.
 */
@optional
- (void) onModuleBytesWritten;

/**
 * Determine whether firmware should be upgraded
 */
@optional
- (BOOL) shouldUpgradeFirmware;

@end

/** 
 * Statistics that can be retrieved by the application relevant to OTA firmware upgrade
 */
@interface VitalConnectFirmwareUpgradeStats: NSObject
{
@public
    /// Current image in firmware upgrade download file
    NSUInteger currImage;
    /// Number of images in firmware upgrade download file
    NSUInteger numImages;
    /// Approximate percentage complete to flash all images. Includes download time and time to flash.
    NSNumber* percentComplete;
    
    /// Amount of bytes from the current image transferred to module
    NSUInteger currImage_bytesTransferred;
    /// Total number of bytes in the current image
    NSUInteger currImage_bytesTotal;
    /// Approximate time to flash in seconds for the current image, once download complete.
    NSUInteger currImage_flashTime;
    
    /// Total number of bytes to be transferred for all images in the download file
    NSUInteger allImages_bytesTotal;
    /// Approximate time to flash in seconds for all images in download file
    NSUInteger allImages_flashTimeTotal;
}

@end

/**
 * An individual log message.
 * @since V1.1.1
 */
@protocol VitalConnectLogMessage <NSObject>
@required
/// The message being logged.
@property (retain, nonatomic, readonly) NSString* msg;
/// The thread number that generated the log message.
@property (nonatomic, readonly) uint64_t threadId;
/// The timestamp of the log message.
@property (retain, nonatomic, readonly) NSDate* timestamp;
@end

/**
 * The VitalConnectLogManager.  Object implementing this protocol will receive log messages from the library.
 * @since V1.1.1
 */
@protocol VitalConnectLogManager <NSObject>

@required

/**
 * log callback to be called when the library generates or receives a log message.
 * @param logManager The logManager handling the log message.
 * @param log The message being logged, either from the library or appendLogMessage
 * @since V1.1.1
 */
- (void)logManager:(id <VitalConnectLogManager>)logManager Log:(id <VitalConnectLogMessage>)log;

@end

@protocol VitalConnectDemographic;
/**
 * The VitalConnect library facade.  This object provides all methods for interacting with the VitalConnect system.  Use
 * the createVitalConnect method to create this object.
 */
@interface VitalConnectManager: NSObject

#pragma mark - Instance Access
/**
 * This method must be called to initialize the VitalConnect engine when the application is first initialized.
 * @param product_key  The product key associated with the application using the VitalConnect library.  Contact VitalConnect
 * support to get a key for your application.
 * @param environment  The server environment associated with the application using the VitalConnect library.  Note that setting this
 * to a production environment prior to one being established for the associated product key may result in failure of the library to function.
 * @param rootDir  The full path to a directory in which all Vital Connect files should be stored on the device.
 * @param encrypted  Should device data be encrypted.
 * @retval nil if the VitalConnectManager could not be created, or an invalid product_key was specified.
 * @retval A VitalConnectManager object if successful.
 * @see VitalConnectServerEnvironment
 * @since V1.7
 */
+(VitalConnectManager*) createVitalConnect:(NSString*) product_key environment: (VitalConnectServerEnvironment) environment services:(VitalConnectServerServices)supportedServices
    rootFileDir:(NSString*) rootDir encrypted:(BOOL) encrypted;
/**
 * Retrieves the VitalConnect engine instance initialized in createVitalConnect method call.
 * @retval nil if createVitalConnect method not successful
 */
+(VitalConnectManager*) getSharedInstance;

#pragma mark - Libary State
/**
 * Start the VitalConnect library.  Call this to initialize the application.
 */
-(void)start;

/**
 * Restart the VitalConnect library.  Call this when VitalConnect service discovery has failed due to network connectivity issues.
 */
-(void)restart;

/**
 * Stop the VitalConnect library.  Call this when the application is about to be terminated.
 */
-(void)stop;

/**
 * Retrieves the current server environment setting for the library.
 * @retval The current server environment setting.
 * @since 1.7
 */
- (VitalConnectServerEnvironment) getCurrentEnvironment;

/**
 * Tells the library that the application will go into the background.
 */
-(void) applicationWillResignActive;

/**
 * Tells the library that the application will be terminated.
 */
-(void) applicationWillTerminate;

/**
 * Tells the library that the application will become active.
 */
-(void) applicationDidBecomeActive;

/**
 * Tells the library that it should reduce its memory as low as possible.
 */
-(void)applicationDidReceiveMemoryWarning;

/**
 * Returns the version of the library.
 * @retval The library version.
 */
+ (NSString *)getVersion;

/**
 * Returns the type of current build. Currently only "release" or "test"
 * @retval The build type.
 */
+(NSString*)getBuildType;

#pragma mark - Relay
/**
 * Register this relay with the VitalConnect Relay Services
 * @param relayIdentifier Unique relay identifier
 * @param passCode secret passcode
 * @retval can return kBackendError_DiscoveryError if service discovery failed, kBackendError_Success if successful.
 * @since V1.3
 */
- (VitalConnectBackendErrorCode) registerRelay:(NSString*)relayIdentifier passCode:(NSString*) passCode;

/**
 * UnRegister the currently registered relay with the VitalConnect Relay Services
 * @retval can return kBackendError_DiscoveryError if service discovery failed, kBackendError_Success if successful.
 * @since V1.3
 */
- (VitalConnectBackendErrorCode) unRegisterRelay;



/**
 * Return the currently registered relay.  If no relay is registered, the application should register a new relay with
 * the registerRelay method.
 * @retval The currently registered relay, or nil if no registered relay.
 * @since V1.3
 */
-(NSString *)getRelayIdentifier;

/**
 * Return the currently registered relay guid.  If no relay is registered, the API should return the default unregistered guid.
 * @retval The currently registered relay, or "Unregistered" if no registered relay.
 * @since V1.3
 */
-(NSString *)getRegisteredRelayGuid;

/**
 * Set the newly registered GUID as the relay GUID.
 * @retval YES if it is successful, else NO
 * @since V1.3
 */
-(void)setRegisteredRelayGuid:(NSString *)guid;

/**
 * Returns whether a service is supported or not
 * @retval YES if it is supported, else NO
 * @since V1.3
 */
-(BOOL)isServiceSupported:(int)service;


#pragma mark - Sensor State
/**
 * Returns the currently connecting sensor.
 * @retval The currently connecting sensor.
 */
-(VitalConnectSensor*)getConnectingSensor;

/**
 * Returns the currently connected sensor.
 * @retval The currently connected sensor.
 */
-(VitalConnectSensor*)getActiveSensor;

/**
 * Register sensor for use with the datasource (aka user)
 * @param sensor Pointer to connected sensor
 * @param dataSourceGuid   GUID of the VitalConnect datasource to associate with the sensor
 * @since V1.3
 */
- (void) bindSensor:(VitalConnectSensor*)sensor withGUID:(NSString*) dataSourceGuid;

/**
 * Enable/disable ECG data to the server
 * @param bEnable Enable/disable push of raw data to server
 */
-(void)enableECGData:(BOOL)bEnable;

/**
 * Get ECG data server storage flag
 */
-(BOOL)ECGDataEnabled;

/**
 * Enable/disable Accelerometer data to the server
 * @param bEnable Enable/disable push of raw data to server
 */
-(void)enableAccelerometerData:(BOOL)bEnable;

/**
 * Get Accelerometer data server storage flag
 */
-(BOOL)accelerometerDataEnabled;

/**
 * Add a connection listener to the VitalConnect library. Calls to this listeners selectors will come on the main thread.
 * If calls on the main thread are not required or desirable, use the addListener:withNotificationsOnMainThread method instead.
 * @param listener The connection listener to add.
 */
-(void)addListener:(id<VitalConnectConnectionListener>)listener;

/**
 * Add a connection listener to the VitalConnect library. If bMainThread is NO, calls to the listeners selectors will
 * be called on arbitrary threads.
 * @param listener The connection listener to add.
 * @param bMainThread Specify YES to have the method called on the main thread, NO to call on an arbitrary thread.
 *   Note: If bMainThread is set to true, one extra callback could happen even after removeListener: is called, due to the thread execution order.
 */
-(void)addListener:(id<VitalConnectConnectionListener>)listener withNotificationsOnMainThread:(BOOL)bMainThread;

/**
 * Remove a previously added connection listener to the VitalConnect library.
 *   Note: If bMainThread is set to True on addListener:withNotificationsOnMainThread: call, one extra callback could happen even after removeListener: is called, due to the thread execution order.
 */
-(void)removeListener:(id<VitalConnectConnectionListener>)listener;

#pragma mark - Scan and Connect
/**
 * Start a scan for sensor devices.
 */
-(void)startScan;

/**
 * Stop an ongoing scan for sensor devices.
 */
-(void)stopScan;

/**
 * Connect to a previously found sensor.  Any previously connected sensor will be disconnected.
 * @param sensor The sensor to connect to.
 * @param guid The Sensor Data Source GUID of the user.
 * @retval YES if connection started, NO if parameter error or connection could not be started.
 * @since 1.8
 */
-(BOOL)connectSensor:(VitalConnectSensor*)sensor forSensorSource:(NSString*)guid;

/**
 * Disconnect from a previously connected sensor.
 * @param sensor The sensor to disconnect from.  This method is a no-op for any sensor but the previously connected sensor.
 * @retval YES if sensor is valid
 */
-(BOOL)disconnectSensor:(VitalConnectSensor*)sensor;


/**
 * Disconnect the currently active sensor.
 * @retval YES if currently active sensor is valid
 */
-(BOOL)disconnectSensor;

/**
 * Scan and connect to the sensor with the provided name.
 * @param deviceName The name of the sensor to connect to.
 * @param guid The Sensor Data Source GUID of the user.
 * @retval YES if scan started, NO if parameter error or scan/connection could not be started.
 * @since 1.8
 */
-(BOOL)scanAndConnectSensorForName:(NSString*)deviceName forSensorSource:(NSString*)guid;

/**
 * Scan and connect to the sensor with the provided name.
 * @param deviceName The name of the sensor to connect to.
 * @param secs The scan timeout in seconds. Connection is not affected by this timeout param. A value of zero uses the library's default timeout value
 * @param guid The Sensor Data Source GUID of the user.
 * @retval YES if scan started, NO if parameter error or scan/connection could not be started.
 * @since 1.8
 */
-(BOOL)scanAndConnectSensorForName:(NSString*)deviceName withTimeout:(NSUInteger)secs forSensorSource:(NSString*)guid;

/**
 * Used when the app comes to foreground to cancel background scan (if present) and start foreground scan.  Ends the longer
 * background scans (currently 90 seconds) and starts a shorter scan (10secs now) so we can clear the user's 'scanning' dialog faster.
 * None of this matters if the sensor is already connected as a scan won't be ongoing and no scan will be started.
 * @param deviceName The name of the sensor to connect to.
 * @param guid The Sensor Data Source GUID of the user.
 * @param pageConnect should scan be skipped and paging reconnection occur if peripheral already discovered for the given device name
 * @since 1.95
 */
- (BOOL)scanAndConnectSensorForName:(NSString*)deviceName forSensorSource:(NSString*)guid pageConnect:(BOOL) pageConnect;

/**
 * Enable or disable the auto reconnect feature.
 * @param bEnable YES to enable the feature, NO to disable the feature.
 * @since 1.8
 */
-(void)enableAutoReconnect:(BOOL)bEnable;

/**
 * Auto reconnect value set in library
 * @retval The auto reconnect enable state.
 * @since 1.9
 */
-(BOOL)autoReconnectEnabled;

/**
 * Number of tries to reconnect back to the target sensor. Value is reset after
 * a sensor connects and then disconnects.
 * @retval The current number of tries.
 * @since 1.9
 */
-(NSUInteger)autoReconnectTries;

/**
 * Time in seconds to wait between scans when attempting auto reconnect to module.  
 * Valid range is between 5s and 120s. This value is reset to default when auto reconnect is toggled.
 * @param wait Time in seconds to wait.
 * @retval TRUE if within range, FALSE otherwise
 * @since 1.9
 */
-(BOOL)setAutoReconnectWaitTime:(NSUInteger)wait;

/**
 * Time in seconds library waits between scans when attempting auto reconnect to module.
 * Default is 5 seconds
 *
 * @retval time in seconds
 * @since 1.9
 */
-(NSUInteger)autoReconnectWaitTime;

/**
 * Returns the last scan results, as an array of VitalConnectSensor objects.
 * @retval An array of VitalConnectSensor objects.
 */
-(NSArray*) lastScanResult;

/**
 * Returns the scanner state.
 */
-(VitalConnectScannerState)getScannerState;

/**
 * Returns the auto scan state.
 */
-(VitalConnectScannerState)getAutoscanState;

#pragma mark - Observers
/**
 * Adds a VitalConnect system observer.
 * @param observer The object to receive the notification
 * @param sel The selector to receive the notification
 * @param observerType The VitalConnectObserverType to receive the notification.
 */
-(void)addObserver:(id)observer selector:(SEL)sel name:(VitalConnectObserverType)observerType;

/**
 * Adds a VitalConnect system observer for a particular data key (e.g.. BPM, steps, etc)
 * @param observer The object to receive the notification
 * @param sel The selector to receive the notification
 * @param key The VitalConnectObserverKey that triggers the notification
 */
- (void)addObserver:(id)observer selector:(SEL)sel byKey:(VitalConnectKeyType)key;


/**
 * Removes a VitalConnect system observer.
 * @param observer The object to receive the notification.
 * @param notification The VitalConnectObserverType to receive the notification.
 */
-(void)removeObserver:(id)observer name:(NSString*)notification;

#pragma mark - Device Storage
/**
 * Encrypt all files stored locally.
 */
-(void)encryptLocalStorage:(BOOL) isEnabled;

/**
 * Are all files stored locally encrypted or not.
 */
-(BOOL) isLocalStorageEncrypted;

/**
 * Enable/Disable data collection from module's memory storage. Live and stored alarm streams are always enabled.
 * @param sensor The sensor whose memory storage is targetted
 * @param bOpen Turn on/off stored data streaming
 * @retval YES if sensor is valid
 */
-(BOOL)storedDataStream:(VitalConnectSensor*)sensor open:(BOOL)bOpen;

/**
 * Delete internal storage of sensor data
 */
-(void)clearLocalStorage;

/**
 * Limit internal storage of triggered notifications to the count specified
 * @param count Number of triggered notifications.  If no value set, the library will store the last 50 notifications
 * that were triggered.
 */
-(void)setNotificationStorageLimit:(NSUInteger)count;

/**
 * Return the existing limit of internal storage for triggered notifications.
 */
-(int)getNotificationStorageLimit;

/**
 * Limit internal storage of processed sensor data
 * @param hours Number of hours of data to store. Up to 1 week (24x7 hours)
 */
-(void)setProcessedDataLocalStorageLimit:(NSUInteger)hours;

/**
 * Limit internal storage of non-processed sensor data
 * @param secs Number of seconds of data to store. Up to 24 hours.
 */
-(void)setRawDataLocalStorageLimit:(NSUInteger)secs;

#pragma mark - VCI Cloud
/**
 * Has sample/log/analytics upload to the VCI cloud been enabled.
 */
- (BOOL)isVCICloudEnabled;

/**
 * Check if stored data is streaming
 * @param sensor The sensor to check
 * @retval YES if sensor is valid and stored data is streaming
 */
-(BOOL)storedDataStreaming:(VitalConnectSensor*)sensor;

/**
 * Enable/disable upload of data to the server
 * @param bEnable Enable/disable push of data to server
 */
-(void)enablePostDataToServer:(BOOL)bEnable;

/**
 * Get server storage flag
 */
-(BOOL)isPostDataToServerEnabled;

/**
 * Flush storage of data to server
 */
-(void)flushToServerStorage;

/**
 * Check for any server-side updates, such as new watches or updated demographic information.
 * @param guid  The Sensor Data Source guid to check for.
 */
-(void)checkForServerUpdatesForSensorSource:(NSString*)guid;

/**
 * Add a backend listener to the VitalConnect library. Calls to this listeners selectors will come on the main thread.
 * @param listener The backend listener to add.
 */
-(void)addBackendListener:(id<VitalConnectBackendListener>)listener;

/**
 * Remove a previously added backend listener to the VitalConnect library.
 */
-(void)removeBackendListener:(id<VitalConnectBackendListener>)listener;

/**
 * Determine if network active to server
 */
-(BOOL)isNetworkActive;

#pragma mark - Samples
/**
 * Specifies the callback message type for the readData:withCallback:withContext method.
 * @param contextObject  A caller-specific object specified in the context parameter of
 * the readData:withCallback:withContext method.
 * @param samples An array of data samples in NSDictionary format.  The keys for this dictionary are of type VitalConnectKeyType.
 * @param done If this is TRUE, no more data samples are forthcoming.  If FALSE, more data samples are available.
 * @param error This will be zero if no error or non-zero for an error encountered during the operation.
 * retval Return TRUE from this function to read next page of data, FALSE otherwise.
 */
typedef BOOL (*process_data_func)(id contextObject, NSArray* samples, Boolean done, int error);

/**
 * Reads streaming sensor data from the VitalConnect system.
 * @param sensorDataType The sensor data type to read
 * @param processFunc The callback to call with each new set of sample data.
 * @param context An application-specific context object that will be returned with each call to the processFunc.
 *
 * @retval Zero if success or non-zero if there is a failure to start the read operation.
 */
-(int)readData:(VitalConnectObserverType)sensorDataType withCallback:(process_data_func)processFunc withContext:(id)context;

/**
 * Reads historical streaming sensor data from the VitalConnect system.
 * @param nMins How many minutes ago to read.
 * @param sensorDataType The sensor data type to read
 * @param processFunc The callback to call with each new set of sample data.
 * @param context An application-specific context object that will be returned with each call to the processFunc.
 *
 * @retval Zero if success, or non-zero if there is a failure to start the read operation.
 */
-(int)readDataGoingBack:(NSInteger)nMins forData:(VitalConnectObserverType)sensorDataType withCallback:(process_data_func)processFunc withContext:(id)context;

/**
 * Cancels a previously established read operation.
 * @param sensorDataType The sensor data type to read
 * @param processFunc The callback to call with each new set of sample data.
 * @param context An application-specific context object that will be returned with each call to the processFunc.
 */
-(void)cancelRead:(VitalConnectObserverType)sensorDataType withCallback:(process_data_func)processFunc withContext:(id)context;

/**
 * Specifies the callback message type for the readData:withCallback:withContext method.
 * @param contextObject  A caller-specific object specified in the context parameter of
 * the readData:withCallback:withContext method.
 * @param samples An array of data samples in NSDictionary format.  The keys for this dictionary are of type VitalConnectKeyType.
 * @param done If this is TRUE, no more data samples are forthcoming.  If FALSE, more data samples are available.
 * @param error This will be zero if no error, or non-zero if an error is encountered during the operation.
 * retval Return TRUE from this function to read next page of data, FALSE otherwise.
 */
typedef void (*persist_samples_callback_func)(id contextObject, NSString* filepath, int status);

/**
 * Converts a date to a sample number from the currently active sensor.  The results of this function are undefined when
 * not connected to a sensor.
 * @param date The date to convert.
 * @retval The sample number corresponding to the supplied date.
 */
-(unsigned int)getSampleForDate:(NSDate *)date;

/**
 * Converts a sample number to a date from the currently active sensor.  The results of this function are undefined when
 * not connected to a sensor.
 * @retval The date corresponding to the supplied sample.
 * @param sampleCount The sample to convert.
 */
-(NSDate*)getDateForSample:(unsigned int)sampleCount;

/**
 * Get the sample upload interval
 * @retval Sample upload interval
 */
- (NSTimeInterval) getSampleUploadInterval;

/**
 * Set the sample upload interval.  Valid range is between 5 seconds and 12 hours.
 * @param interval desired upload interval in seconds
 * @retval zero if success, non-zero if value is out of range or could not otherwise set the new interval.
 */
- (int) setSampleUploadInterval:(NSTimeInterval) interval;

#pragma mark - Bluetooth State
/**
 * Tests the iOS bluetooth thread by requesting a log statement from that thread.
 */
-(void)pingBluetoothThread;

/**
 * E.g. is Bluetooth disabled in Settings or is Airplane Mode on
 * @retval whether Bluetooth is on or off.
 */
-(BOOL)isDeviceBluetoothOn;

/**
 * The current status of the device antenna (e.g. Bluetooth).
 * @retval the current bluetooth antenna state.
 */
-(VCDeviceAntennaState)getDeviceBluetoothState;

#pragma mark - Watches
/**
 * Create a new event watch
 * @param guid  The Sensor Data Source guid to create the watch for.
 * @param key  The Data Key to listen to.
 * @param needsConfirmation  true if the generated notification require confirmation, else false.
 * @retval the local id for tracking the new watch.
 * @since V1.9
 */
- (NSString*) createEventWatchForSensorSource:(NSString*)guid
                                      DataKey:(VitalConnectWatchType)key
                                 Confirmation:(BOOL)needsConfirmation;



/**
 * Create a new watch of type threshold
 * @param guid  The Sensor Data Source guid to create the watch for.
 * @param key  The Data Key to listen to.
 * @param severity  The severity of notifications.
 * @param bound  The bound, above or below, of the watch.
 * @param needsConfirmation  true if the generated notification require confirmation, else false.
 * @param thresholdValue The value to trigger at.
 * @retval localId for the watch
 * @since V1.5
 */
- (NSString*) createThresholdWatchForSensorSource:(NSString*)guid
                                     DataKey:(VitalConnectThresholdDataKey)key
                                    Severity:(VitalConnectThresholdWatchSeverity)severity
                                       Bound:(VitalConnectThresholdWatchBound)bound
                                Confirmation:(BOOL)needsConfirmation
                              ThresholdValue:(NSNumber*)thresholdValue;


/**
 * Gets the minimum and maximum threshold values allowed for the specified key.
 * @param key The data key.
 * @retval An array of NSNumber values, with the minimum at position zero and maximum at position 1.
 */
-(NSArray *)getThresholdWatchValueRangeForKey: (VitalConnectThresholdDataKey) key;


/**
 * Get an array of VitalConnectWatches for a given Sensor Data Source @see VitalConnectWatch
 * @param guid  Sensor Data Source
 * @retval an array of type VitalConnectWatch
 * @since V1.5
 */
- (NSArray*) getWatchListForSensorSource:(NSString*)guid;

/**
 * Get a watch for the Sensor Data Source with the given local ID
 * @param guid  Sensor Data Source
 * @param localId The local ID of the watch
 * @retval a VitalConnectWatch
 * @since V1.9
 */
- (id<VitalConnectWatch>) getWatchForSensorSource: (NSString *)guid withLocalId:(NSString*)localId;

/**
 * Delete the given watch for the given sensor data source @see VitalConnectWatch
 * @param watch The watch to be deleted
 * @since 1.7
 */
- (void) deleteWatch:(id<VitalConnectWatch>)watch;

/**
 * Add a Watch Manager observer to the VitalConnect system for the given Sensor Data Source
 * @param observer The listener to add.
 * @param guid The Sensor Data Source.
 * @see VitalConnectWatchManagerObserver
 * @since V1.5
 */
- (void) addWatchManagerObserver:(id<VitalConnectWatchManagerObserver>)observer forSensorSource:(NSString*)guid;
/**
 * Remove a Watch Manager observer to the VitalConnect system for the given Sensor Data Source
 * @param observer The listener to add.
 * @param guid The Sensor Data Source.
 * @see VitalConnectWatchManagerObserver
 * @since V1.5
 */
- (void) delWatchManagerObserver:(id<VitalConnectWatchManagerObserver>)observer forSensorSource:(NSString*)guid;

#pragma mark - Notes
/**
 * Returns an array including all note entries registered in the VitalConnect system.  Note entries are persisted across
 * application exits.
 * @retval An array of type VitalConnectNoteEntry
 * @since V1.1.1
 */
-(NSArray*) getNoteEntries;

/**
 * Adds a note entry to the VitalConnect system.
 * @param entry The entry to add.
 * @since V1.1.1
 */
-(void) addNoteEntry: (VitalConnectNoteEntry *)entry;

/**
 * Removes a note entry from the VitalConnect system.
 * @param entry The entry to remove.
 * @since V1.1.1
 */
-(void) removeNoteEntry: (VitalConnectNoteEntry *)entry;

/**
 * Removes all note entries from the VitalConnect system.
 * @since V1.1.1
 */
-(void) removeAllNoteEntries;

/**
 * Add a note entry listener to the VitalConnect system.
 * @param listener The listener to add.
 * @see VitalConnectNoteManagerListener
 * @since V1.1.1
 */
-(void) addNoteListener: (id <VitalConnectNoteManagerListener>) listener;

/**
 * Remove a note entry listener from the VitalConnect system.
 * @param listener The listener to remove.
 * @see VitalConnectNoteManagerListener
 * @since V1.1.1
 */
-(void) removeNoteListener: (id <VitalConnectNoteManagerListener>) listener;

/**
 * Used to allow the library to perform background fetches.  E.g. currently to fetch updated demographics, notifications,
 * and watches from the server while in the background.
 */
- (void)performBackgroundFetch:(NSString*) guid completionHandler:(void (^)(BOOL))completionHandler;

#pragma mark - Logging
/**
 * Adds an object that implements the VitalConnectLogManager protocol to the log listener.
 * @param logger the object to receive the log messages.
 * @since V1.1.1
 */
- (void) addLogListener:(id<VitalConnectLogManager>) logger;

/**
 * Removes an object implementing VitalConnectLogManager protocol from the list log listeners.
 * @param logger the object to be removed from listening to log messages.
 * @since V1.1.1
 */
- (void) removeLogListener:(id<VitalConnectLogManager>) logger;

/**
 * Adds the given message to the libraries logs.
 * @param format log, printf-style format string
 * @param ... additional formatting arguments to be substituted into format
 * @param NS_FORMAT_FUNCTION takes a format string and optional varargs as arguments
 * @since V1.1.1
 */
- (void) appendLogMsg:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

#pragma mark - Demographics
/**
 * Retrieves the Demographic data for the given sensor data source.
 * @param source The sensor data source guid.
 * @retval demographic data for the given source.
 * @since 1.5
 */
- (id<VitalConnectDemographic>) getDemographicData:(NSString*)source;


#pragma mark - Firmware
/**
 * Add listener to the sensor firmware upgrade process
 * @param listener interface to be called during upgrade process. An instance is only added once for multiple calls without remove.
 */
-(void)addFirmwareUpgradeListener:(id<VitalConnectFirmwareUpgradeListener>)listener;

/**
 * Remove a previously added firmware upgrade listener to the VitalConnect library.
 */
-(void)removeFirmwareUpgradeListener:(id<VitalConnectFirmwareUpgradeListener>)listener;

/**
 * Kicks off check for upgrade for a sensor. Availability will be returned through the listener
 * @param sensor module to check for firmware upgrade availability
 * @param upgradeListener interface to be called during upgrade process. See addFirmwareUpgradeListener:
 */
- (void) checkForFirmwareUpgradeFor:(VitalConnectSensor*)sensor withListener:(id<VitalConnectFirmwareUpgradeListener>)upgradeListener;

/**
 * Assumes upgrade path has been established via API commands.  Starts download of firmware image and subsequent upgrade of module.
 * Application can stop the upgrade process after download by listening to onFirmwareDownloadComplete
 * @param sensor module to upgrade
 * @param upgradeListener interface to be called during upgrade process. See addFirmwareUpgradeListener:
 */
- (void) startFirmwareUpgradeFor:(VitalConnectSensor*)sensor withListener:(id<VitalConnectFirmwareUpgradeListener>)upgradeListener;

/**
 * Assumes upgrade path has been established via API commands.  Starts download of firmware image and subsequent upgrade of module.
 * Application can stop the upgrade process after download by listening to onFirmwareDownloadComplete
 * @param sensor module being upgrade
 * @param upgradeStats Structure filled with current upgrade status
 * @retval YES - returned upgrade stats are valid.  NO - firmware upgrade stats could not be retrieved.
 */
- (BOOL) getFirmware:(VitalConnectSensor*)sensor UpgradeStatus:(VitalConnectFirmwareUpgradeStats*)upgradeStats;

@end

#pragma mark - Sensor Variables
/**
 * Sensor link connection status.
 * @see connectionStatus
 */
typedef enum {
    /// Connection status, the sensor is pairing.
    kVCIConnectionStatus_pairing,
    /// Connection status, the sensor is being paged.
    kVCIConnectionStatus_paging,
    /// Connection status, the sensor is authenticating.
    kVCIConnectionStatus_authenticating,
    /// Connection status, the sensor is enabling encryption.
    kVCIConnectionStatus_securing,
    /// Connection status, the sensor is connected.
    kVCIConnectionStatus_connected,
    /// Connection status, the sensor is disconnecting.
    kVCIConnectionStatus_disconnecting,
    /// Connection status, the sensor is disconnected.
    kVCIConnectionStatus_disconnected
} VitalConnectConnectionStatus;

/**
 * A VitalConnect sensor object.
 */
@interface VitalConnectSensor : NSObject <NSCopying, VitalConnectObservable>

/// The name for this sensor.  This name is specified by the sensor hardware.  This is only valid when the sensor is connected.
@property (readonly, strong, nonatomic) NSString *name;

/// The serial number of the sensor.  The serial number is specified by the sensor hardware. This is only valid when the sensor is connected.
@property (readonly, strong, nonatomic) NSString *serialNumber;

/// The current UUID for the sensor.  This is specified by the Bluetooth library on the iPhone.
@property (readonly, strong, nonatomic) NSString *UUID;

/// The battery level of the sensor.  This is only valid when the sensor is currently connected.  It will be -1 if no battery information is available.
@property (readonly, strong, nonatomic) NSNumber *batteryLevel;

/// The firmware version of the sensor.  This is only valid when the sensor is connected.
@property (readonly, strong, nonatomic) NSString *firmwareVersion;

/// The hardware version of the sensor.  This is only valid when the sensor is connected.
@property (readonly, strong, nonatomic) NSString *hardwareVersion;

/// A flag telling whether or not this sensor is connected.
@property (readonly, nonatomic) BOOL connected;

/// A flag telling if sensor/patch in wrong combination.
@property (readonly, nonatomic) BOOL badProductCombination;

/// A property telling the connectivity status of the sensor.
@property (readonly, nonatomic) VitalConnectConnectionStatus connectionStatus;

/**
 * Has the relay library synced the all controls state for the sensor (e.g. high frequency enabled/disabled,
 * blink led enabled/disabled, high quality ecg enabled/disabled, ...)?
 */
@property (readonly) BOOL allControlStatesSynced;

/**
 * Has the relay library synced the blink LED state for the sensor?
 */
@property (readonly) BOOL isBlinkLEDStateSynced;

/**
 * Is ECG avvailable on the sensor?
 */
@property (readonly) BOOL isECGAvailable;

/**
 * Has the relay library synced the Enable ECG state for the sensor?
 */
@property (readonly) BOOL isEnableECGStateSynced;

/**
 * Is acceleromter avvailable on the sensor?
 */
@property (readonly) BOOL isAccelerometerAvailable;

/**
 * Has the relay library synced the enable acceleromter state for the sensor?
 */
@property (readonly) BOOL isEnableAccelerometerStateSynced;

// Ask a connected module to blink its LED for a short period of time. @since V1.7
@property BOOL blinkLED;

/// A connected module's ECG data status
@property BOOL enableECGData;

/// A connected module's acceleromter data status
@property BOOL enableAccelerometerData;

/// The free memory level of the sensor.  This is only valid when the sensor is currently connected.  It will be -1 if no memory information is available.
@property (readonly, strong, nonatomic) NSNumber *freeMemory;

/// The current Device Type (Patch Type)
@property (readonly, strong, nonatomic) NSString *deviceType;

/// The current Product Type for the sensor.
@property (readonly, assign) int productType;

/// The current Product Type name for the sensor.
@property (readonly, strong, nonatomic) NSString *productTypeName;

/// The current Product version for the sensor.
@property (readonly, strong, nonatomic) NSString *productVersion;


/**
 * A property holding the current sensor status.
 * @since V1.1.1
 */
@property (readonly, nonatomic) VitalConnectPatchStatus patchStatus;

/**
 * Property holding the current link loss percent
 * @since V1.1.1
 */
@property (strong, nonatomic, readonly) NSNumber* linkLoss;

@end


#pragma mark - Demographics
/**
 * A definition of gender for VitalConnectDemographic information.
 */
enum VitalConnectGender {
    /// The patch wearer is female.
    VitalConnectGender_FEMALE,
    /// The patch wearer is male.
    VitalConnectGender_MALE,
};

typedef enum  {
	/// The birthyear of the patch wearer
    dd_birthyear,
    /// The initial weight of the patch wearer (at the time the patch was first put on)
    dd_weight,
    /// The height of the patch wearer
    dd_height,
    /// The gender of the patch wearer
    dd_gender,
    /// The perceived functional ability of the patch wearer
    dd_pfa,
    /// The physical activity rating of the patch wearer
    dd_par,
    /// The resting heart rate of the patch wearer
    dd_restingHeartrate,
    /// Resting heart rate persistence.  If set, the manually-entered resting heart rate will not be modified by the sensor.
    dd_rhrPersistence,
    /// The patch location on the wearer
    dd_patchLocation,
    /// The maximum number of demographic display types
    dd_MAX
} DemographicDisplayType;

/**
 * Demographic data for a given sensor data source user.
 * @since 1.5
 */
@protocol VitalConnectDemographic <VitalConnectObservable>
@required

/// Sensor data source the demographic information pertains to
@property (retain, readonly, nonatomic) NSString* deviceDataSource;

/// Birth year of the user.  Valid range is 1900 to present year, inclusive.
@property (retain, nonatomic) NSNumber* yearBorn;

/// Weight in kilograms.  Valid range is 1kg to 1000kg inclusive.
@property (retain, nonatomic) NSNumber* weight;

/// Height in centimeters.  valid range is 10cm to 300cm  inclusive.
@property (retain, nonatomic) NSNumber* height;

/// @see VitalConnectGender
@property (nonatomic) enum VitalConnectGender gender;

/// Perceived Functional Ability.  Valid range is 2 through 26 inclusive.
@property (retain, nonatomic) NSNumber* pfa;

/// Physical Activity Rating.  Valid range is 0 to 10 inclusive.
@property (retain, nonatomic) NSNumber* par;

/// Resting heart rate.  Valid range is 30 to 200 inclusive.
@property (retain, nonatomic) NSNumber* restingHeartrate;

/// Resting heart rate persistence.  When YES, the manually-entered resting heart rate will not be automatically adjusted by the sensor.
@property (nonatomic) BOOL rhrPersistence;

/// Resting heart rate.  Valid values include '1 - Above pectoralis major', '2 - Sternum', and 3 - Below pectoralis major.
@property (retain, nonatomic) NSString* patchLocation;

@end


