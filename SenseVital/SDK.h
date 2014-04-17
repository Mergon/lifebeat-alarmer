/**
 SDK.h
 
 Copyright 2013 Vital Connect Inc. All rights reserved.
 
 This Software is the copyrighted work of Vital Connect, Inc. Use of the Software is governed by the terms of the end user license agreement,  which accompanies or is included with the Software ("License Agreement"). An end user will be unable to install or use any Software that is accompanied by or includes the License Agreement, unless he or she first agrees to the License Agreement terms.
 
 The Software is made available solely for use by end users according to the License Agreement. Any reproduction or redistribution of the Software not in accordance with the License Agreement is expressly prohibited by law.
 
 WITHOUT LIMITING THE FOREGOING, COPYING OR REPRODUCTION OF THE SOFTWARE OR REDISTRIBUTION IS EXPRESSLY PROHIBITED, UNLESS SUCH REPRODUCTION OR REDISTRIBUTION IS EXPRESSLY PERMITTED BY THE LICENSE AGREEMENT ACCOMPANYING SUCH SOFTWARE.
 
 THE SOFTWARE IS WARRANTED, IF AT ALL, ONLY ACCORDING TO THE TERMS OF THE LICENSE AGREEMENT. EXCEPT AS WARRANTED IN THE LICENSE AGREEMENT, VITAL CONNECT, INC HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS WITH REGARD TO THE SOFTWARE, INCLUDING ALL WARRANTIES AND CONDITIONS OF MERCHANTABILITY, WHETHER EXPRESS, IMPLIED OR STATUTORY, FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT.
 
 */

#ifndef SampleiOSApp_SDK_h
#define SampleiOSApp_SDK_h

/*
 * The API key is provided by Vital Connect and identifies your application to the system.
 */
#define SDK_API_KEY @"0e42583d2a1cb3cc6a103e0b92f24dc65715d0bc"

/*
 * the relay ID and password are credentials for your iphone that can be used by the sample application to work with the Vital Connect system, until you want to use the system's credential-generation functionality.  These credentials are used to authenticate the iphone to the Vital Connect system.
 */
#define SDK_RELAY_ID @"44ffe44d-f255-4bc9-901c-fbb2acda6bd2"
#define SDK_RELAY_PASSWORD @"XqdF9CyDcmqjA3tK"


/*
 * the sensor data source is a guid that can be used by the sample application to work with the Vital Connect system, until you want to access the system's sensor data source-generation functionality.  It uniquely represents a patch-wearer in the Vital Connect system.
 */
#define SDK_SENSOR_DATA_SOURCE_GUID @"3cbf6a9d-e9c9-4580-85af-81bf13422759"


#endif
